// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const _CVR = '0xFc9B2B2565B38511B9822887F99D036d694a11e6';
  const _exchangeAgent = '0x51FCc54e9c7D8606cD16ea54e91Ed4D09F831e64';
  const _distributor = '0xe77250450fc9f682edeff9f0d252836189c01b53';

  await deploy('NexusMutualCover', {
    from: deployer,
    args: [_CVR, _exchangeAgent, _distributor],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['NexusMutualCover', 'CoverCompared'];
