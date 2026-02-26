## Variable Naming

**Impact:** MEDIUM

Use `camelCase` for standard variables and `UPPER_CASE` for constants.

**Incorrect (Mixed styles):**

```nix
let
  user_name = "aytordev";
  UserName = "Aytor Dev";
  enable_auto_start = true;
  MAX_retries = 5;
in
{
  # Inconsistent naming makes code harder to read
}
```

**Correct (camelCase):**

```nix
let
  userName = "aytordev";
  fullName = "Aytor Dev";
  enableAutoStart = true;
  MAX_RETRIES = 5;
  DEFAULT_PORT = 8080;
in
{
  # Clear distinction between variables and constants
  services.myapp = {
    user = userName;
    autoStart = enableAutoStart;
    maxRetries = MAX_RETRIES;
    port = DEFAULT_PORT;
  };
}
```
