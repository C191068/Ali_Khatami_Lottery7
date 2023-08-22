module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const lottery = await deploy("akrkLottery", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 6,
    })
}
