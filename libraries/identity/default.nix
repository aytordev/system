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
in {
  /**
  Normalize and validate the flat identity fields exported by the private flake.
  */
  fromSecrets = secrets: let
    identity = {
      username = requiredString secrets "username";
      email = requiredString secrets "useremail";
      fullName = requiredString secrets "userfullname";
    };
  in
    builtins.deepSeq identity identity;

  /**
  Require a structural home username to match the canonical private identity.
  */
  assertUsername = expected: actual:
    if actual == expected
    then actual
    else throw "home username '${actual}' does not match canonical identity '${expected}'";
}
