_: let
  requiredString = secrets: name:
    if !builtins.isAttrs secrets
    then throw "secrets input must be an attribute set"
    else if !builtins.hasAttr name secrets
    then throw "secrets input is missing required identity field '${name}'"
    else let
      value = builtins.getAttr name secrets;
    in
      if !builtins.isString value || value == ""
      then throw "secrets identity field '${name}' must be a non-empty string"
      else value;

  normalize = identity: builtins.deepSeq identity identity;

  /**
  Normalize and validate the flat owner identity fields exported by the private
  flake.
  */
  fromSecrets = secrets: let
    identity = {
      username = requiredString secrets "username";
      email = requiredString secrets "useremail";
      fullName = requiredString secrets "userfullname";
    };
  in
    normalize identity;

  /**
  Resolve a per-user identity from the private flake's `users` map. Falls back
  to the flat owner identity when the requested user IS the owner, so the owner
  does not need to be duplicated in the map.
  */
  fromSecretsFor = username: secrets:
    if builtins.isAttrs (secrets.users or null) && builtins.hasAttr username secrets.users
    then let
      user = secrets.users.${username};
      identity = {
        username = requiredString user "username";
        email = requiredString user "useremail";
        fullName = requiredString user "userfullname";
      };
    in
      normalize identity
    else if (secrets.username or "") == username
    then fromSecrets secrets
    else throw "unknown user '${username}'; add a 'users.${username}' identity to the secrets flake";

  /**
  Require a structural home username to match the canonical private identity.
  */
  assertUsername = expected: actual:
    if actual == expected
    then actual
    else throw "home username '${actual}' does not match canonical identity '${expected}'";
in {
  inherit fromSecrets fromSecretsFor assertUsername;
}
