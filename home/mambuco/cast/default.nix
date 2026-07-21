{ pkgs, ... }:

let
  stremio-cast = pkgs.writeShellScriptBin "stremio-cast" ''
    set -euo pipefail

    url="''${1:-}"
    if [ -z "$url" ]; then
      url="$(${pkgs.wl-clipboard}/bin/wl-paste --no-newline 2>/dev/null || true)"
    fi

    case "$url" in
      http://* | https://*) ;;
      *)
        echo "usage: stremio-cast [media-url] — pass the stream link or copy it to the clipboard first" >&2
        exit 1
        ;;
    esac

    device="''${STREMIO_CAST_DEVICE:-}"
    if [ -z "$device" ]; then
      # discover on the physical interface: with the VPN up, the default
      # route points at the tunnel and SSDP multicast would go nowhere
      iface="$(${pkgs.iproute2}/bin/ip -4 -o addr show scope global \
        | ${pkgs.gawk}/bin/awk '$2 !~ /^(tun|tap|wg|proton)/ { print $2; exit }')"
      scan="$(${pkgs.gupnp-tools}/bin/gssdp-discover -n 3 \
        -t urn:schemas-upnp-org:device:MediaRenderer:1 ''${iface:+-i "$iface"})"
      device="$(printf '%s\n' "$scan" | ${pkgs.gawk}/bin/awk '/Location:/ { print $2; exit }')"
    fi

    if [ -z "$device" ]; then
      echo "stremio-cast: no DLNA renderer found on the network" >&2
      exit 1
    fi

    echo "casting to $device"
    exec ${pkgs.go2tv}/bin/go2tv -u "$url" -t "$device"
  '';
in
{
  home.packages = [
    pkgs.go2tv
    stremio-cast
  ];
}
