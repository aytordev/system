{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  coreAliases = {
    g = "git";
    add = "git add";
    commit = "git commit";
    pull = "git pull";
    push = "git push";
    status = "git status";
    st = "git status -sb";
    d = "git diff";
    gdiff = "git diff HEAD";
    vdiff = "git difftool HEAD";
    cfg = "git --git-dir=$HOME/.config/.dotfiles/ --work-tree=$HOME";
  };
  addAliases = {
    ga = "git add";
    gau = "git add --update";
    gaa = "git add --all";
    gapa = "git add --patch";
    gav = "git add --verbose";
    gap = "git apply";
    gapt = "git apply --3way";
  };
  branchAliases = {
    gb = "git branch";
    gba = "git branch -a";
    gbd = "git branch -d";
    gbD = "git branch -D";
    gbm = "git branch -m";
    gbM = "git branch -M";
    gbnm = "git branch --no-merged";
    gbr = "git branch --remote";
    gbl = "git blame -b -w";
  };
  bisectAliases = {
    gbsb = "git bisect bad";
    gbsg = "git bisect good";
    gbsr = "git bisect reset";
    gbss = "git bisect start";
  };
  commitAliases = {
    gc = "git commit -v";
    gcm = "git commit -v -m";
    gca = "git commit -v --amend";
    gcam = "git commit -v --amend -m";
    gcan = "git commit -v --amend --no-edit";
  };
  checkoutAliases = {
    gcof = "git checkout --force";
  };
  cherryPickAliases = {
    gcp = "git cherry-pick";
    gcpx = "git cherry-pick -x";
    gcpa = "git cherry-pick --abort";
    gcpc = "git cherry-pick --continue";
  };
  diffAliases = {
    gd = "git diff";
    gdca = "git diff --cached";
    gdcw = "git diff --cached --word-diff";
    gdw = "git diff --unified=0 --word-diff=color";
    gdwn = "git diff --unified=0 --word-diff=color --no-index";
  };
  fetchAliases = {
    gf = "git fetch";
    gfa = "git fetch --all";
    gfap = "git fetch --all --prune";
    gfo = "git fetch origin";
  };
  logAliases = {
    gl = "git log";
    gla = "git log --all";
    glag = "git log --all --graph";
    glang = "git log --all --name-status --graph";
  };
  mergeAliases = {
    gm = "git merge";
    gmo = "git merge origin";
    gmu = "git merge upstream";
    gma = "git merge --abort";
    gmtl = "git mergetool --no-prompt";
    gmtlvim = "git mergetool --no-prompt --tool=vimdiff";
  };
  pullAliases = {
    gP = "git pull";
    gPo = "git pull origin";
    gPr = "git pull --rebase";
    gPn = "git pull --no-rebase";
    gPno = "git pull --no-rebase origin";
    gPdr = "git pull --dry-run";
    gPf = "git pull --force";
    gPff = "git pull --ff-only";
  };
  pushAliases = {
    gp = "git push";
    gpo = "git push origin";
    gpoa = "git push origin --all";
    gpu = "git push -u";
    gpuo = "git push -u origin";
    gpf = "git push --force";
    gpfo = "git push --force origin";
    gpfl = "git push --force-with-lease";
    gpflo = "git push --force-with-lease origin";
    gpd = "git push -d";
    gpdo = "git push -d origin";
    gpdr = "git push --dry-run";
  };
  rebaseAliases = {
    gr = "git rebase";
    gri = "git rebase -i";
    grb = "git rebase";
    grbi = "git rebase -i";
    gra = "git rebase --abort";
    grba = "git rebase --abort";
    grc = "git rebase --continue";
    grbc = "git rebase --continue";
    grs = "git rebase --skip";
    grbs = "git rebase --skip";
    grbm = "git rebase master";
    grbo = "git rebase --onto";
  };
  remoteAliases = {
    gr = "git remote";
    gra = "git remote add";
    grao = "git remote add origin";
    grau = "git remote add upstream";
    grr = "git remote rename";
    grrm = "git remote remove";
    grs = "git remote show";
    grset = "git remote set-url";
    grso = "git remote set-url origin";
    grv = "git remote -v";
    gru = "git remote update";
    grup = "git remote update --prune";
    grt = "cd $(git rev-parse --show-toplevel || echo \".\")";
  };
  resetAliases = {
    grs = "git reset --soft";
    grss = "git reset --soft HEAD^";
    grh = "git reset HEAD";
    grhh = "git reset HEAD --hard";
    grsh = "git reset --hard";
    grshh = "git reset --hard HEAD^";
    gR = "git reset";
    gRh = "git reset --hard";
    gRs = "git reset --soft";
    gpristine = "git reset --hard && git clean -dffx";
  };
  removeAliases = {
    grm = "git rm";
    grmc = "git rm --cached";
    grmcf = "git rm --cached -f";
    grmcr = "git rm --cached -r";
    grmcrf = "git rm --cached -rf";
  };
  restoreAliases = {
    grst = "git restore";
    grsts = "git restore --source";
    grstS = "git restore --staged";
    grs = "git restore";
    grsc = "git restore --cached";
    grss = "git restore --source";
  };
  statusAliases = {
    gs = "git status";
    gss = "git status -s";
    gsb = "git status -sb";
    gsh = "git show";
    gsps = "git show --pretty=short --show-signature";
  };
  stashAliases = {
    gS = "git stash";
    gSd = "git stash drop";
    gSl = "git stash list";
    gSs = "git stash show";
    gSa = "git stash apply";
    gSp = "git stash pop";
    gSc = "git stash clear";
    gSall = "git stash --all";
    gSmsg = "git stash push -m";
  };
  otherAliases = {
    gcl = "git clone";
    gi = "git init";
    gclean = "git clean -id";
    ghh = "git help";
    gignore = "git update-index --assume-unchanged";
    gunignore = "git update-index --no-assume-unchanged";
    gignored = "git ls-files -v | grep '^[[:lower:]]'";
    grev = "git revert";
  };
  linuxAliases = lib.optionalAttrs pkgs.stdenv.isLinux {
    gk = "gitk --all";
    gka = "gitk --all --date-order";
    gkar = "gitk --all --date-order --remotes";
    gkas = "gitk --all --date-order --since=\"2 weeks ago\"";
  };
  githubCliAliases = {
    ghrc = "gh repo clone";
    ghrl = "gh repo list";
    ghrv = "gh repo view";
    ghri = "gh repo info";
    ghrs = "gh repo status";
    ghrf = "gh repo fork";
    ghrr = "gh repo rename";
    ghprc = "gh pr create";
    ghprl = "gh pr list";
    ghprv = "gh pr view";
    ghprco = "gh pr checkout";
    ghprm = "gh pr merge";
    ghprd = "gh pr diff";
  };
in {
  # Combine all aliases into a single attribute set
  allAliases = lib.foldl' (acc: x: acc // x) {} [
    coreAliases
    addAliases
    branchAliases
    bisectAliases
    commitAliases
    checkoutAliases
    cherryPickAliases
    diffAliases
    fetchAliases
    logAliases
    mergeAliases
    pullAliases
    pushAliases
    rebaseAliases
    remoteAliases
    resetAliases
    removeAliases
    restoreAliases
    statusAliases
    stashAliases
    otherAliases
    githubCliAliases
    linuxAliases
  ];

  # Generate the content for the git aliases file
  generateGitAliasesFile = aliases: ''
    # Git aliases for Bash
    # This file is automatically generated by the git module
    # Do not edit this file directly as it will be overwritten

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "alias ${name}='${value}'") aliases)}
  '';
}
