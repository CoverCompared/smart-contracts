// This script is for airdrop mock on testnet
const { ethers } = require('hardhat');
const { getBigNumber } = require('./shared/utilities');

const RECEIVERS = [
  '0x7aC9C9135de57041095103d2aA8B5Be31B9aa415',
  '0x409c31A26E43C3EB7D4b6F2770f654fBA41660B7',
  '0x97E4FfcF0DaD720b3AdaD55ecc46980A2B043123',
  '0x5e29BC412B1f2Dd71a22baE246E6acE3b861EF69',
  '0x30a828319f8F23ebc4B2ebD671eBE511E06EffF5',
  '0xEA94e8832CADd3c2DA4ccbE78C5f889dA2782Ae0',
  '0xE64629dDb17FB53af2b3124A76602b4AF6EaA3bf',
  '0x13D27067c12E397c009128d8CBfe960725bC67a3',
  '0x9dCf03838B3D02b30DFFF1806cE5D08f59bD1Ced',
  '0xA96FB345fEAc989FC123232885407e3ddC65A095',
  '0x7026876DB37e16FD7BC515f210Ae3e9590d8e866',
  '0xD1bFC9f03ce3FDc9BF60cb7f18f9130A5eD81948',
  '0x4F4C3a3AB3423866849B986B60Eb53Df2E8602E4',
  '0x2EaD2E8677fdf1ce8Be30208bb9eCe0fb5714594',
  '0x0BF341C86A180ae8d12f0E7102dAC253CC656810',
  '0x783eC40a9404045e6F35D71FB017938dCffc233e',
  '0x3EfDC0C342244005A9A4041C82FdF7aab75b1f7c',
  '0x887039F7049F09e4AE114D105897A302AF70a829',
  '0x2f4f0120c3b6F887AbE084f6Ce787648EAd71062',
  '0xD344Df6a36BA1Ff26867045d62aA5362f4AE0FF0',
  '0xE7a4bf56cAEcCbB0399e5d8F880a22eeA6DE7fC8',
  '0x6A25336f87Ec124Ec9D9A76a34FB05E4823C1CFA',
  '0xa538e220F46Dc4c8B16a148E79e8B6819367Dea2',
  '0x9c645Eb48e290CAe46E37515773feb11A96af5b8',
  '0x4523B0024168b7aF7271ECceD627974B0e6bEEC9',
  '0x213af2E4e72A07563E171107FA7d79Fd4d8D0781',
  '0x937d0139BeBBe9AAa170E518fb06A8928320D9Fc',
  '0x67FE6f8B218185Cb981D54ab524826266e9D2FfC',
  '0x9D306Fc412833E44505EB46faf3A51BB2704961C',
  '0xB257bc2Bdf83709B2FE1E8884111aED3Ec190873'
];


const CHUNK_SIZE = 50;

async function main() {
  const airdropContractAddress = "0x516Bc9ad2074c28cBC6Bb3a7f4786760641Be510";
  const airdropContract = await ethers.getContractAt('Airdrop', airdropContractAddress);
  const cvr = '0xd3e48FAcD30A73609ffA60AE84851e72d10fEa52';
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
