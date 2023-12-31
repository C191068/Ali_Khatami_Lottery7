require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("solidity-coverage")
require("hardhat-gas-reporter")
require("hardhat-contract-sizer")
require("dotenv").config()

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
module.exports = {
    defaultNetwork: "hardhat",
    networks:{
        hardhat{
            chainId: 31337,
            blockConfirmations: 1,
        },
        sepolia: {
            chainId: 4,
            blockConfirmations: 6,
            url:
            accounts:
        },
    },
    solidity: "0.8.19",
    namedAccounts: {
        deployer: {
            derfault: 0,
        },
        player: {
            default: 1,
        },
    },
}
