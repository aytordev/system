## Theme Hierarchy

**Impact:** CRITICAL

Understand the priority of theme configurations. Manual configuration always wins, followed by Catppuccin modules (if enabled), and finally Stylix defaults as the base.

**Incorrect:**

**Mixing Priorities without Intent**
Relying on Stylix for everything while manually hacking specific colors in random places, leading to inconsistent states.

**Correct:**

**Strict Hierarchy**

1.  **Manual theme config**: Explicit per-module settings (Highest Priority).
2.  **Catppuccin modules**: Catppuccin-specific integration (Medium Priority).
3.  **Stylix**: Base16 theming system (Lowest Priority / Default).

_Principle_: Prefer specific theme module customizations over Stylix defaults. Only drop to Stylix when no specific integration exists.
