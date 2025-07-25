{pkgs, ...}: {
  name = "node-24";
  description = "Node.js 24 shell";
  packages = with pkgs; [
    nodejs_24
    yarn
    pnpm
  ];
  shellHook = ''
    echo -e "\n\033[1;32m🎯 Node.js 24 Shell\033[0m"
    echo "Run 'node --version' to see the version"
    echo "Run 'yarn --version' to see the version"
    echo "Run 'pnpm --version' to see the version"
    echo "Run 'npm --version' to see the version"
  '';
}
