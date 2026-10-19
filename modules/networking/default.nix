{ config, pkgs, ... }:

let
  # The NextDNS profile ID is a secret this public repo must not carry, so
  # `nextdns-profile` writes it to an unmanaged drop-in that rebuilds never
  # touch. The "<host>-" prefix makes NextDNS log this machine as a named device.
  nextdnsProfile = pkgs.writeShellApplication {
    name = "nextdns-profile";
    runtimeInputs = with pkgs; [ coreutils curl gnugrep gnused systemd ];
    text = ''
      conf=/etc/systemd/resolved.conf.d/50-nextdns.conf

      need_root() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "nextdns-profile: run with sudo" >&2
          exit 1
        fi
      }

      case "''${1:-}" in
        "")
          if [ -f "$conf" ]; then
            echo "profile: $(grep -o '[0-9a-f]*\.dns\.nextdns\.io' "$conf" | head -n1 | sed 's/\.dns\.nextdns\.io//')"
          else
            echo "profile: none (using network DNS)"
          fi
          curl -fsSL --max-time 5 https://test.nextdns.io || true
          echo
          ;;
        -h|--help)
          echo "usage: nextdns-profile [<profile-id> | --off]"
          ;;
        --off)
          need_root
          rm -f "$conf"
          systemctl restart systemd-resolved
          echo "NextDNS disabled"
          ;;
        *)
          need_root
          if ! printf '%s' "$1" | grep -qx '[0-9a-f]\{6\}'; then
            echo "nextdns-profile: '$1' is not a 6-character NextDNS profile ID" >&2
            exit 1
          fi
          sni="${config.networking.hostName}-$1.dns.nextdns.io"
          mkdir -p "$(dirname "$conf")"
          printf '[Resolve]\nDNS=45.90.28.0#%s 2a07:a8c0::#%s 45.90.30.0#%s 2a07:a8c1::#%s\nDNSOverTLS=yes\nDomains=~.\n' \
            "$sni" "$sni" "$sni" "$sni" > "$conf"
          chmod 644 "$conf"
          systemctl restart systemd-resolved
          sleep 1
          curl -fsSL --max-time 5 https://test.nextdns.io || true
          echo
          ;;
      esac
    '';
  };
in
{
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Local stub resolver so /etc/resolv.conf is always "nameserver 127.0.0.53",
  # identical and parseable on every network. Routers that advertise scoped
  # link-local nameservers (fe80::...%wlan) otherwise land verbatim in
  # resolv.conf, which glibc tolerates but Chromium's resolver rejects wholesale
  # — every request in Helium then dies with ERR_NAME_NOT_RESOLVED.
  services.resolved.enable = true;

  environment.systemPackages = [ pkgs.openvpn nextdnsProfile ];

  services.openssh.enable = true;

  # Allow Next.js / dev server on local network
  networking.firewall.allowedTCPPorts = [ 3000 ];
}
