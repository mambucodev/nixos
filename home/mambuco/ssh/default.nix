{ ... }:

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
}
