// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const _WETH = '0xc778417e063141139fce010982780140aa0cd5ab'; // UniswapV2 Router
  const _exchangeAgent = '0xed698505e496B0c39Eb42B9696f141C5526DdF24';
  const _devWallet = '0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b';
  const _multiSigWallet = '0xC31F8d97B0B9fcD8A30F9AA906335dCCdba99bD5';

  await deploy('MSOPolka', {
    from: deployer,
    args: [_WETH, _exchangeAgent, _devWallet, _multiSigWallet],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['MSOPolka', 'PolkaCover'];
