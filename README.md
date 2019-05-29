# Towards Tax Compliance by Design: A Decentralized Validation of Tax Processes Using Blockchain Technology
This repository includes the smart contract implementation described in our accepted paper "Towards Tax Compliance by Design: A Decentralized Validation of Tax Processes Using Blockchain Technology" at the 21st IEEE Conference on Business Informatics (CBI 2019).

## Getting Started

### Prerequisites
To run our test code and deploy the smart contracts, you need [truffle](https://truffleframework.com/truffle). Truffle can be installed through the [node](https://nodejs.org/en/) package manager (npm).
```
npm -g install truffle
```

Moreover, in order to execute the truffle tests, you need to install ``truffle-assertions``. The package can be automatically installed by running ``npm install`` within the project directory.

### Deploy the Smart Contracts
Our truffle project includes a deployment script that deploys the administrative as well as the CoA smart contract. The network to which the smart contracts are deployed can be configured in the ``truffle-config.js`` file. For more information, see the [truffle documentation](https://truffleframework.com/docs/truffle/reference/configuration).
By default, truffle assumes the development network to be available at 127.0.0.1:8545. In this case, the smart contracts can be deployed with the ``truffle migrate --reset`` command.

### Run the Test Samples
You can easily run the tests located in the ``test`` directory using the truffle framework. For example, run within the project directory:

```
truffle test
```

The comments in the test code (``test/exchange.js``) explain both test cases.