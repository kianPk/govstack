# Contributing

Thanks for helping improve GovStack.

## Development

```bash
forge install
forge test -vv
forge fmt
```

## Pull requests

1. Branch from `main`
2. Extend `GovStack.t.sol` for governance or treasury changes
3. Run `forge test` and `forge fmt` before submitting

## Style

- Solidity `0.8.24`, OpenZeppelin Governor / Timelock patterns
- Encode governance actions via `ProposalLib` helpers when possible
