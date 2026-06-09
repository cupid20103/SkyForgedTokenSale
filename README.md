# SkyForged Token Sale

A staged presale (ICO) smart contract for the SkyForged token, built with Hardhat. Buyers pay in USDC and receive an allocation of tokens that becomes claimable once the sale finishes.

## How it works

- The sale runs through 9 sequential stages, each with its own per-token price (in USDC) and token allocation.
- Buyers call `buyTokens` to purchase from the current stage. Payment is pulled in USDC and forwarded to the fee wallet.
- A stage advances automatically once its allocation sells out.
- Purchases are recorded per buyer in `purchasedTokens`. Tokens are not transferred at purchase time.
- Once every stage has sold out, buyers call `claimTokens` to receive their tokens.
- The owner can pause/resume the sale, update the fee wallet, and withdraw leftover tokens after the sale ends.

Payment uses USDC on Base mainnet (`0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`). Token amounts use 18 decimals and USDC uses 6 decimals.

## Requirements

- Node.js 20 (see `.nvmrc`)
- Yarn

## Setup

```
yarn install
```

Create a `.env` file (see `.env.test` for the keys) with:

```
PRIVATE_KEY=     # deployer private key, without the 0x prefix
INFURA_API_KEY=  # used by the Ethereum mainnet network
SCAN_API_KEY=    # block explorer API key, used for contract verification
```

`PRIVATE_KEY` is only required when sending transactions (deploying or verifying). Local `compile` and `test` work without it.

## Common commands

Compile the contracts:

```
npx hardhat compile
```

Run the tests:

```
npx hardhat test
```

Deploy to a network (the deployer addresses are set in `scripts/deploy.js`):

```
npx hardhat run scripts/deploy.js --network <network>
```

Verify a deployed contract on the block explorer:

```
npx hardhat verify --network <network> <DEPLOYED_CONTRACT_ADDRESS> "<Constructor Argument>"
```

## Networks

Configured in `hardhat.config.js`. The default network is the in-process `hardhat` network. Available networks include `mainnet`, `sepolia`, `holesky`, `mainnet_bsc`, `testnet_bsc`, `mainnet_polygon`, `testnet_polygon`, and `base_sepolia`.
