{ ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Mambuco";
        email = "gabriele.giambrone@icloud.com";
        signingKey = "~/.ssh/id_ed25519.pub";
      };

      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      commit.gpgSign = true;
      tag.gpgSign = true;

      init.defaultBranch = "main";

      pull.rebase = "merges";
      push.autoSetupRemote = true;
      push.default = "current";

      fetch.prune = true;
      rebase.autoStash = true;
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";

      alias = {
        co = "checkout";
        st = "status -sb";
        lg = "log --oneline --graph --decorate --all";
        last = "log -1 HEAD --stat";
        amend = "commit --amend --no-edit";
      };
    };

    ignores = [
      ".DS_Store"
      ".direnv/"
      ".envrc"
      "*.swp"
      ".idea/"
      ".vscode/"
    ];
  };

  home.file.".config/git/allowed_signers".text =
    "gabriele.giambrone@icloud.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgxNlN1yRCUKFlQEaQ3M1VBqbxzt8BHiexI2xlKSjY7\n";
}
