# Git ignore patterns
# Returns a list of gitignore patterns to be used in the git configuration
# Base ignore patterns
[
  # Common temporary files
  "*~"
  "*.swp"
  "*.swo"
  "*."
  "*.bak"
  "*.backup"
  "*.tmp"
  "*.temp"

  # System files
  ".DS_Store"
  ".DS_Store?"
  "Thumbs.db"
  "ehthumbs.db"
  "Desktop.ini"
  "$RECYCLE.BIN/"
  "*.stackdump"

  # Build artifacts and logs
  "*.o"
  "*.pyc"
  "*.pyo"
  "*.pyd"
  "*.so"
  "*.dll"
  "*.dylib"

  # Environment and package directories
  ".direnv/"
  ".env"
  ".venv"
  "env/"
  "venv/"
  "ENV/"
  "dist/"
  "build/"
  "*.egg-info/"
  "__pycache__/"

  # IDE/Editor files
  ".vscode/"
  "!.vscode/extensions.json"
  "!.vscode/*.code-snippets"
  ".idea/"
  ".idea_modules/"
  "*.sublime-*"
  ".vs/"
  ".atom/"
  ".vscode-oss/"
  "*.kdev4"
  ".kdev4/"
  "*.kdev4.*"

  # Version control
  ".git/"
  ".gitattributes"
  ".gitconfig"
  ".gitignore"
  ".gitmodules"
  ".gitkeep"
  ".git-rewrite/"

  # Language specific
  # Nix
  "result/"
  "result-*/"
  "shell.nix"

  # Node.js
  "node_modules/"
  "npm-debug.log*"
  "yarn-debug.log*"
  "yarn-error.log*"
  ".pnp.*"
  ".yarn/"
  "!.yarn/patches"
  "!.yarn/plugins"
  "!.yarn/releases"
  "!.yarn/sdks"
  "!.yarn/versions"

  # Logs and databases
  "*.log"
  "logs/"
  "*.sqlite"
  "*.sqlite3"
  "*.db"

  # Project specific
  ".env.local"
  ".env.development"
  ".env.test"
  ".env.production"
  ".env.*.local"
]
