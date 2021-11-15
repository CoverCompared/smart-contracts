// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const signers = [
    '0x396FA529e1B1D9582f5016511A88a7BA28190965',
    '0x1Df437DE4C327CE210A18FF25EbB7322AEA50095',
    '0xC7D822328aC1e28a82B1b333ac077511B050fc9F',
    '0x15C1e78536F761B2FeD10f1EcDb6db6B4D1E5d5F',
  ];
  const _numConfirmationsRequired = 2;

  await deploy('MultiSigWallet', {
    from: deployer,
    args: [signers, _numConfirmationsRequired],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ['MultiSigWallet', 'PolkaCover'];
