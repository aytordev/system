# Git aliases configuration
#
# This module defines a comprehensive set of Git aliases organized into
# logical categories for better maintainability and discoverability.
#
# Example usage:
#   programs.git.aliases = import ./aliases.nix { inherit lib; };
{ lib }:

with lib;

let
  # Helper function to create bash function aliases
  # Type: string -> string
  bashFunction = cmd: ''!f() { ${cmd}; }; f'';

  # Core aliases - Basic git commands
  coreAliases = {
    # Basic operations
    a = "add";
    ap = "add -p";
    c = "commit --verbose";
    co = "checkout";
    p = "push";
    s = "status -sb";
    st = "stash";
    stl = "stash list";
    d = "diff";
    ds = "diff --stat";
    dc = "diff --cached";
    rao = "remote add origin";
  };

  # Flow aliases - Git flow commands
  flowAliases = {
    # Commit operations
    ca = "commit -a --verbose";
    cam = "commit -a -m";
    ac = "!git add . && git commit -am";
    m = "commit --amend --verbose";
    
    # Branch operations
    cob = "checkout -b";
    com = "checkout main";
    cod = "checkout develop";
    
    # Rebase operations
    ria = "!git rebase -i $(git merge-base HEAD master)";
    rid = "!git rebase -i $(git merge-base HEAD develop)";
  };

  # Workflow aliases - Common workflows
  workflowAliases = {
    # Sync and cleanup
    up = "!git pull --rebase --prune $@ && git submodule update --init --recursive";
    
    # Push operations
    done = "!git push origin HEAD";
    mr = "push -u origin HEAD";
    pushitgood = "push -u origin --all";
    po = "!echo 'Ah push it' && git push origin && echo 'PUSH IT REAL GOOD'";
    
    # Save operations
    save = "!git add -A && git commit -m 'SAVEPOINT'";
    wip = "!git add -u && git commit -m 'WIP'";
    wipe = "!git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard";
    
    # Undo/reset operations
    undo = "reset HEAD~1 --mixed";
    res = "!git reset --hard";
    
    # Combined operations
    rdone = bashFunction ''git ac "$1" && git done'';
  };

  # Branch aliases - Branch management
  branchAliases = {
    # Branch delete operations
    brd = "!sh -c \"git checkout master && git branch --merged | grep -v '\\\\*' | xargs -n 1 git branch -d\"";
    brdhere = "!sh -c \"git branch --merged | grep -v '\\\\*' | xargs -n 1 git branch -d\"";
    
    # Branch display
    b = "rev-parse --abbrev-ref HEAD";
    
    # Branch sorting and listing
    lb = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
    lbr = "branch -vv";
  };

  # Log aliases - Viewing history
  logAliases = {
    # Pretty log formats
    l = "!git log --pretty=format:\"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate --date=short";
    lg = "!git log - -pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30";
    hist = "!git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    
    # Alias management
    la = "!git config -l | grep alias | cut -c 7-";
  };

  # Advanced workflow aliases - Complex commands
  advancedAliases = {
    # Fix corrupt git repo
    fix = bashFunction ''
      find .git/objects/ -type f -empty | xargs rm
      git fetch -p
      git fsck --full
    '';

    # Forced pull
    pullf = "!git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)";

    # Pull only the current branch
    pullhead = bashFunction ''
      local b="$1"
      if [ -z "$b" ]; then
        b=$(git rev-parse --abbrev-ref HEAD)
      fi
      git pull origin "$b"
    '';

    # Reset and repull branch
    smash = bashFunction ''
      local b="$1"
      if [ -z "$b" ]; then
        b=$(git rev-parse --abbrev-ref HEAD)
      fi
      echo "Are you sure you want to delete and recreate branch $b?"
      read -p "Enter to continue, ctrl-C to quit: " response
      git checkout master
      git branch -D "$b"
      git fetch origin "$b"
      git checkout "$b"
    '';

    # Rebase current branch off master
    rbm = bashFunction ''
      local b="$1"
      if [ -z "$b" ]; then
        b=$(git rev-parse --abbrev-ref HEAD)
      fi
      echo "Rebasing $b onto master..."
      read -p "Enter to continue, ctrl-C to quit: " response
      git checkout master
      git pull origin master
      git checkout "$b"
      git rebase master
    '';

    # Rebase current branch off develop
    rbd = bashFunction ''
      local b="$1"
      if [ -z "$b" ]; then
        b=$(git rev-parse --abbrev-ref HEAD)
      fi
      echo "Rebasing $b onto develop..."
      read -p "Enter to continue, ctrl-C to quit: " response
      git checkout develop
      git pull origin develop
      git checkout "$b"
      git rebase develop
    '';

    # Merge test
    mergetest = bashFunction ''
      git merge --no-commit --no-ff "$1"
      git merge --abort
      echo "Merge aborted"
    '';

    # Stash staged changes
    stash-staged = bashFunction ''
      staged=$(git diff --staged --unified=0)
      unstaged=$(git diff --unified=0)
      [ -z "$staged" ] && { echo "No staged changes to stash"; return 1; }
      [ -z "$unstaged" ] && { git stash "$@"; return $?; }
      
      echo "This is a potentially destructive command."
      echo "Be sure you understand it before running it."
      read -p "Continue? [y/N]: " cont
      echo "$cont" | grep -iq '^y' || { echo "Not continuing."; return 1; }
      
      git reset --hard
      echo "$staged" | git apply --unidiff-zero --allow-empty - && \
      git stash "$@" && \
      echo "$unstaged" | git apply --unidiff-zero --allow-empty - || {
        top=$(git rev-parse --git-dir)
        echo "$staged" >"$top/LAST_STAGED.diff"
        echo "$unstaged" >"$top/LAST_UNSTAGED.diff"
        echo "ERROR: Could not stash staged."
        echo "Diffs saved: try git apply --unidiff-zero .git/LAST_STAGED.diff .git/LAST_UNSTAGED.diff"
        return 1
      }
    '';

    # Stash unstaged changes
    stash-unstaged = bashFunction ''
      staged=$(git diff --staged --unified=0)
      unstaged=$(git diff --unified=0)
      [ -z "$staged" ] && { git stash "$@"; return $?; }
      [ -z "$unstaged" ] && { echo "No unstaged changes to stash"; return 1; }
      
      echo "This is a potentially destructive command."
      echo "Be sure you understand it before running it."
      read -p "Continue? [y/N]: " cont
      echo "$cont" | grep -iq '^y' || { echo "Not continuing."; return 1; }
      
      git reset --hard
      echo "$unstaged" | git apply --unidiff-zero - && \
      git stash "$@" && \
      echo "$staged" | git apply --unidiff-zero --allow-empty - || {
        top=$(git rev-parse --git-dir)
        echo "$staged" >"$top/LAST_STAGED.diff"
        echo "$unstaged" >"$top/LAST_UNSTAGED.diff"
        echo "ERROR: Could not stash unstaged."
        echo "Diffs saved: try git apply --unidiff-zero .git/LAST_STAGED.diff .git/LAST_UNSTAGED.diff"
        return 1
      }
    '';

    # Fetch pull request
    fetch-pr = bashFunction ''
      git remote get-url "$1" >/dev/null 2>&1 || { 
        echo "Usage: git fetch-pr <remote> [<pr-number>]" >&2
        return 1
      }
      if [ -z "$2" ]; then
        pr="*"
      else
        pr="$2"
      fi
      git fetch "$1" "+refs/pull/$pr/head:refs/remotes/$1/pr/$pr"
    '';

    # Random dad joke on typo
    dad = "!curl -s https://icanhazdadjoke.com/ && echo";
  };

in
# Combine all aliases into a single attribute set
lib.foldl' (acc: x: acc // x) {} [
  coreAliases
  flowAliases
  workflowAliases
  branchAliases
  logAliases
  advancedAliases
]