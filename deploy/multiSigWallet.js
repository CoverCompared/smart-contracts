// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const signers = ['0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b', '0xDEfd29b83702cC5dA21a65Eed1FEC2CEAB768074'];
  const _numConfirmationsRequired = 2;

  await deploy('MultiSigWallet', {
    from: deployer,
    args: [signers, _numConfirmationsRequired],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['MultiSigWallet', 'PolkaCover'];
