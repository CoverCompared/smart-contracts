// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const _WETH = '0xc778417e063141139fce010982780140aa0cd5ab'; // UniswapV2 Router
  const _exchangeAgent = '0x1eEF7bF547aC2EFeFd2B0582d208Bef5ae0d92d6';
  const _devWallet = '0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b';
  const _multiSigWallet = '0x16968799D61aDD13833912Cd6a6DCC7338d06944';

  await deploy('P4LPolka', {
    from: deployer,
    args: [_WETH, _exchangeAgent, _devWallet, _multiSigWallet],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['P4LPolka', 'PolkaCover'];
