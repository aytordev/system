# Variables imported from secrets
{ lib, inputs, ... }@args: 
let
  # Import secrets with lib available
  secrets = import inputs.secrets { inherit lib; };
in {
  # Expose the secrets
  inherit (secrets.soft-secrets.personal) username userfullname useremail;
}