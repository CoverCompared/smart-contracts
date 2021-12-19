const { BigNumber } = require('@ethersproject/bignumber');
const { expect } = require('chai');
const { ethers } = require('hardhat');
const { getBigNumber, getHexStrFromStr, getPaddedHexStrFromBN } = require('../scripts/shared/utilities');
const {
  WETH_ADDRESS,
  UNISWAP_FACTORY_ADDRESS,
  TWAP_ORACLE_PRICE_FEED_FACTORY,
  CVR,
  USDC,
  CVR_USDC,
  WETH_USDC,
} = require('../scripts/shared/constants');

// We are doing test MSO on rinkeby
describe('MSOCover', function () {
  before(async function () {
    this.MSOCover = await ethers.getContractFactory('MSOCover');
    this.ExchangeAgent = await ethers.getContractFactory('ExchangeAgent');
    this.MockERC20 = await ethers.getContractFactory('MockERC20');
    this.signers = await ethers.getSigners();

    this.wethAddress = WETH_ADDRESS.rinkeby;
    this.uniswapFactoryAddress = UNISWAP_FACTORY_ADDRESS.rinkeby;

    this.cvrAddress = CVR.rinkeby;
    this.cvr = await this.MockERC20.attach(this.cvrAddress);

    this.usdcAddress = USDC.rinkeby;
    this.wethUsdcAddress = WETH_USDC.rinkeby;
    this.cvrUsdc = CVR_USDC.rinkeby;

    this.twapOraclePriceFeedFactoryAddress = TWAP_ORACLE_PRICE_FEED_FACTORY.rinkeby;

    this.devWallet = this.signers[0];
  });

  beforeEach(async function () {
    this.exchangeAgent = await (
      await this.ExchangeAgent.deploy(this.usdcAddress, this.wethAddress, this.uniswapFactoryAddress, this.twapOraclePriceFeedFactoryAddress)
    ).deployed();

    this.msoCover = await (await this.MSOCover.deploy(this.wethAddress, this.exchangeAgent.address, this.devWallet.address)).deployed();
    await this.msoCover.addCurrency(this.cvrAddress);
    await this.exchangeAgent.addCurrency(this.cvrAddress);
  });

  it('Should buy MSO by ETH', async function () {
    let hexData = '';
    const policyId = 'MSO-000';
    const priceUSD = 30;
    const productPeriod = 5;
    const conciergePrice = 20;

    const hexPolicyId = getHexStrFromStr(policyId);
    const paddedPriceUSDHexStr = getPaddedHexStrFromBN(priceUSD);
    const paddedPeriodHexStr = getPaddedHexStrFromBN(productPeriod);
    const paddedConciergePriceHexStr = getPaddedHexStrFromBN(conciergePrice);

    hexData = hexPolicyId + paddedPriceUSDHexStr.slice(2) + paddedPeriodHexStr.slice(2) + paddedConciergePriceHexStr.slice(2);
    const flatSig = await this.devWallet.signMessage(ethers.utils.arrayify(ethers.utils.keccak256(hexData)));

    const expectedAmount = await this.exchangeAgent.getETHAmountForUSDC(priceUSD + conciergePrice);

    await expect(this.msoCover.buyProductByETH(policyId, priceUSD, productPeriod, conciergePrice, flatSig, { value: getBigNumber(5, 16) }))
      .to.emit(this.msoCover, 'BuyMSO')
      .withArgs(0, expectedAmount, priceUSD, conciergePrice, this.signers[0].address, this.wethAddress);
  });

  it('Should buy MSO by available token', async function () {
    let hexData = '';
    const policyId = 'MSO-000';
    const priceUSD = 30;
    const productPeriod = 5;
    const conciergePrice = 20;

    const hexPolicyId = getHexStrFromStr(policyId);
    const paddedPriceUSDHexStr = getPaddedHexStrFromBN(priceUSD);
    const paddedPeriodHexStr = getPaddedHexStrFromBN(productPeriod);
    const paddedConciergePriceHexStr = getPaddedHexStrFromBN(conciergePrice);

    hexData = hexPolicyId + paddedPriceUSDHexStr.slice(2) + paddedPeriodHexStr.slice(2) + paddedConciergePriceHexStr.slice(2);
    const flatSig = await this.devWallet.signMessage(ethers.utils.arrayify(ethers.utils.keccak256(hexData)));

    const expectedAmount = await this.exchangeAgent.getTokenAmountForUSDC(this.cvrAddress, priceUSD + conciergePrice);
    await this.cvr.connect(this.signers[0]).approve(this.msoCover.address, getBigNumber(100000000000));

    await expect(this.msoCover.buyProductByToken(policyId, priceUSD, productPeriod, this.cvrAddress, conciergePrice, flatSig))
      .to.emit(this.msoCover, 'BuyMSO')
      .withArgs(0, expectedAmount, priceUSD, conciergePrice, this.signers[0].address, this.cvrAddress);
  });
});
