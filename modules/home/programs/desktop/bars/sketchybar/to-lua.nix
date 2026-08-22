{lib}: let
  toLua = value:
    if value == null
    then "nil"
    else if builtins.isString value
    then builtins.toJSON value
    else if builtins.isBool value
    then
      if value
      then "true"
      else "false"
    else if builtins.isInt value || builtins.typeOf value == "float"
    then toString value
    else if builtins.isList value
    then "{${lib.concatMapStringsSep ", " toLua value}}"
    else if builtins.isAttrs value
    then "{\n${
      lib.concatStringsSep ",\n" (
        lib.mapAttrsToList (name: item: "[${toLua name}] = ${toLua item}") value
      )
    }\n}"
    else throw "Cannot serialize ${builtins.typeOf value} to Lua";
in
  toLua
