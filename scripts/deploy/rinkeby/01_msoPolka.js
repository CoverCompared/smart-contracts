// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const _WETH = '0xc778417e063141139fce010982780140aa0cd5ab'; // UniswapV2 Router
  const _exchangeAgent = '0x5640B69a5e1375a95e610052c5eedfea17675996';
  const _devWallet = '0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b';

  await deploy('MSOCover', {
    from: deployer,
    args: [_WETH, _exchangeAgent, _devWallet],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['MSOCover', 'CoverCompared'];
