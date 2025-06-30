# Git Shell Aliases Configuration
#
# This module defines shell aliases for Git commands, organized into logical
# categories for better maintainability and discoverability. Each alias is
# prefixed with 'g' for Git commands to avoid conflicts with system commands.
#
# Types:
#   shellAliases :: { string = string; }
#
# Example usage:
#   programs.bash.shellAliases = import ./shell-aliases.nix { inherit config lib pkgs; };
#
# Maintainers:
#   - System Infrastructure Team <infra@example.com>
#
# Last Updated: 2025-07-01
#
# Notes:
#   - All aliases are prefixed with 'g' to avoid conflicts with system commands
#   - Aliases are grouped by functionality for better organization
#   - Each group is documented with its purpose and type signature
{ config, lib, pkgs, ... }:

with lib;

let
  # Core Git commands - Basic Git operations
  #
  # These are the most commonly used Git commands with minimal options.
  #
  # Type: AttrSetOf string
  #   An attribute set where each key is an alias and each value is the Git command it represents
  coreAliases = {
    # Basic operations
    #
    # Short aliases for common Git commands
    g = "git";                   # Shorthand for 'git'
    add = "git add";             # Stage changes
    commit = "git commit";       # Create a new commit
    pull = "git pull";           # Fetch and merge changes
    push = "git push";           # Push changes to remote
    status = "git status";       # Show working tree status
    st = "git status -sb";       # Short branch status
    d = "git diff";              # Show changes between commits/staging
    gdiff = "git diff HEAD";     # Show unstaged changes
    vdiff = "git difftool HEAD"; # Visual diff tool for changes
    
    # Dotfiles management
    #
    # Special alias for managing dotfiles repository
    # Uses a separate Git directory and work tree
    #
    # Example:
    #   $ cfg status  # Check status of dotfiles
    #   $ cfg add .config/nixpkgs  # Stage changes to nixpkgs config
    cfg = "git --git-dir=$HOME/.config/.dotfiles/ --work-tree=$HOME";
  };

  # Add/Stage operations
  #
  # Aliases for staging changes with various options.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git command with specific add/apply options
  addAliases = {
    # Stage specific files or directories
    ga = "git add";            # Add file contents to the index
    gau = "git add --update";  # Only match tracked files
    gaa = "git add --all";     # Add all files (tracked and untracked)
    gapa = "git add --patch";  # Interactive patch selection
    gav = "git add --verbose"; # Show verbose output during add
    
    # Apply patch operations
    gap = "git apply";         # Apply a patch to files and/or to the index
    gapt = "git apply --3way"; # Apply patch with 3-way merge if needed
  };

  # Branch operations
  #
  # Aliases for working with Git branches and examining line-by-line revision
  # and author information.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git command with branch or blame options
  branchAliases = {
    # Branch management
    gb = "git branch";           # List local branches
    gba = "git branch -a";       # List all branches (local and remote)
    gbd = "git branch -d";       # Delete a branch (safe, prevents deletion of unmerged changes)
    gbD = "git branch -D";       # Force delete a branch (even with unmerged changes)
    gbm = "git branch -m";       # Rename current branch (old name)
    gbM = "git branch -M";       # Force rename current branch (even if target exists)
    gbnm = "git branch --no-merged"; # List branches not yet merged into current
    gbr = "git branch --remote"; # List remote-tracking branches
    
    # Blame operations
    #
    # Show what revision and author last modified each line of a file
    # Options:
    #   -b: Show blank SHA-1 for boundary commits
    #   -w: Ignore whitespace when comparing
    gbl = "git blame -b -w";
  };

  # Bisect operations
  #
  # Aliases for binary search through commit history to find bugs.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git bisect subcommand with arguments
  bisectAliases = {
    # Mark the current commit as bad (contains the bug)
    gbsb = "git bisect bad";
    # Mark the current commit as good (doesn't contain the bug)
    gbsg = "git bisect good";
    # Reset bisect state and return to original branch
    gbsr = "git bisect reset";
    # Start a new bisect session
    gbss = "git bisect start";
  };

  # Commit operations
  #
  # Aliases for creating and modifying commits with various options.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git commit command with specific options
  commitAliases = {
    # Create commits with various options
    gc = "git commit -v";              # Commit with verbose diff output
    gcm = "git commit -v -m";          # Commit with inline message
    gca = "git commit -v --amend";     # Amend the last commit
    gcam = "git commit -v --amend -m"; # Amend with new message
    gcan = "git commit -v --amend --no-edit"; # Amend without editing message
  };

  # Checkout operations
  #
  # Aliases for switching between branches and restoring working tree files.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git checkout command with specific options
  checkoutAliases = {
    # Force checkout, discarding local changes
    # Use with caution as this will overwrite uncommitted changes
    gcof = "git checkout --force";
  };

  # Cherry-pick operations
  #
  # Aliases for applying specific commits from one branch onto another.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git cherry-pick command with specific options
  cherryPickAliases = {
    # Basic cherry-pick operations
    gcp = "git cherry-pick";       # Apply the changes introduced by some existing commits
    gcpx = "git cherry-pick -x";   # Append a line that says "(cherry picked from commit...)"
    
    # Cherry-pick control operations
    gcpa = "git cherry-pick --abort";    # Cancel the operation and return to the pre-sequence state
    gcpc = "git cherry-pick --continue"; # Continue the operation in progress
  };

  # Diff operations
  #
  # Aliases for viewing changes between commits, commit and working tree, etc.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git diff command with specific options
  diffAliases = {
    # Basic diff operations
    gd = "git diff";           # Show changes between working directory and index
    gdca = "git diff --cached"; # Show changes staged for commit
    
    # Word-level diff operations
    gdcw = "git diff --cached --word-diff";  # Word diff for staged changes
    gdw = "git diff --unified=0 --word-diff=color";  # Colored word diff without context
    
    # Special diff cases
    gdwn = "git diff --unified=0 --word-diff=color --no-index";  # Diff files on disk
  };

  # Fetch operations
  #
  # Aliases for downloading objects and refs from remote repositories.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git fetch command with specific options
  fetchAliases = {
    # Basic fetch operations
    gf = "git fetch";           # Download objects and refs from default remote
    gfa = "git fetch --all";    # Fetch all remotes
    
    # Fetch with cleanup
    gfap = "git fetch --all --prune";  # Remove remote-tracking references that no longer exist
    
    # Remote-specific operations
    gfo = "git fetch origin";   # Fetch from specific remote (origin)
  };

  # Log operations
  #
  # Aliases for viewing commit history with various formatting options.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git log command with specific formatting options
  logAliases = {
    # Basic log views
    gl = "git log";                    # Show commit logs
    gla = "git log --all";             # Show all commits from all branches
    
    # Graph-based log views
    glag = "git log --all --graph";    # ASCII graph of commit history
    glang = "git log --all --name-status --graph";  # Graph with changed files
  };

  # Merge operations
  #
  # Aliases for combining changes from different branches and resolving conflicts.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git merge/mergetool command with specific options
  mergeAliases = {
    # Basic merge operations
    gm = "git merge";              # Merge another branch into current branch
    gmo = "git merge origin";      # Merge from origin branch
    gmu = "git merge upstream";    # Merge from upstream branch
    gma = "git merge --abort";     # Abort the current merge process
    
    # Merge conflict resolution
    gmtl = "git mergetool --no-prompt";           # Launch merge resolution tool
    gmtlvim = "git mergetool --no-prompt --tool=vimdiff";  # Use vimdiff for merging
  };

  # Pull operations
  #
  # Aliases for fetching and integrating changes from remote repositories.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git pull command with specific options
  pullAliases = {
    # Basic pull operations
    gP = "git pull";             # Fetch and merge changes from default remote
    gPo = "git pull origin";     # Pull from specific remote (origin)
    
    # Pull with rebase options
    gPr = "git pull --rebase";   # Rebase local changes on top of remote changes
    gPn = "git pull --no-rebase"; # Explicitly disable rebase
    gPno = "git pull --no-rebase origin"; # Pull without rebase from origin
    
    # Special pull cases
    gPdr = "git pull --dry-run";  # Show what would be done without making changes
    gPf = "git pull --force";     # Force fetch and merge
    gPff = "git pull --ff-only";  # Fast-forward only, fail if not possible
  };

  # Push operations
  #
  # Aliases for updating remote refs and associated objects.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git push command with specific options
  pushAliases = {
    # Basic push operations
    gp = "git push";                 # Push changes to default remote
    gpo = "git push origin";         # Push to specific remote (origin)
    gpoa = "git push origin --all";  # Push all branches to origin
    
    # Push with tracking
    gpu = "git push -u";             # Set upstream for current branch
    gpuo = "git push -u origin";     # Set upstream to origin for current branch
    
    # Force push operations
    gpf = "git push --force";        # Force push (use with caution)
    gpfo = "git push --force origin"; # Force push to origin
    
    # Safer force push options
    gpfl = "git push --force-with-lease";        # Only overwrite if remote hasn't changed
    gpflo = "git push --force-with-lease origin"; # Same as above, specific to origin
    
    # Push with delete
    gpd = "git push -d";             # Delete remote branch
    gpdo = "git push -d origin";      # Delete branch on origin
    
    # Dry run
    gpdr = "git push --dry-run";      # Show what would be pushed without making changes
  };

  # Rebase operations
  #
  # Aliases for re-applying commits on top of another base tip.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git rebase command with specific options
  rebaseAliases = {
    # Basic rebase commands
    gr = "git rebase";           # Rebase current branch onto another branch
    gri = "git rebase -i";       # Interactive rebase (reword, edit, squash, etc.)
    grb = "git rebase";          # Alias for consistency with other commands
    grbi = "git rebase -i";      # Interactive rebase (alternative alias)
    
    # Rebase control operations
    gra = "git rebase --abort";  # Abort a rebase in progress
    grba = "git rebase --abort"; # Alternative abort alias
    grc = "git rebase --continue"; # Continue a rebase after resolving conflicts
    grbc = "git rebase --continue"; # Alternative continue alias
    grs = "git rebase --skip";   # Skip the current patch
    grbs = "git rebase --skip";  # Alternative skip alias
    
    # Rebase onto specific branch
    grbm = "git rebase master";  # Rebase current branch onto master
    grbo = "git rebase --onto";  # Rebase using specific base and new base
  };

  # Remote operations
  #
  # Aliases for managing remote repositories and their refs.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git remote command with specific options
  remoteAliases = {
    # Basic remote operations
    gr = "git remote";           # Show remote repositories
    gra = "git remote add";      # Add a new remote repository
    grao = "git remote add origin"; # Add origin as a remote repository
    grau = "git remote add upstream"; # Add upstream as a remote repository
    
    # Remote management operations
    grr = "git remote rename";   # Rename a remote repository
    grrm = "git remote remove";  # Remove a remote repository
    grs = "git remote show";     # Show information about a remote
    grset = "git remote set-url"; # Change URL of a remote
    grso = "git remote set-url origin"; # Set URL for origin remote
    
    # Remote inspection
    grv = "git remote -v";       # Show remote repositories with their URLs
    
    # Remote synchronization
    gru = "git remote update";   # Fetch updates from all remotes
    grup = "git remote update --prune"; # Update and prune outdated remote-tracking branches
    
    # Working directory navigation
    grt = "cd $(git rev-parse --show-toplevel || echo \".\")";  # Go to git root directory
    
  };

  # Reset operations
  #
  # Aliases for resetting current HEAD to a specified state.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git reset command with specific options
  resetAliases = {
    # Soft reset (preserves changes in working directory and index)
    grs = "git reset --soft";        # Reset to specific commit, keep changes staged
    grss = "git reset --soft HEAD^";  # Reset to previous commit, keep changes staged
    
    # Mixed reset (default, preserves changes in working directory only)
    grh = "git reset HEAD";          # Unstage all changes (reset index to HEAD)
    grhh = "git reset HEAD --hard";   # Discard all changes (use with caution)
    
    # Hard reset (discards all changes)
    grsh = "git reset --hard";       # Reset working directory to specific commit
    grshh = "git reset --hard HEAD^"; # Reset to previous commit, discard all changes
    gR = "git reset";                # Generic reset command
    gRh = "git reset --hard";         # Hard reset (discard all changes)
    gRs = "git reset --soft";         # Soft reset (keep changes staged)
    gpristine = "git reset --hard && git clean -dffx";  # Completely reset working directory
  };

  # Remove operations
  removeAliases = {
    grm = "git rm";
    grmc = "git rm --cached";
    grmcf = "git rm --cached -f";
    grmcr = "git rm --cached -r";
    grmcrf = "git rm --cached -rf";
  };

  # Restore operations
  #
  # Aliases for restoring working tree files to a previous state.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git restore command with specific options
  restoreAliases = {
    # Basic restore operations
    grst = "git restore";            # Restore working tree files
    grsts = "git restore --source";   # Restore from a specific commit
    grstS = "git restore --staged";   # Unstage changes (restore index)
    
    # Alternative aliases for compatibility
    grs = "git restore";             # Alias for grst
    grsc = "git restore --cached";    # Alias for grstS (deprecated)
    grss = "git restore --source";    # Alias for grsts
  };

  # Status operations
  #
  # Aliases for displaying the state of the working directory and staging area.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git status or show command with specific options
  statusAliases = {
    # Status commands
    gs = "git status";           # Show the working tree status
    gss = "git status -s";       # Short format status
    gsb = "git status -sb";      # Short format with branch information
    
    # Show commands
    gsh = "git show";            # Show various types of objects (commits, tags, etc.)
    gsps = "git show --pretty=short --show-signature";  # Show commit with signature
  };

  # Stash operations
  #
  # Aliases for stashing changes in a dirty working directory.
  # Stashing is useful when you need to switch branches but aren't ready to commit.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git stash command with specific options
  stashAliases = {
    # Basic stash operations
    gS = "git stash";               # Stash changes in working directory
    gSd = "git stash drop";         # Remove a single stashed state
    gSl = "git stash list";         # List all stashed changesets
    gSs = "git stash show";         # Show changes in the most recent stash
    gSa = "git stash apply";        # Apply stashed changes without removing
    gSp = "git stash pop";          # Apply and remove from stash
    gSc = "git stash clear";        # Remove all stashed states
    gSall = "git stash --all";      # Stash all changes, including untracked files
    gSmsg = "git stash push -m";    # Stash with a custom message
  };

  # Other operations
  #
  # Miscellaneous Git operations that don't fit into other categories.
  # These aliases provide shortcuts for various Git commands and options.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git command with specific options
  otherAliases = {
    # Repository operations
    gcl = "git clone";           # Clone a repository into a new directory
    gi = "git init";             # Create an empty Git repository
    
    # Cleanup operations
    gclean = "git clean -id";    # Interactive cleaning of untracked files
    
    # Help and documentation
    ghh = "git help";            # Display help information about Git
    
    # File tracking operations
    gignore = "git update-index --assume-unchanged";    # Ignore changes to a tracked file
    gunignore = "git update-index --no-assume-unchanged"; # Stop ignoring changes to a file
    gignored = "git ls-files -v | grep '^[[:lower:]]'";  # List ignored files
    
    # History modification
    grev = "git revert";         # Revert existing commits
  };

  # Platform-specific aliases (Linux)
  #
  # Git GUI aliases that are specific to Linux systems.
  # These aliases are only available when building on Linux.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: Git command with specific options
  linuxAliases = lib.optionalAttrs pkgs.stdenv.isLinux {
    # Gitk (Git repository browser) aliases
    gk = "gitk --all";                     # Launch gitk with all branches
    gka = "gitk --all --date-order";       # Show all branches in date order
    gkar = "gitk --all --date-order --remotes";  # Show all branches including remotes
    gkas = "gitk --all --date-order --since=\"2 weeks ago\"";  # Show recent changes
  };

  # GitHub CLI aliases (conditional)
  #
  # Aliases for GitHub CLI (gh) commands, only enabled when GitHub CLI is configured.
  # These provide convenient shortcuts for common GitHub repository and pull request operations.
  #
  # Type: AttrSetOf string
  #   Key: Short alias name
  #   Value: GitHub CLI command with specific options
  githubCliAliases = lib.mkIf config.programs.gh.enable {
    # Repository operations
    ghrc = "gh repo clone";     # Clone a GitHub repository
    ghrl = "gh repo list";      # List repositories owned by user or organization
    ghrv = "gh repo view";      # View a GitHub repository in the browser
    ghri = "gh repo info";      # Show information about a GitHub repository
    ghrs = "gh repo status";    # Show repository status
    ghrf = "gh repo fork";      # Create a fork of a repository
    ghrr = "gh repo rename";    # Rename a repository
    
    # Pull request operations
    ghprc = "gh pr create";     # Create a pull request
    ghprl = "gh pr list";       # List pull requests in a repository
    ghprv = "gh pr view";       # View a pull request
    ghprco = "gh pr checkout";  # Check out a pull request locally
    ghprm = "gh pr merge";      # Merge a pull request
    ghprd = "gh pr diff";       # View changes in a pull request
  };

in {
  # Combine all aliases into a single attribute set
  #
  # This merges all the individual alias sets into one comprehensive set of Git aliases.
  # The order is important: later entries will override earlier ones with the same key.
  #
  # Type: AttrSetOf string
  #   A flat attribute set where each key is an alias and each value is the Git command it represents
  shellAliases = lib.foldl' (acc: x: acc // x) {} [
    coreAliases           # Basic Git commands
    addAliases            # Add/stage operations
    branchAliases         # Branch management
    bisectAliases         # Binary search for bugs
    commitAliases         # Commit operations
    checkoutAliases       # Checkout operations
    cherryPickAliases     # Apply specific commits
    diffAliases           # View changes
    fetchAliases          # Download objects/refs
    logAliases            # View commit history
    mergeAliases          # Merge branches
    pullAliases           # Fetch and merge
    pushAliases           # Update remote refs
    rebaseAliases         # Reapply commits
    remoteAliases         # Manage remotes
    resetAliases          # Reset current HEAD
    removeAliases         # Remove files
    restoreAliases        # Restore working tree files
    statusAliases         # Show working tree status
    stashAliases          # Stash changes
    otherAliases          # Miscellaneous commands
    githubCliAliases      # GitHub CLI integration
    linuxAliases          # Linux-specific aliases
  ];
}