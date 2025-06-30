# System Variables
# This file re-exports variables from the secrets directory
# These variables are used throughout the system configuration

{
  lib,
  inputs,
  ...
} @ args: {
  # User information from secrets
  username = inputs.secrets.username;    # System username
  userfullname = inputs.secrets.userfullname;  # User's full name
  useremail = inputs.secrets.useremail;  # User's email address
}
