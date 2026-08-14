{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = inputs.secrets.username;
  home = inputs.self.homeConfigurations."${username}@wang-lin".config;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  integratedHome = darwin.config.home-manager.users.${username};

  getKnownHosts = config: lib.attrByPath ["home" "file" ".ssh/known_hosts.d/aytordev" "text"] "" config;
  standaloneKnownHosts = getKnownHosts home;
  integratedKnownHosts = getKnownHosts integratedHome;
  knownHostsFile = pkgs.writeText "aytordev-known-hosts" standaloneKnownHosts;
  sshConfig = home.home.file.".ssh/config".text;
  integratedSshConfig = integratedHome.home.file.".ssh/config".text;
  trustedHosts = [
    "github.com"
    "gitlab.com"
    "git.sr.ht"
    "aarch64-build-box.nix-community.org"
    "darwin-build-box.nix-community.org"
    "build-box.nix-community.org"
    "wang-lin.local"
  ];
  systemSshOption = [
    "aytordev"
    "programs"
    "terminal"
    "tools"
    "ssh"
  ];
  tests = [
    (standaloneKnownHosts == integratedKnownHosts)
    (sshConfig == integratedSshConfig)
    (builtins.all (host: lib.hasInfix host standaloneKnownHosts) trustedHosts)
    (!lib.hasInfix "C+C+C+C" standaloneKnownHosts)
    (lib.hasInfix "StrictHostKeyChecking accept-new" sshConfig)
    (lib.hasInfix "ForwardAgent no" sshConfig)
    (lib.hasInfix ".ssh/ssh_key_github_ed25519" sshConfig)
    (lib.hasInfix ".ssh/portfolio_hetzner_ed25519" sshConfig)
    (!lib.hasAttrByPath systemSshOption darwin.options)
    darwin.config.services.openssh.enable
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-ssh-tests" {} ''
      test "$(${pkgs.coreutils}/bin/wc -l < ${knownHostsFile})" -eq 10
      ${pkgs.openssh}/bin/ssh-keygen -l -f ${knownHostsFile} >/dev/null
      touch "$out"
    ''
