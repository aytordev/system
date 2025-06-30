# Variables del sistema
# Este archivo reexporta las variables desde el directorio de secrets
{
  lib,
  inputs,
  ...
} @ args: {
  # Reexportar los valores relevantes
  username = inputs.secrets.username;
  userfullname = inputs.secrets.userfullname;
  useremail = inputs.secrets.useremail;
}
