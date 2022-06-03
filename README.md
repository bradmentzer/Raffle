Decentralized Raffle

<<Writing the contracts>>

1. Enter lottery for a fee
2. Pick a random winner
   1. Autonomous- we never have to interact
   2. Provably random

Deploy contract

<<Build the frontend>>

1. Buttons NextJS
2. Deploy in a decentralized context

yarn add --dev @chainlink/contracts
yarn add --dev hardhat-deploy

# wrap hardhat ethers with

yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers

yarn add --dev prettier-plugin-solidity prettier

yarn add dotenv

yarn add --dev @nomiclabs/hardhat-waffle
