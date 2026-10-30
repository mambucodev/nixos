{ ... }:

{
  nix.distributedBuilds = true;

  # "nix-builder" is an SSH alias: the real host, user, key and host key live
  # in /root/.ssh/{config,known_hosts}, outside this repo. Root, because the
  # laptop's nix-daemon is what opens the connection.
  nix.buildMachines = [{
    # Ubuntu's non-interactive SSH shell never sources the Nix profile, so
    # point straight at the daemon instead of relying on PATH.
    hostName = "nix-builder?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon";
    protocol = "ssh-ng";
    system = "x86_64-linux";
    # Shared box: cap parallel builds; each build still gets all its cores.
    maxJobs = 4;
    speedFactor = 10;
    supportedFeatures = [ "big-parallel" "benchmark" ];
  }];

  # The builder pulls dependencies from cache.nixos.org itself instead of the
  # laptop uploading them over the home uplink.
  nix.settings.builders-use-substitutes = true;
}
