const { expect } = require('chai');
const { ethers } = require('hardhat');

const { getAPIEndPoint, getCoverPremium, confirmCoverPremium } = require('../scripts/shared/insureAce');
const { advanceBlockTo } = require('../scripts/shared/utilities');

// We are doing test on Ethereum mainnet hardhat
describe('InsureAcePolka', function () {
  before(async function () {
    this.InsureAcePolka = await ethers.getContractFactory('InsureAcePolka');
    this.signers = await ethers.getSigners();

    this.chainId = 1;
    /** Below parameters are hard coded for just testing. */
    // this.coverContractAddress = '0x05DC45B1c03657d141696aAe0211c84818f520b3';
    this.coverContractAddress = '0x88Ef6F235a4790292068646e79Ee563339c796a0';
    this.chain = 'ETH';
    this.coverOwner = this.signers[0].address;
    this.productIds = [4, 58]; // hardcoded at the moment
    this.coverDays = [30, 60];
    this.coverAmounts = ['500000000000000000', '800000000000000000'];
    this.coverCurrency = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
    this.referralCode = null;

    // this.chainId = 4;
    // /** Below parameters are hard coded for just testing. */
    // this.coverContractAddress = '0x0921f628b8463227615D2199D0D3860E4fBcD411';
    // this.chain = 'ETH';
    // this.coverOwner = this.signers[0].address;
    // this.productIds = [4, 58]; // hardcoded at the moment
    // this.coverDays = [30, 60];
    // this.coverAmounts =  ["500000000000000000", "800000000000000000"];
    // this.coverCurrency = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
    // this.referralCode = null;
  });

  beforeEach(async function () {
    this.insureAcePolka = await (
      await this.InsureAcePolka.deploy(
        this.signers[0].address, // @todo should be changed CVR
        this.signers[0].address, // @todo should be changed ExcahngeAgent
        this.coverContractAddress
      )
    ).deployed();
  });

  // it('Should get data from InsureAce API', async function () {
  //   console.log('1. Getting premium...');
  //   const premiumInfo = await getCoverPremium(this.chainId, {
  //     chain: this.chain,
  //     productIds: this.productIds,
  //     coverDays: this.coverDays,
  //     coverAmounts: this.coverAmounts,
  //     coverCurrency: this.coverCurrency,
  //     owner: this.coverOwner,
  //     referralCode: this.referralCode
  //   });

  //   console.log('2. Confirming cover premium');
  //   const confirmInfo = await confirmCoverPremium(this.chainId, {
  //     chain: this.chain,
  //     params: premiumInfo.params,
  //   });
  //   console.log(`confirmInfo ${JSON.stringify(confirmInfo)}`);
  // });

  it('Should buy product By ETH', async function () {
    console.log('1. Getting premium...');
    const premiumInfo = await getCoverPremium(this.chainId, {
      chain: this.chain,
      productIds: this.productIds,
      coverDays: this.coverDays,
      coverAmounts: this.coverAmounts,
      coverCurrency: this.coverCurrency,
      owner: this.coverOwner,
      referralCode: this.referralCode,
    });

    console.log('2. Confirming cover premium');
    const confirmInfo = await confirmCoverPremium(this.chainId, {
      chain: this.chain,
      params: premiumInfo.params,
    });

    const params = confirmInfo.params;
    console.log('current block height', await ethers.provider.getBlockNumber());
    console.log('securityParameters', params[8]);
    await advanceBlockTo(parseInt(params[8][0]) + 5);

    await this.insureAcePolka.buyCoverByETH(
      params[0],
      params[1],
      params[2],
      params[3],
      params[4],
      params[5],
      params[6],
      params[7],
      params[8],
      params[9],
      params[10],
      params[11],
      { value: premiumInfo.premium }
    );
  });
});
