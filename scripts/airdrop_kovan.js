// This script is for airdrop mock on testnet
const { ethers } = require('hardhat');
const { getBigNumber } = require('./shared/utilities');

const RECEIVERS = [
  '0x2b027fc5d37000699c7f85edfbad6acf76b4f0a7',
'0x95f4B26077C8E3e25dA9eB295Aea85B04b9C967b',
'0xDBf5Af5d5C25CD20390CD9487f3d2Bc8b39fb3cE',
'0xdB648ADFb54Fd67d2b7ae05C800628601432F8ff',
'0x77F32431FD1b840D664C7B470Cc0Fc2eBbE2B9C0',
'0xD62eb3de6C73937148020A95F6359282816AF938',
'0x1aBc3cBBAB938f92CDdDB8187aBf3C4Bb5CD6352',
'0x0d8FBfCE9018950e97ea5B10f4DCE118F02fda81',
'0x1860a619d26f4998c3C5fac85738eCD912bf34b5',
'0xc3e8c5B49Bb5Aa31C819D7B20EFED65924c8Ba30',
'0xc9B87204dddad169Af4E4BEfa5FC5ce88ad02512',
'0x9bFFd20A9c9e23fa2Bd530ea4809921e6D71e63E',
'0xe5d2a4a5505106c05dbe588cdc491fd6f4778f2b',
'0x4b8722aB20E1bC61DF07343818328128dDCc3E41',
'0xAB3f4956b4EF7c6EDbc79c8c22bb1490AdE4834e',
'0x031c02C1f21F4e24cC244cBBA5aD1B2059De9b37',
'0x2E8332DE2CB33Ba36BAd9F6a686b6B23ca240cE1',
'0x575EC632bB8F13105FD487B31439D22EeA0c4b1C',
'0xD5f652068F02A91D0Ee5cbc8C226aF61Cb76efbC',
'0x9fdA04BD525fa4eb4C30A62d386D57Bf8AE04ba1',
'0x952751429b98532673A72c2eE9daeC7905aDeE2b',
'0xbc98F0F440f59d5b9e5359589277CDD756636a74',
'0xbaC969430a2da39C1a76FB3b21C021E92306f8c5',
'0xE27A94268f5aa5b70748a38e58293Cd993579a91',
'0x801E395Ea58B4cdf1C64A59D695Dd8f0cD946A38',
'0x60c5619FEB40276e78cCCdb099C5c2908E62b998',
'0x73C9640dbD36B58ff7ad336a1da14D10b0cD2037',
'0x461C2BEC24f83140c949Cc9cdd77707D4a134D73',
'0x6A186E47745b24415b546B7D347768697FaDEc7b',
'0x94DE06719f055916e03c31b841866d713FA3c45c',
'0x698F6e82da956f80D97cb5f8D0678a6E20a32e00',
'0x91B3114Af652B63514bb4B7c8A7CE006F1a25ec6',
'0x12d6aA0CeaaA7c6DC9B10fEDe199a62e3B7489d3',
'0xf7353AC107BFE5041a8c13C55dd23361599bFecF',
'0x1E3eEf86f764F9910e9bE00ACeb462D169C9af03',
'0xAc3cA9e05CA1b479Ec6035B4a768C07230A3Ec67',
'0xDeD11bd23AD00BeDCa53Fe653Ee9577D4408b8B9',
'0x6ffabdbF6613BC30c933f204Bd599b59975f016B',
'0x556fb5E4e52634D755AdAc75082eD8a2C356Bcc9',
'0xf47Ec7c789b52a82F5Ca312244ddafd1A91EE55C',
'0x93f23dFf48458110c43A83Dd7C71AD750416B913',
'0x1b7BaD7732a37Df7Fd513B0d3a93994E472e6F91',
'0xBEC8959dC4628138ecd5841E9457B1e0f7AFCb8a',
'0x55077f55C5558b5792A55dF910aAf7aFC75e731F',
'0xE15509a5026007D18389ebA73aD8b8226D13A6B1',
'0x6fd52723272C59f2b0Fb35e1E1f196e418d42Ca2',
'0x32E15607A78f396c87F72fbe5CAE2f3b89259356',
'0xd77c46572f90Cf5158Db2a444C963422cB22A198',
'0x1f03D9efef2D8eAD8D1B6efd7050e92af6274d22',
'0x9319998C7B21A6944B39EA0635891A9FCE46E6A6',
'0xA1bc83F13C10C82C465E8f8b8083dB7Ad0A9A4F1',
'0x20882754D875C388Ec1d0b624Ab3336d9fB90aa1',
'0x0E40aaaE416879137e1ee8ef6D9F2Aa6bE6Bd0Cf',
'0x0fb680e7de03F32bfe31e774ec10AdF5bD5a5f6B',
'0xDe9a9425b3CE28f66719eA606B1d1FDda210A94d',
'0x14f9eF4017ce65eaf97495eEdA7B98A2C4A31f93',
'0xB33e0Ef006Eb4846adc2036666A3489b6d1902Bd',
'0x9b9FE7f26ef91b89693F58a734c72C24960712D7',
'0xfa38Be1fbc23D94B95C695F8610A48e255569005',
'0x5f38ED049a350CAd6c99B109bde5eab4aB278728',
'0xfb34A59731769770069667aD4c806cd282f5968d',
'0xb2C659C4B388E0840f581B1c21F5cA4F9f823D46',
'0x49bc13b81A16e00e916E01569956D29B13375d47',
'0x1e8E74FE50D0F2b15DB968261A78D3ff0dBcCbC4',
'0x647247C21D8E01e1f6fB23B64ab45694A7BDC759',
'0x2b74A075157035977e006c8d71dE9Ca240aA8711',
'0x948ba46C967a3E92fc34dA53C9ef5FA75B724405',
'0xd87e58Cd1fAc2956B187eb705da73F98B5CfE8D6',
'0x0FAB8AEBAf43D7E42Bd2f1Fe312D66673987E724',
'0x650b1E81628bC125A78C3FD7C66211b53E65535a',
'0x51F420e4D24ba868C969DE505EFb4D26b9bFcF5c',
'0x5bCd2BC57ba7b6b073c352fC75Da9b01BF1B9fB6',
'0xC134f280C35dFD5ccD47Ea1584e987aB64389fC6',
'0x0DF02e0118F8665462348b3fBE926A868D51C8Aa',
'0xfB57177EdeAdDDDee18BB92763a5438264C83a1c',
'0x75fb3d5062B670f6F6b51D3e9517791a22275a80',
'0xfD46918D10977f0B2c486772F433a90124eC6A87',
'0xEe82bBA8e7367d4FE1a79e520390f1d89453a51F',
'0xb0eF2ef30f225C2e84ABA0938874a0D90f454726',
'0x48B1cE0e5c57309351a993792B749f30357eFE81',
'0x49380b238dBe8FC8579A6bAE8903bD5A4F2E25d1',
'0xC0a28EA12fae82FcD693b8aE9cDd552B93608cE7',
'0x0A3B4905B0A7Bd42645c8f0BDa9f3bC213f09610',
'0xbE53aC9178cDE328cb52e70882a1b24Eb1734481',
'0x8E8bBB0283DD62A2d40B4f1310C0E57d1927e140',
'0xa13bC3FBe6Ee0c3a6f0B72F4e24c4351D7A1b9B6',
'0xa8e59Bd3cAab29d41fa663b4A47Dd1538d85A879',
'0x4b20c3f54f78253Ac951e962E6501e724b8357dB',
'0x00528c921a79cbd6ae88f901df3f1795f6bfb56b',
'0xbC8444E64efEd41aa85547f71D03d9d1d7422FE6'
];


const CHUNK_SIZE = 50;

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
