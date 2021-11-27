// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

/**
 * @note Please check what network you are playing on now
 */
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  /** @note Check these addresses every deployment,  */
  const _CVR = '0xd3e48FAcD30A73609ffA60AE84851e72d10fEa52';
  const _exchangeAgent = '0x1eEF7bF547aC2EFeFd2B0582d208Bef5ae0d92d6';
  const _coverContractAddress = '0x0921f628b8463227615D2199D0D3860E4fBcD411';

  await deploy('InsureAcePolka', {
    from: deployer,
    args: [_CVR, _exchangeAgent, _coverContractAddress],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['InsureAcePolka', 'PolkaCover'];