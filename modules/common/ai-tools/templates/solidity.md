# Solidity Project

## Stack

- **Language:** Solidity ^0.8.x
- **Framework:** Foundry (forge, cast, anvil)
- **Package Manager:** forge install (git submodules)

## Style Rules

- Use `custom errors` over `require` strings for gas efficiency
- Prefer `immutable` and `constant` for values set at deploy time
- Use `internal` visibility by default; only expose what's needed
- Prefix internal/private functions with `_`
- Use NatSpec comments (`///` or `/** */`) on all public interfaces
- Emit events for all state-changing operations
- Use `unchecked` blocks only with explicit overflow justification

## File Conventions

- `PascalCase.sol` for contracts, `IPascalCase.sol` for interfaces
- `src/` for contracts, `test/` for tests, `script/` for deployment
- One primary contract per file

## Security Patterns

- Check-Effects-Interactions pattern for external calls
- Use `ReentrancyGuard` or equivalent for state-modifying external calls
- Validate all inputs at function entry (address(0), bounds, auth)
- Use OpenZeppelin libraries for standard patterns (ERC20, Access Control)
- Prefer pull-over-push for ETH transfers

## Testing

- Use `forge test` with `-vvv` for verbose traces on failure
- Write fuzz tests for arithmetic and boundary conditions
- Use `vm.prank` / `vm.startPrank` for access control tests
- Test revert conditions with `vm.expectRevert`
- Use `forge coverage` to identify untested paths

## AI Agent Notes

- Run `forge build` to compile and check for errors
- Run `forge test` before committing any contract changes
- Use `forge fmt` for formatting
- Check `foundry.toml` for project-specific configuration
- Use `cast` for on-chain interaction and debugging
- Review gas reports with `forge test --gas-report`
