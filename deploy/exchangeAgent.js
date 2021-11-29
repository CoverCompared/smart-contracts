// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
/**
 * @note These are rinkeby addresses, should be changed whenever switching network
 */
const USDC = '0xD4D5c5D939A173b9c18a6B72eEaffD98ecF8b3F6';
const WETH = '0xc778417e063141139fce010982780140aa0cd5ab'; // Uniswap V2 WETH
const UNISWAPV2_FACTORY = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
const TWAP_PRICE_FEED_FACTORY = '0x6fa8a7E5c13E4094fD4Fa288ba59544791E4c9d3';
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('ExchangeAgent', {
    from: deployer,
    args: [USDC, WETH, UNISWAPV2_FACTORY, TWAP_PRICE_FEED_FACTORY],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['ExchangeAgent', 'PolkaCover'];
