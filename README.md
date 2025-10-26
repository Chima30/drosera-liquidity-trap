# LiquidityTrap (Drosera Proof-of-Concept)

## Overview
LiquidityTrap is a Drosera Proof-of-Concept (PoC) that monitors on-chain liquidity for a specific DEX token pair. Its goal is to detect unusually low reserves in the liquidity pool, which could indicate potential rug pulls or abnormal token activity. This trap demonstrates how Drosera operators can automatically monitor DeFi protocols in a decentralized and deterministic manner.

**Trap Config Address:** `0x4568a9b8ee9ab52272b8b9d616a071ab14fd4c0a`  
**Creator Address:** `0xa3d7f5e1191941de22778a550f0ca4e2497cb7c8`  
**Response Contract Address:** `0x09C6c345B1bBE743E62A34A2094664C69abbA78E`  

---

## What It Does
* Monitors the liquidity of the PAIR token at `0xf80489C1439b6aCcA9FC25B95954ae59Ad69f942`.
* Triggers a response if the reserves fall below a critical threshold:
  - `r0 < 100 ETH`
  - `r1 < 100,000 USDC`
* Demonstrates the Drosera trap pattern using deterministic logic that separates monitoring from action.

---

## Key Files

* `src/LiquidityTrap.sol` - The core trap contract containing the monitoring logic.
* `src/SimpleResponder.sol` - The external Responder contract that executes actions when the trap triggers.
* `drosera.toml` - The configuration file defining trap parameters, cooldown periods, operator requirements, and whitelist.
* `foundry.toml` - Foundry configuration with remappings, compiler settings, and output directories.

---

## Solidity Contracts

### `SimpleResponder.sol`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleResponder {
    function respondCallback(uint256 amount) public {
        // PoC: The Trap triggered, the Responder was called.
    }
}
```
## LiquidityTrap.sol
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "contracts/interfaces/ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32);
}

contract LiquidityTrap is ITrap {
    address public constant PAIR = 0xf80489C1439b6aCcA9FC25B95954ae59Ad69f942;

    function name() external pure override returns (string memory) {
        return "LiquidityTrap";
    }

    function collect() external view override returns (bytes memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(PAIR);
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        return abi.encode(r0, r1);
    }

    function shouldRespond(bytes calldata data) external pure override returns (bool, bytes memory) {
        (uint112 r0, uint112 r1) = abi.decode(data, (uint112, uint112));
        bool low = (r0 < 100 ether || r1 < 100_000 * 10**6);
        return (low, data);
    }
}
```
## drosera.toml Configuration
```
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]

[traps.liquidity_trap]
path = "out/LiquidityTrap.sol/LiquidityTrap.json"
response_contract = "0x09C6c345B1bBE743E62A34A2094664C69abbA78E"
response_function = "respondCallback(uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = true
whitelist = ["0xa3d7f5e1191941de22778a550f0ca4e2497cb7c8"]
```
## How It Works
Detection Logic

The trap reads the liquidity pool reserves from the DEX pair and determines if the trap should trigger:
```solidity
function shouldRespond(bytes calldata data) external pure override returns (bool, bytes memory) {
    (uint112 r0, uint112 r1) = abi.decode(data, (uint112, uint112));
    bool low = (r0 < 100 ether || r1 < 100_000 * 10**6);
    return (low, data);
}
```
1. r0 → Reserve of token 0 (ETH)

2. r1 → Reserve of token 1 (USDC)

3. Returns true if either reserve falls below the threshold.

## Operator Execution

1. Operators read the collect() output.

2. Deterministic evaluation of shouldRespond() is performed off-chain.

3. If the trap triggers, the Responder contract is called automatically.

## Deployment Steps

1. Deploy SimpleResponder.sol first and capture the address (0x09C6c345B1bBE743E62A34A2094664C69abbA78E).

2. Update drosera.toml with the deployed Responder address and whitelist your wallet.

3. Build the Trap Contract using Foundry:
```bash
forge build
```
4. ## Deploy the Trap:
```bash
forge create src/LiquidityTrap.sol:LiquidityTrap \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key YOUR_FUNDED_PRIVATE_KEY \
  --broadcast
```

5. ## Register Operators:
```bash
drosera-operator register \
  --eth-rpc-url https://rpc.hoodi.ethpandaops.io \
  --eth-private-key YOUR_OPERATOR_PRIVATE_KEY \
  --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
```

6. ## Opt-in Operators:
```bash
drosera-operator optin \
  --eth-rpc-url https://rpc.hoodi.ethpandaops.io \
  --eth-private-key YOUR_OPERATOR_PRIVATE_KEY \
  --trap-config-address 0x4568a9b8ee9ab52272b8b9d616a071ab14fd4c0a
```

7. ## Run Drosera Node in Docker:
```bash
docker compose up -d
docker logs -f drosera-node
```

8. ## Restart operator service if needed:
```bash
docker compose restart drosera-operator
```
## Testing
To test the LiquidityTrap contract with Foundry:
```bash
forge test --match-contract LiquidityTrap
```



