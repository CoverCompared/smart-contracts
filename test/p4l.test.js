// const { expect } = require('chai');
// const { ethers } = require('hardhat');
// const { getBigNumber, getHexStrFromStr, getPaddedHexStrFromBN } = require('../scripts/shared/utilities');
// const {
//   WETH_ADDRESS,
//   UNISWAP_FACTORY_ADDRESS,
//   TWAP_ORACLE_PRICE_FEED_FACTORY,
//   CVR,
//   USDC,
//   CVR_USDC,
//   WETH_USDC,
// } = require('../scripts/shared/constants');

// // We are doing test P4L on rinkeby
// describe('P4LCover', function () {
//   before(async function () {
//     this.P4LCover = await ethers.getContractFactory('P4LCover');
//     this.ExchangeAgent = await ethers.getContractFactory('ExchangeAgent');
//     this.MockERC20 = await ethers.getContractFactory('MockERC20');
//     this.signers = await ethers.getSigners();

//     this.wethAddress = WETH_ADDRESS.rinkeby;
//     this.uniswapFactoryAddress = UNISWAP_FACTORY_ADDRESS.rinkeby;

//     this.cvrAddress = CVR.rinkeby;
//     this.cvr = await this.MockERC20.attach(this.cvrAddress);

//     this.usdcAddress = USDC.rinkeby;
//     this.wethUsdcAddress = WETH_USDC.rinkeby;
//     this.cvrUsdc = CVR_USDC.rinkeby;

//     this.twapOraclePriceFeedFactoryAddress = TWAP_ORACLE_PRICE_FEED_FACTORY.rinkeby;

//     this.devWallet = this.signers[0];
//   });

//   beforeEach(async function () {
//     this.exchangeAgent = await (
//       await this.ExchangeAgent.deploy(this.usdcAddress, this.wethAddress, this.uniswapFactoryAddress, this.twapOraclePriceFeedFactoryAddress)
//     ).deployed();

//     this.p4lCover = await (
//       await this.P4LCover.deploy(this.wethAddress, this.exchangeAgent.address, this.devWallet.address)
//     ).deployed();

//     await this.p4lCover.addCurrency(this.cvrAddress);
//     await this.exchangeAgent.addCurrency(this.cvrAddress);
//   });

//   it('Should buy P4L by ETH', async function () {
//     let hexData = '';

//     const policyId = 'P4L-000';
//     const value = 50;
//     const durPlan = 6;

//     const hexPolicyId = getHexStrFromStr(policyId);
//     const paddedValueHexStr = getPaddedHexStrFromBN(value);
//     const paddedDurPlanHexStr = getPaddedHexStrFromBN(durPlan);

//     hexData = hexPolicyId + paddedValueHexStr.slice(2) + paddedDurPlanHexStr.slice(2);
//     const flatSig = await this.devWallet.signMessage(ethers.utils.arrayify(ethers.utils.keccak256(hexData)));

//     const expectedAmount = await this.exchangeAgent.getETHAmountForUSDC(value);

//     await expect(this.p4lCover.buyProductByETH(policyId, value, durPlan, flatSig, { value: getBigNumber(1) }))
//       .to.emit(this.p4lCover, 'BuyP4L')
//       .withArgs(0, this.signers[0].address, this.wethAddress, expectedAmount, value);
//   });

//   it('Should buy P4L by available token', async function () {
//     let hexData = '';

//     const policyId = 'P4L-000';
//     const value = getBigNumber(50);
//     const durPlan = 6;

//     const hexPolicyId = getHexStrFromStr(policyId);
//     const paddedValueHexStr = getPaddedHexStrFromBN(value);
//     const paddedDurPlanHexStr = getPaddedHexStrFromBN(durPlan);

//     hexData = hexPolicyId + paddedValueHexStr.slice(2) + paddedDurPlanHexStr.slice(2);
//     const flatSig = await this.devWallet.signMessage(ethers.utils.arrayify(ethers.utils.keccak256(hexData)));

//     const expectedAmount = await this.exchangeAgent.getTokenAmountForUSDC(this.cvrAddress, value);

//     await this.cvr.connect(this.signers[0]).approve(this.p4lCover.address, ethers.constants.MaxUint256, { from: this.signers[0].address });

//     await expect(this.p4lCover.buyProductByToken(policyId, value, durPlan, this.cvrAddress, flatSig))
//       .to.emit(this.p4lCover, 'BuyP4L')
//       .withArgs(0, this.signers[0].address, this.cvrAddress, expectedAmount, value);
//   });
// });
