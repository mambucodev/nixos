{ config, lib, ... }:

# Plain on-disk key (~/.ssh/id_ed25519), no agent. Passphrase-less and protected
# at rest by the LUKS root; created manually once, not managed declaratively.
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
    };
  };

  # OpenSSH requires ~/.ssh/config to be owned by the user (or root) and not
  # group/world-writable. Because Home Manager manages files as symlinks into the
  # Nix store, inside user namespaces or sandboxes (e.g., bubblewrap, Electron/IDEs,
  # or containers) the root-owned store files appear as owned by 'nobody' (UID 65534),
  # causing OpenSSH to error with "Bad owner or permissions on ~/.ssh/config".
  #
  # We disable Home Manager's symlink creation for .ssh/config and install it
  # directly with 0600 permissions in an activation step.
  home.file.".ssh/config".enable = false;

  home.activation.copySshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG "$HOME/.ssh"
    run chmod 700 "$HOME/.ssh"
    run rm -f "$HOME/.ssh/config"
    run install -m 0600 ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
  '';
}
