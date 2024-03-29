// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('MockERC20', {
    from: deployer,
    args: ['CVRs', 'CVR'],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['CVR', 'PolkaCover', 'Mock Token'];
