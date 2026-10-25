# GovStack

**Full DAO stack** — `ERC20Votes` token, OpenZeppelin `Governor`, `TimelockController`, and a timelock-owned `Treasury`. Propose → vote → queue → execute.

[![CI](https://github.com/kianPk/govstack/actions/workflows/ci.yml/badge.svg)](https://github.com/kianPk/govstack/actions/workflows/ci.yml)
[![Demo](https://img.shields.io/badge/Demo-kianpk.github.io%2Fgovstack-10b981?style=for-the-badge)](https://kianpk.github.io/govstack/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?style=for-the-badge&logo=solidity)](https://github.com/kianPk/govstack)
[![Foundry](https://img.shields.io/badge/Foundry-forge-000000?style=for-the-badge)](https://book.getfoundry.sh/)

> Lab / portfolio governance — short delays for tests; retune for production.

## Architecture

```text
GovToken (ERC20Votes + Permit)
    │ votes
    ▼
GovGovernor ──queue/execute──▶ TimelockController ──owns──▶ Treasury
   │                              │
   │ 4% quorum · timestamp clock  └─ minDelay (1h in deploy script)
   └─ settings: 1m delay · 1h period
```

| Contract | Responsibility |
|----------|----------------|
| `GovToken` | Voting power, mint, permit |
| `GovGovernor` | Proposals, counting, quorum fraction |
| `TimelockController` | Delayed execution, role handoff |
| `Treasury` | ETH/ERC20 vault spent only by timelock |

## Quick start

```bash
forge install
forge test -vv
forge script script/Deploy.s.sol --rpc-url <RPC> --broadcast
```

## Also in this release

- **`Treasury.batchSpend`** — pay multiple ETH recipients in one timelock call (length-checked)
- `ProposalLib` helpers for ETH/token treasury grants
- Timestamp clock Governor + Timelock handoff

## Lifecycle (tested)

1. Delegate votes  
2. `propose` treasury spend  
3. Cast votes after voting delay  
4. `queue` into timelock  
5. `execute` after min delay → ETH leaves treasury  

## Stack

```text
Solidity 0.8.24 · Foundry · OpenZeppelin Governor / Timelock / ERC20Votes
```

## License

MIT © [kianPk](https://github.com/kianPk)
