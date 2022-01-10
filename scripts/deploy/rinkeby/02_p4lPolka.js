// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const _WETH = '0xc778417e063141139fce010982780140aa0cd5ab'; // UniswapV2 Router
  const _exchangeAgent = '0x3320C193109265faC179cC3eF0a466Cca01651DF';
  const _devWallet = '0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b';
  const _signer = '0x356C9B814a5D3508ab76834D0eF67e6A171d3740';

  await deploy('P4LCover', {
    from: deployer,
    args: [_WETH, _exchangeAgent, _devWallet, _signer],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['P4LCover', 'CoverCompared'];
