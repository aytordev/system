{ pkgs, mkShell, ... }:

mkShell {
  packages = with pkgs; [
    nodejs_22
    yarn
    pnpm
  ];
  shellHook = ''
    echo -e "\n\033[1;32m🎯 Node.js 22 LTS Shell\033[0m"
    echo "Run 'node --version' to see the version"
    echo "Run 'yarn --version' to see the version"
    echo "Run 'pnpm --version' to see the version"
    echo "Run 'npm --version' to see the version"
  '';
}
