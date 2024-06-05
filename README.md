# Hardhat common usage

## Normal command

npx hardhat

npx hardhat compile

npx hardhat test

## Migrate & Deploy command

npx hardhat run scripts/`Script Name`.js [--network `Network`]

## Verify command

npx hardhat verify [--network `Network`] DEPLOYED_CONTRACT_ADDRESS ["Constructor Argument"]

## Other command

npx sol-merger "contracts/`ContractName.`"
