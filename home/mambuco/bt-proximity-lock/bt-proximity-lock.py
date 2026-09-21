#!/usr/bin/env python3
"""
Bluetooth Proximity Screen Locker
Monitors proximity of paired Bluetooth device (e.g., Pixel Watch 4)
and locks the screen when moving away (>= 3-5 meters).
Optimized for zero resource waste when already locked, with hysteresis/tolerance.
Includes 'Arm-on-Presence' safeguard to prevent infinite lock loops if battery dies.
"""

import os
import sys
import time
import re
import signal
import logging
import argparse
import subprocess
from pathlib import Path

# Defaults
DEFAULT_CONFIG_PATH = Path.home() / ".config" / "bt-proximity-lock.conf"
DEFAULT_MAC = "64:9D:38:1A:4F:5A"
DEFAULT_DEVICE_NAME = "Pixel Watch 4"
DEFAULT_RSSI_THRESHOLD = -4      # Bluetooth Classic RSSI: 0 dB is golden range; <= -4 dB indicates ~3-5m away
DEFAULT_TOLERANCE_COUNT = 5      # Consecutive readings below threshold before triggering lock
DEFAULT_POLL_INTERVAL = 2.0      # Polling interval (seconds) when unlocked
DEFAULT_LOCKED_INTERVAL = 8.0    # Backoff polling interval (seconds) when screen is already locked
DEFAULT_PAUSE_MEDIA = True       # Pause MPRIS media players when screen locks

logger = logging.getLogger("bt-proximity-lock")


def parse_config(config_path: Path) -> dict:
    """Load simple KEY=VALUE configuration file if it exists."""
    config = {
        "DEVICE_MAC": DEFAULT_MAC,
        "DEVICE_NAME": DEFAULT_DEVICE_NAME,
        "RSSI_THRESHOLD": DEFAULT_RSSI_THRESHOLD,
        "TOLERANCE_COUNT": DEFAULT_TOLERANCE_COUNT,
        "POLL_INTERVAL": DEFAULT_POLL_INTERVAL,
        "LOCKED_INTERVAL": DEFAULT_LOCKED_INTERVAL,
        "PAUSE_MEDIA": DEFAULT_PAUSE_MEDIA,
    }
    if not config_path.exists():
        return config

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                k = k.strip().upper()
                v = v.strip().strip('"').strip("'")
                if k == "DEVICE_MAC":
                    config["DEVICE_MAC"] = v
                elif k == "DEVICE_NAME":
                    config["DEVICE_NAME"] = v
                elif k == "RSSI_THRESHOLD":
                    config["RSSI_THRESHOLD"] = int(v)
                elif k == "TOLERANCE_COUNT":
                    config["TOLERANCE_COUNT"] = int(v)
                elif k == "POLL_INTERVAL":
                    config["POLL_INTERVAL"] = float(v)
                elif k == "LOCKED_INTERVAL":
                    config["LOCKED_INTERVAL"] = float(v)
                elif k == "PAUSE_MEDIA":
                    config["PAUSE_MEDIA"] = v.lower() in ("true", "1", "yes")
    except Exception as e:
        logger.warning("Could not read config file %s: %s", config_path, e)

    return config


def send_notification(summary: str, body: str):
    """Send native desktop notification via DBus."""
    try:
        subprocess.run(
            [
                "gdbus", "call", "--session",
                "--dest", "org.freedesktop.Notifications",
                "--object-path", "/org/freedesktop/Notifications",
                "--method", "org.freedesktop.Notifications.Notify",
                "bt-proximity-lock", "0", "dialog-information",
                summary, body, "[]", "{}", "4000"
            ],
            capture_output=True, timeout=2
        )
    except Exception:
        pass


def get_user_session_id() -> str:
    """Find active display session ID via loginctl."""
    user = os.environ.get("USER", os.environ.get("LOGNAME", ""))
    if not user:
        try:
            user = subprocess.run(["id", "-un"], capture_output=True, text=True, check=True).stdout.strip()
        except Exception:
            user = "1000"
    try:
        res = subprocess.run(
            ["loginctl", "show-user", user, "-p", "Display", "--value"],
            capture_output=True, text=True, check=True
        )
        sess = res.stdout.strip()
        if sess and sess != "0":
            return sess
    except Exception:
        pass
    return "auto"


def is_screen_locked() -> bool:
    """
    Check whether the desktop screen is currently locked.
    Checks GNOME ScreenSaver DBus first, then falls back to loginctl.
    """
    # 1. GNOME ScreenSaver DBus
    try:
        res = subprocess.run(
            [
                "dbus-send", "--session", "--dest=org.gnome.ScreenSaver",
                "--type=method_call", "--print-reply",
                "/org/gnome/ScreenSaver", "org.gnome.ScreenSaver.GetActive"
            ],
            capture_output=True, text=True, timeout=2
        )
        if res.returncode == 0:
            if "boolean true" in res.stdout:
                return True
            if "boolean false" in res.stdout:
                return False
    except Exception:
        pass

    # 2. loginctl LockedHint
    try:
        sess = get_user_session_id()
        cmd = ["loginctl", "show-session"]
        if sess != "auto":
            cmd.append(sess)
        cmd.extend(["-p", "LockedHint", "--value"])
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=2)
        if res.returncode == 0:
            return res.stdout.strip() == "yes"
    except Exception:
        pass

    return False


def lock_screen():
    """Lock user session via GNOME DBus and loginctl."""
    logger.info("Executing screen lock...")
    # Optional MPRIS pause
    try:
        subprocess.run(
            [
                "dbus-send", "--session", "--type=method_call",
                "--dest", "org.mpris.MediaPlayer2.Player",
                "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player.Pause"
            ],
            capture_output=True, timeout=1
        )
    except Exception:
        pass

    # GNOME ScreenSaver Lock
    locked = False
    try:
        res = subprocess.run(
            [
                "dbus-send", "--session", "--type=method_call",
                "--dest=org.gnome.ScreenSaver",
                "/org/gnome/ScreenSaver", "org.gnome.ScreenSaver.Lock"
            ],
            capture_output=True, timeout=2
        )
        if res.returncode == 0:
            locked = True
    except Exception:
        pass

    # loginctl fallback
    if not locked:
        try:
            subprocess.run(["loginctl", "lock-session"], capture_output=True, timeout=2)
        except Exception as e:
            logger.error("Failed to execute loginctl lock-session: %s", e)


def get_bluetooth_rssi(mac: str) -> tuple[bool, int | None]:
    """
    Query RSSI for the given Bluetooth MAC address.
    Returns:
        (connected: bool, rssi: int or None)
    """
    try:
        res = subprocess.run(
            ["hcitool", "rssi", mac],
            capture_output=True, text=True, timeout=3
        )
        out = (res.stdout + res.stderr).strip()
        if "Not connected" in out or res.returncode != 0:
            # Trigger background reconnect attempt if disconnected
            try:
                subprocess.Popen(
                    ["bluetoothctl", "connect", mac],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
            except Exception:
                pass
            return False, None

        # Format: "RSSI return value: 0" or "-5"
        match = re.search(r"RSSI return value:\s*(-?\d+)", out)
        if match:
            return True, int(match.group(1))

        return True, 0
    except subprocess.TimeoutExpired:
        logger.debug("hcitool rssi timed out for %s", mac)
        return False, None
    except Exception as e:
        logger.debug("Error running hcitool rssi: %s", e)
        return False, None


def run_calibration(mac: str, threshold: int, interval: float):
    """Interactive calibration mode: print continuous RSSI readings and visual bar."""
    print(f"\n--- Bluetooth Proximity Calibration ---")
    print(f"Target Device: {mac}")
    print(f"Current Threshold: {threshold} dB")
    print(f"Sampling every {interval}s. Walk away 3-5 meters to observe readings.\nPress Ctrl+C to stop.\n")

    try:
        while True:
            connected, rssi = get_bluetooth_rssi(mac)
            locked = is_screen_locked()
            status_lock = "[LOCKED]" if locked else "[UNLOCKED]"

            if not connected or rssi is None:
                print(f"{status_lock} Device: DISCONNECTED / OUT OF RANGE -> Trigger: AWAY (Lock candidate)")
            else:
                bars = max(0, min(10, int((rssi + 20) / 2)))
                meter = "#" * bars + "-" * (10 - bars)
                is_away = rssi <= threshold
                decision = "AWAY (Lock trigger)" if is_away else "NEAR (Safe)"
                print(f"{status_lock} RSSI: {rssi:+3d} dB  [{meter}]  Status: {decision}")

            time.sleep(interval)
    except KeyboardInterrupt:
        print("\nCalibration ended.")


def run_daemon(config: dict):
    """
    Main daemon loop with:
    - Arm-on-presence safeguard (prevents infinite lock loop if watch battery dies)
    - Tolerance debounce against brief radio interference
    - Zero resource consumption while locked
    """
    mac = config["DEVICE_MAC"]
    device_name = config["DEVICE_NAME"]
    threshold = config["RSSI_THRESHOLD"]
    tolerance = config["TOLERANCE_COUNT"]
    poll_interval = config["POLL_INTERVAL"]
    locked_interval = config["LOCKED_INTERVAL"]

    logger.info("Starting bt-proximity-lock daemon for %s (%s)", device_name, mac)
    logger.info("Threshold: <= %d dB | Tolerance strikes: %d", threshold, tolerance)
    logger.info("Intervals: %0.1fs (unlocked), %0.1fs (locked power-save)", poll_interval, locked_interval)

    strikes = 0
    was_locked = False
    armed = False
    notified_standby = False

    while True:
        # Check if laptop is already locked
        locked = is_screen_locked()

        if locked:
            if not was_locked:
                logger.info("Screen is locked. Entering power-save mode (suspending Bluetooth polling).")
                was_locked = True
                strikes = 0
                armed = False  # Must re-arm upon unlock once watch is confirmed nearby!

            # DO NOT poll bluetooth while locked! Save radio & battery.
            time.sleep(locked_interval)
            continue

        if was_locked:
            logger.info("Screen unlocked. Waiting for %s presence to re-arm...", device_name)
            was_locked = False
            strikes = 0
            armed = False
            notified_standby = False

        # Query Bluetooth proximity
        connected, rssi = get_bluetooth_rssi(mac)

        # Check if watch is present nearby to ARM the lock trigger
        if connected and rssi is not None and rssi > threshold:
            if not armed:
                logger.info("%s detected nearby (%d dB). Proximity lock ARMED.", device_name, rssi)
                armed = True
                notified_standby = False
            strikes = 0
            time.sleep(poll_interval)
            continue

        # If NOT armed yet (e.g. watch battery died or Bluetooth off when unlocking)
        if not armed:
            if not notified_standby:
                logger.warning(
                    "%s not detected nearby. Proximity lock in STANDBY (prevents infinite lock loop).",
                    device_name
                )
                send_notification(
                    "Proximity Lock: Standby",
                    f"{device_name} is not connected or battery is low. Screen lock is suspended until watch reconnects."
                )
                notified_standby = True
            time.sleep(3.0)
            continue

        # ARMED state: watch was confirmed nearby and has now moved away or dropped
        if not connected or rssi is None:
            strikes += 1
            logger.warning(
                "Device %s disconnected or out of range. Strike %d/%d",
                mac, strikes, tolerance
            )
        elif rssi <= threshold:
            strikes += 1
            logger.info(
                "Weak signal: %d dB (Threshold: <= %d dB). Strike %d/%d",
                rssi, threshold, strikes, tolerance
            )

        # Evaluate trigger threshold
        if strikes >= tolerance:
            logger.warning(
                "Tolerance limit reached (%d/%d away strikes). Triggering screen lock!",
                strikes, tolerance
            )
            lock_screen()
            strikes = 0
            armed = False
            was_locked = True
            time.sleep(locked_interval)
            continue

        time.sleep(poll_interval)


def main():
    parser = argparse.ArgumentParser(description="Bluetooth Proximity Screen Locker")
    parser.add_argument(
        "--config", type=Path, default=DEFAULT_CONFIG_PATH,
        help=f"Path to configuration file (default: {DEFAULT_CONFIG_PATH})"
    )
    parser.add_argument("--mac", type=str, help="Device Bluetooth MAC address")
    parser.add_argument("--threshold", type=int, help="RSSI threshold in dB (e.g. -4)")
    parser.add_argument("--tolerance", type=int, help="Consecutive strikes required to lock (e.g. 5)")
    parser.add_argument("--interval", type=float, help="Polling interval in seconds")
    parser.add_argument("--calibrate", "-c", action="store_true", help="Run in live calibration/test mode without locking")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose debug logging")

    args = parser.parse_args()

    # Configure logging
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    config = parse_config(args.config)

    # Command line overrides
    if args.mac:
        config["DEVICE_MAC"] = args.mac
    if args.threshold is not None:
        config["RSSI_THRESHOLD"] = args.threshold
    if args.tolerance is not None:
        config["TOLERANCE_COUNT"] = args.tolerance
    if args.interval is not None:
        config["POLL_INTERVAL"] = args.interval

    # Graceful shutdown handler
    def handle_exit(signum, frame):
        logger.info("Received termination signal %s. Exiting cleanly.", signum)
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_exit)
    signal.signal(signal.SIGTERM, handle_exit)

    if args.calibrate:
        run_calibration(
            config["DEVICE_MAC"],
            config["RSSI_THRESHOLD"],
            config["POLL_INTERVAL"]
        )
    else:
        run_daemon(config)


if __name__ == "__main__":
    main()
