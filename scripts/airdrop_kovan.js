// This script is for airdrop mock on testnet
const { ethers } = require('hardhat');
const { getBigNumber } = require('./shared/utilities');

const RECEIVERS = [
  '0xCB7765cbf6d0AaE17f89D99D54d65d6CA050EFa8',
  '0x426E5CF7803f1aeD2f9446c3FA3721954B98DC87',
  '0x02A0Ff1EC6cEF01E72fDF2A761225caBd7880CC1',
  '0x816cC43EBeB044cdb755E0F06993a0EB4f42Be36',
  '0xa7910BBea68734Ca1B42c85ec21b0CDdD619EA4B',
  '0x4CA7EdDDA41157140F4E3FADD71dDAaeca13aC92',
  '0x91CC478B5b6Dbf53A6fE7918664e9C96DCEFC3D4',
  '0xeb84C6c37158f4d3691F709A39A97cb880b6a3CE',
  '0x47543111e36597a3570b6Fc5bC6ce3AdF0e5dD6C',
  '0x7dc41E7E2a6Bc74d4D43491A235976F9eF2B80b4',
  '0x23c14E77e980e8D90851c72678ec5f4255aF7874',
  '0x4a0C4d58F065aF34c31B1356d4933926173645E7',
  '0x9BFCe4bC4330EC3F0a1b9be6FC7a7b0bf895696D',
  '0xD6b2786A8bE1E540da2C71a0D4bfCee1d55d0178',
  '0x2C575FfACFB644D5504cb4e6369d42CE465c4ee8',
  '0x167581E73bbDeD3730B60a407f86234F876453bf',
  '0x77c50f15C4AcD969989632c659e767f6Cf50Ac8a',
  '0xC6c03Ceb403a798e83cB1aed19536d03d86A14d5',
  '0x8c18Cf968075497fcc32dE5006db7B6CdBF3B4c1',
  '0xA6Ad8Aa40eef0Ab6c8D66040CD3bBB6673A27464',
  '0x83D3b06b93c1FF58E57a047Ee7A37392581b0367',
  '0x43f54ADf885CD19ed9Ac7029C6AD43Fd8fc93BB1',
  '0x3e2613097CF934f39D7C0954cC3929a5FA3F9FE5',
  '0xcc170AAFdAc49cBD132B9c342e401D76d9a8de4b',
  '0x9a5594e857A1cBb2Ac9f5a0f85E20996CE94FFc7',
  '0x216b468E0C23fC8901eeD39CbEbD5e6D6d7152ba',
  '0x5c96AeF83De0a4a6cD68C1bBEB1F2435aB323eaB',
  '0xE292b11edd2db992fD61838C59856f7176b4b127',
  '0x9AC64B8D3d1171470C6c00EeA21B28414bC98d42',
  '0x595b275c1A27efD53838ec730646B6c7f8df579a',
  '0xF8D8aa09919d42a84Bd9Dab81288Fa509c822E29',
  '0x81B5194ac62bfC307699a49513410dc589837Db7',
  '0x15B238f81fCC26Ce23f4343722792a5d4D0BFD1A',
  '0x05182841bb3b3dBe64AdAd70FFb1E95278Ad44af',
  '0xb5f936A9A4e6EAeD966D974994323Ad8560B563C',
  '0x97b50989B9ba4220732B57e935E481bef5a40000',
  '0x55FDb36811969d25FB2D49631de54A996D0dA053',
  '0x0698D798C667F765F4e9d09d107Df951d699F4a0',
  '0xca875733d8030849FDe3e63B2b4CDb40c96bc10D',
  '0x8aABBFFbA4fB3aE5d99E4AdD66A194d36691BE7D',
  '0xF1EFD89f2CE4002012A64D3C8D9F4D41eD8001Ab',
  '0x5CA81D9B624F4802F2A1f9e4Cb6E20bB4cdCDbaB',
  '0xe04122Ef7e9232c7D724f48eFE46655417f320C0',
  '0x0799699f4a7Ff676E7c6A0169588d602A85fdDf8',
  '0xb0D06D48aFC6Bd43Cc5377496A1b674fAe21d5FC',
  '0xc833294c9a6832499Cc7040A724B7D5526b42D8C',
  '0xbF48FD1a7Cbd66e96E1646D05f0598687f97b274',
  '0x4882e382DC07e0621C4D53baB969279308Bbce7f',
  '0x053CfAf8bf4f75b0899c603A0cD8EA3AEE331f26',
  '0x0C713514522A5F821BB20937E74612e71365D317',
  '0x75A5b31C4384926Dd571cdDc73a5B23974374deA',
  '0xe56a378d229621a15f4A70B3dbE860ff2f9Fb5F8',
  '0x495FFB23e9dA2E93648F882b2d3e48e9b3dAEcA3',
  '0x54321103c0156d6d9B09E169d10393AA20C70Be2',
  '0xBE64c8A2C6ee6A8EDeb4789B031525183a464881',
  '0x2d096Fd2Aa1E1B8f2FfE36551c6EB41BeBA65a33',
  '0x727839FD19978809B7e616092E2eb7b54034a4d7',
  '0x1430A7cf9F532A08F524148c05EEdcC9acAa2340',
  '0x8374C3C10411890603E7B3Df1Ef4aa76DbB7881A',
  '0x70F829803447414B1B7Dc934366FB41644B28680',
  '0xC0886247066bA2Bd0Dca2bF5502CDa8cee8e43f0',
  '0x9bE08bbdc799625F5CC1A5ec517E111E7c8c5975',
  '0xbF91b4014C2b5d20dFaB36E90A3a2590F61a1F5E',
  '0xaf2A839d55AdD7D837EB1Fef540910D80b302289',
  '0xc880E2D173edeAAEB866ba0ED906666439DF6497',
  '0xE7Bf3F476fc8Ef90812e2f57Df14160Bbd88dc72',
  '0xA138e9AF6c627F6C8F130C4efe79CdA074FeD62d',
  '0x12A966269815E8EDBcC6f65d13b66BD7FC0a8A4E',
  '0x060A114ACd2C0c55a1711a37b77b47F230b72b10',
  '0xd8977138e53fa23bF85B0760F69D39434C3f2CEA',
  '0x8E8ec6b4a84F9b43e363D9F487210813ed181699',
  '0x4CBacCCC6902A20467DA456EBB77E649c0dFfb6A',
  '0xE231523410B629159D9C5fE76beB6E96d7C634bB',
  '0x50058BB0448371CdeA40bCe856f4A113be8DEe2c',
  '0xd996efF75E43357F04E3f37D61EF6A6851A0b8f1',
  '0x10088ec53aEbC9A371De5ebBb25c1a95900cC178',
  '0x4c22a8B1ed3FFDb148E6e4DeeDe6f872fb9fe25a',
  '0x092d57Ba4060E23A440340eC689C4005Ce41Ee8a',
  '0xf8F50338cB207305b1810ea7eC2693E3A60cDCCF',
  '0xB2C996B1b3a79cE0aC105a93F0B29dB25B6ADB15',
  '0x364D8F71860092C2d4D44D0F71AB3eF7abc48168',
  '0x3407e4d4c6960371aD0c36A31B27A251e50b3868',
  '0x7E4b769F08E0C6CbBDDA5F95191f69C2AcBC5B3b',
  '0xEaE78156Ee3B4d7932df4cdE7d6fAe86ef1BE108',
  '0x136728b98AEf538595c82F869AE64369D4637276',
  '0x3dF184aA3287746959c128d36C3805c940Bb60b5',
  '0x7F37Fc705B84eE9364a9d9C3AafB3c27c051a4dB',
  '0x13fBE5Cd76b900601bAcA777209B117F2C6954A1',
  '0xE6255a91734C77B1554EF9B38F8C878b31047e50',
  '0x81Aae3dd7A6DF8eEc91f65E2fa3419A22D50398d',
  '0xD081a5b9cBb2d6C3C99924c9D30DEe8027f2397F',
  '0x064d525fEA8fAeb998d97205459D437f0BE974F4',
  '0xC68df251e6cb9b238Ab8782F78A6F8e42F080BCf',
  '0x0BA3548e895EB3AA3Ec10DBd8F27D295c92fD05b',
  '0x333A340aC6BDB1DB377eEA7C71E6944CFb2B4c54',
  '0x799B73677764ae5B15b973072cf05E6C891C5d55',
  '0x88dCBB83544fC6Cc52b4cfc61EA72dc52CCeaA21',
  '0x2fcF506e32D1fbAFC9541B4266e23ff87945389E',
  '0x7FDEECF7ECcbaf02eE7b30213E7a59F7905c553c',
  '0x09f97171177956a1F5454Bf60EE9259772B21BEC',
  '0xD6f5E1B36c66E2bbb6f949e86cAcFcCc908B3dA7',
  '0x2910a8c6a167953411FFb52C9480fD764283bb04',
  '0x9524807A219f608e92d25Edd8D1176Ff16EfDbBF',
  '0xA1B8760B24b2Fb60EcefAB1550a325bC9eBd965F',
  '0xe198aB30E0537fA7DC425eC847527e5A96856CF1',
  '0xcA75928E3F6485c344073400f56dC708F84f2498',
  '0x2C909f75Db0DB0AC9E8109907958E41C36208554',
  '0x8863FE2d647D9042d2e265f36e0B9811Ef69C0CD',
  '0x3DE8b4a4d10722df64bcCb050606867EbdE36288',
  '0x7d2BaCafA10744C447724fA2c259980759B47eC7',
  '0x0389c580566E9616E28d0894f71cebCB77893ccE',
  '0x9EeC57DB1d46b2213283Fe7287370930E9D8693d',
  '0x6259cc840720f351a9651cd7242F12F7F98e83F4',
  '0x4aFFEB19c4FE1E91eD34F08C1d9fB667A0701b36',
  '0x30A18756C411E7f5F64007299481683a63Ed3334',
  '0x72C3e4e7DcA835240d9052c345659306cC9C0c3D',
  '0x789a7B1e97c659238d8140668a622cd1f38e525F',
  '0xdf5e5789BBEA65ecfac1DD4613Fd1BaB121d6604',
  '0x55308E95Ffa0d6d2e54eA3C41301fD8E9fdD7567',
  '0xA4021F1Aa41D11fc243A642dbCF173c4250eF756',
  '0x3D42F44fD8b751dC7864487a52D15618E9544C32',
  '0xd660B953c80e40C2eF7Fae9B856b8A293974BE0C',
  '0x43791B25Eeca0b1f8C8aDEE77246704efb40e978',
  '0xdA1802184699751966f91f764c9BF761F1F2E5AA',
  '0xf1F0c8A8297dEA74C570b8fb62c138B90f00B602',
  '0xa359a7B19F6A0a8490931f78763eD5554047c494',
  '0xd7202449533b348D4Eb585d7131a24ec90B0B2f7',
  '0x6B51a3BC35A505029b4f3B2DbCC8c739D9907352',
  '0x054cAC51aa782D8d80cF266a1a94D941A51F0B49',
  '0x581B10105020D551c02e0CD3577c0af3225394BC',
  '0x77A48665E8C9A34D0597cA9dD8A10580Ae7d76d3',
  '0x4ba6705757FC153E8ca3ac1482C0D1FE96ed9758',
  '0x0a66c4f7Af78a9FfacD7F44b58BCAF4395Ac7DC0',
  '0x3575Fb5349765ad12bD853B204E95B6bce8381a8',
  '0x3482C3C7498b4D35482Fec81858116ef424Db354',
  '0x0cd895A240669800F67a7A159F7Fbf72bC19477c',
  '0x0f966Ca63706Ce468bdEfAA5E955798CdADa4A2d'
];

const CHUNK_SIZE = 100;

async function main() {
  const airdropContractAddress = '0x51c93013EaB3095Bd3bEc7Dd9bC5e777cAa7ECb8';
  const airdropContract = await ethers.getContractAt('Airdrop', airdropContractAddress);
  const cvr = '0xFc9B2B2565B38511B9822887F99D036d694a11e6';
  const from = '0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b';

  /** validating addresses */
  for (const addr of RECEIVERS) {
    if (ethers.utils.isAddress(addr) !== true) {
      console.log(`Invalid address ${addr} - idx - ${RECEIVERS.indexOf(addr)}`);
      return;
    } else {
      console.log(`Address ${addr} is valid address`);
    }
  }
  let callReceivers = [];
  let callAmounts = [];
  let airdropIdx = 1;

  // const r1 = ['0xDEfd29b83702cC5dA21a65Eed1FEC2CEAB768074'];
  const r1 = [...RECEIVERS];
  for (const addr of r1) {
    callReceivers.push(addr);
    callAmounts.push(getBigNumber(10000));
    if (callReceivers.length === CHUNK_SIZE || r1.indexOf(addr) === r1.length - 1) {
      console.log(`Airdrop ${airdropIdx} is mining`);
      const tx = await airdropContract.airdrop(callReceivers, callAmounts, cvr, from, {
        gasPrice: ethers.utils.parseUnits('80', 'gwei'), gasLimit: 4000000
      });
      await tx.wait();
      console.log('Transaction hash', tx.hash);
      console.log(`Airdrop ${airdropIdx} was mined`);
      callReceivers = [];
      callAmounts = [];
      airdropIdx++;
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });