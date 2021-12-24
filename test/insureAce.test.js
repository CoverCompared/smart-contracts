// const { expect } = require('chai');
// const { ethers } = require('hardhat');

// const { getAPIEndPoint, getCoverPremium, confirmCoverPremium } = require('../scripts/shared/insureAce');
// const { advanceBlockTo, createPair, createPairETH, getBigNumber } = require('../scripts/shared/utilities');
// const TWAP_PRICE_FACTORY_ABI = require('../scripts/abis/TwapOraclePriceFeedFactory.json');

// const UNISWAPV2_ROUTER = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
// const UNISWAPV2_FACTORY = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
// const WETH = '0xc778417E063141139Fce010982780140Aa0cD5Ab';
// const TWAP_ORACLE_PRICE_FEED_FACTORY = '0x6fa8a7E5c13E4094fD4Fa288ba59544791E4c9d3';

// // We are doing test on Ethereum mainnet hardhat
// describe('InsureAcePolka', function () {
//   before(async function () {
//     this.basicMetaTransaction = await ethers.getContractFactory('BasicMetaTransaction');
//     this.InsureAcePolka = await ethers.getContractFactory('InsureAcePolka');
//     this.ExchangeAgent = await ethers.getContractFactory('ExchangeAgent');
//     this.MockERC20 = await ethers.getContractFactory('MockERC20');
//     this.signers = await ethers.getSigners();

//     /** Below parameters are hard coded just for testing. */
//     // this.chainId = 1;
//     // this.coverContractAddress = '0x88Ef6F235a4790292068646e79Ee563339c796a0'; // this is ETH mainnet address

//     this.chainId = 4;
//     this.coverContractAddress = '0x0921f628b8463227615D2199D0D3860E4fBcD411'; // this is rinkeby testnet address, @Terry checked it through test script

//     this.chain = 'ETH';
//     this.coverOwner = this.signers[0].address;

//     this.ABI = [
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '_CVR',
//             type: 'address',
//           },
//           {
//             internalType: 'address',
//             name: '_exchangeAgent',
//             type: 'address',
//           },
//           {
//             internalType: 'address',
//             name: '_coverContractAddress',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'nonpayable',
//         type: 'constructor',
//       },
//       {
//         anonymous: false,
//         inputs: [
//           {
//             indexed: false,
//             internalType: 'uint16[]',
//             name: 'productIds',
//             type: 'uint16[]',
//           },
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_buyer',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_currency',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'uint256',
//             name: '_amount',
//             type: 'uint256',
//           },
//         ],
//         name: 'BuyInsureAce',
//         type: 'event',
//       },
//       {
//         anonymous: false,
//         inputs: [
//           {
//             indexed: true,
//             internalType: 'uint256',
//             name: '_productId',
//             type: 'uint256',
//           },
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_buyer',
//             type: 'address',
//           },
//         ],
//         name: 'BuyProduct',
//         type: 'event',
//       },
//       {
//         anonymous: false,
//         inputs: [
//           {
//             indexed: false,
//             internalType: 'address',
//             name: 'userAddress',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'address payable',
//             name: 'relayerAddress',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'bytes',
//             name: 'functionSignature',
//             type: 'bytes',
//           },
//         ],
//         name: 'MetaTransactionExecuted',
//         type: 'event',
//       },
//       {
//         anonymous: false,
//         inputs: [
//           {
//             indexed: true,
//             internalType: 'address',
//             name: 'previousOwner',
//             type: 'address',
//           },
//           {
//             indexed: true,
//             internalType: 'address',
//             name: 'newOwner',
//             type: 'address',
//           },
//         ],
//         name: 'OwnershipTransferred',
//         type: 'event',
//       },
//       {
//         anonymous: false,
//         inputs: [
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_user',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_to',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'address',
//             name: '_token',
//             type: 'address',
//           },
//           {
//             indexed: false,
//             internalType: 'uint256',
//             name: '_amount',
//             type: 'uint256',
//           },
//         ],
//         name: 'WithdrawAsset',
//         type: 'event',
//       },
//       {
//         inputs: [],
//         name: 'CVR',
//         outputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'WETH',
//         outputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '_currency',
//             type: 'address',
//           },
//         ],
//         name: 'addCurrency',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         name: 'availableCurrencies',
//         outputs: [
//           {
//             internalType: 'bool',
//             name: '',
//             type: 'bool',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'uint16[]',
//             name: 'products',
//             type: 'uint16[]',
//           },
//           {
//             internalType: 'uint16[]',
//             name: 'durationInDays',
//             type: 'uint16[]',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'amounts',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'address',
//             name: 'currency',
//             type: 'address',
//           },
//           {
//             internalType: 'address',
//             name: 'owner',
//             type: 'address',
//           },
//           {
//             internalType: 'uint256',
//             name: 'referralCode',
//             type: 'uint256',
//           },
//           {
//             internalType: 'uint256',
//             name: 'premiumAmount',
//             type: 'uint256',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'helperParameters',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'securityParameters',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'uint8[]',
//             name: 'v',
//             type: 'uint8[]',
//           },
//           {
//             internalType: 'bytes32[]',
//             name: 'r',
//             type: 'bytes32[]',
//           },
//           {
//             internalType: 'bytes32[]',
//             name: 's',
//             type: 'bytes32[]',
//           },
//         ],
//         name: 'buyCoverByETH',
//         outputs: [],
//         stateMutability: 'payable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'uint16[]',
//             name: 'products',
//             type: 'uint16[]',
//           },
//           {
//             internalType: 'uint16[]',
//             name: 'durationInDays',
//             type: 'uint16[]',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'amounts',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'address',
//             name: 'currency',
//             type: 'address',
//           },
//           {
//             internalType: 'address',
//             name: 'owner',
//             type: 'address',
//           },
//           {
//             internalType: 'uint256',
//             name: 'referralCode',
//             type: 'uint256',
//           },
//           {
//             internalType: 'uint256',
//             name: 'premiumAmount',
//             type: 'uint256',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'helperParameters',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'uint256[]',
//             name: 'securityParameters',
//             type: 'uint256[]',
//           },
//           {
//             internalType: 'uint8[]',
//             name: 'v',
//             type: 'uint8[]',
//           },
//           {
//             internalType: 'bytes32[]',
//             name: 'r',
//             type: 'bytes32[]',
//           },
//           {
//             internalType: 'bytes32[]',
//             name: 's',
//             type: 'bytes32[]',
//           },
//         ],
//         name: 'buyCoverByToken',
//         outputs: [],
//         stateMutability: 'payable',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'coverContractAddress',
//         outputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'exchangeAgent',
//         outputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: 'userAddress',
//             type: 'address',
//           },
//           {
//             internalType: 'bytes',
//             name: 'functionSignature',
//             type: 'bytes',
//           },
//           {
//             internalType: 'bytes32',
//             name: 'sigR',
//             type: 'bytes32',
//           },
//           {
//             internalType: 'bytes32',
//             name: 'sigS',
//             type: 'bytes32',
//           },
//           {
//             internalType: 'uint8',
//             name: 'sigV',
//             type: 'uint8',
//           },
//         ],
//         name: 'executeMetaTransaction',
//         outputs: [
//           {
//             internalType: 'bytes',
//             name: '',
//             type: 'bytes',
//           },
//         ],
//         stateMutability: 'payable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: 'user',
//             type: 'address',
//           },
//         ],
//         name: 'getNonce',
//         outputs: [
//           {
//             internalType: 'uint256',
//             name: 'nonce',
//             type: 'uint256',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'owner',
//         outputs: [
//           {
//             internalType: 'address',
//             name: '',
//             type: 'address',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'productIds',
//         outputs: [
//           {
//             internalType: 'uint256',
//             name: '_value',
//             type: 'uint256',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '_currency',
//             type: 'address',
//           },
//         ],
//         name: 'removeCurrency',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         inputs: [],
//         name: 'renounceOwnership',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '_coverContractAddress',
//             type: 'address',
//           },
//         ],
//         name: 'setup',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: 'newOwner',
//             type: 'address',
//           },
//         ],
//         name: 'transferOwnership',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: 'owner',
//             type: 'address',
//           },
//           {
//             internalType: 'uint256',
//             name: 'nonce',
//             type: 'uint256',
//           },
//           {
//             internalType: 'uint256',
//             name: 'chainID',
//             type: 'uint256',
//           },
//           {
//             internalType: 'bytes',
//             name: 'functionSignature',
//             type: 'bytes',
//           },
//           {
//             internalType: 'bytes32',
//             name: 'sigR',
//             type: 'bytes32',
//           },
//           {
//             internalType: 'bytes32',
//             name: 'sigS',
//             type: 'bytes32',
//           },
//           {
//             internalType: 'uint8',
//             name: 'sigV',
//             type: 'uint8',
//           },
//         ],
//         name: 'verify',
//         outputs: [
//           {
//             internalType: 'bool',
//             name: '',
//             type: 'bool',
//           },
//         ],
//         stateMutability: 'view',
//         type: 'function',
//       },
//       {
//         inputs: [
//           {
//             internalType: 'address',
//             name: '_token',
//             type: 'address',
//           },
//           {
//             internalType: 'address',
//             name: '_to',
//             type: 'address',
//           },
//           {
//             internalType: 'uint256',
//             name: '_amount',
//             type: 'uint256',
//           },
//         ],
//         name: 'withdrawAsset',
//         outputs: [],
//         stateMutability: 'nonpayable',
//         type: 'function',
//       },
//       {
//         stateMutability: 'payable',
//         type: 'receive',
//       },
//     ];
//     this.interface = new ethers.utils.Interface(this.ABI);
//     // this.productIds = [4, 58]; // hardcoded at the moment - for mainnet testing
//     // this.coverDays = [30, 60];  // for mainnet testing
//     // this.coverAmounts = ['500000000000000000', '800000000000000000']; // for mainnet testing

//     this.productIds = [57]; // for rinkeby testing
//     this.coverDays = [30]; // for rinkeby testing
//     this.coverAmounts = ['500000000000000000']; // for rinkeby testing

//     this.coverCurrency = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
//     this.referralCode = null;

//     this.cvr = await (await this.MockERC20.deploy('CVR', 'CVR')).deployed();

//     this.mockUSDC = await (await this.MockERC20.deploy('USDC', 'USDC')).deployed();

//     this.exchangeAgent = await this.ExchangeAgent.deploy(this.mockUSDC.address, WETH, UNISWAPV2_FACTORY, TWAP_ORACLE_PRICE_FEED_FACTORY);

//     this.cvrETHPair = await createPairETH(
//       UNISWAPV2_ROUTER,
//       UNISWAPV2_FACTORY,
//       this.cvr.address,
//       getBigNumber(5000),
//       getBigNumber(10),
//       this.signers[0].address,
//       this.signers[0]
//     );

//     await ethers.provider.send('eth_sendTransaction', [
//       { from: this.signers[10].address, to: this.exchangeAgent.address, value: getBigNumber(10).toHexString() },
//     ]);

//     this.twapOracleFactory = new ethers.Contract(TWAP_ORACLE_PRICE_FEED_FACTORY, TWAP_PRICE_FACTORY_ABI, ethers.provider);

//     await (
//       await this.twapOracleFactory.connect(this.signers[0]).newTwapOraclePriceFeed(this.cvr.address, WETH, { from: this.signers[0].address })
//     ).wait();

//     await this.exchangeAgent.addCurrency(this.cvr.address);
//   });

//   beforeEach(async function () {
//     this.insureAcePolka = await (
//       await this.InsureAcePolka.deploy(
//         this.cvr.address, // @todo should be changed CVR
//         this.exchangeAgent.address, // @todo should be changed ExcahngeAgent
//         this.coverContractAddress
//       )
//     ).deployed();

//     await this.exchangeAgent.addWhiteList(this.insureAcePolka.address);
//   });

//   it('Shoud be able to send transaction successfully', async () => {
//     let nonce = await this.insureAcePolka.getNonce(this.signers[0].address);

//     const premiumInfo = await getCoverPremium(this.chainId, {
//       chain: this.chain,
//       productIds: this.productIds,
//       coverDays: this.coverDays,
//       coverAmounts: this.coverAmounts,
//       coverCurrency: this.coverCurrency,
//       owner: this.coverOwner,
//       referralCode: this.referralCode,
//     });
//     console.log('2. Confirming cover premium');
//     const confirmInfo = await confirmCoverPremium(this.chainId, {
//       chain: this.chain,
//       params: premiumInfo.params,
//     });
//     const params = confirmInfo.params;

//     const functionSignature = this.interface.encodeFunctionData('buyCoverByToken', [
//       params[0],
//       params[1],
//       params[2],
//       params[3],
//       params[4],
//       params[5],
//       params[6],
//       params[7],
//       params[8],
//       params[9],
//       params[10],
//       params[11],
//     ]);

//     const messageToSign = await ethers.utils.soliditySha256(
//       ['uint256', 'address', 'uint256', 'bytes'],
//       [nonce.toNumber(), testContract.address, networkId, toBuffer(functionSignature)]
//     );
//     const signature = await this.signers[0].signMessage(messageToSign);
//     signature = signature.signature;
//     const r = signature.slice(0, 66);
//     const s = '0x'.concat(signature.slice(66, 130));
//     const v = '0x'.concat(signature.slice(130, 132));
//     v = web3.utils.hexToNumber(v);
//     if (![27, 28].includes(v)) v += 27;

//     await expect(this.insureAcePolkal.executeMetaTransaction(this.signers[0].address, functionSignature, r, s, v))
//       .to.emit(this.insureAcePolka, 'BuyInsureAce')
//       .withArgs(this.productIds, this.signers[0].address, this.coverCurrency, premiumInfo.premium);

//     await expect(this.insureAcePolka.getNonce(this.signers[0].address)).to.be.equal(BigNumber.from(nonce).add(1));
//   });

//   // it('Should get data from InsureAce API', async function () {
//   //   // console.log('1. Getting premium...');
//   //   // const premiumInfo = await getCoverPremium(this.chainId, {
//   //   //   chain: this.chain,
//   //   //   productIds: this.productIds,
//   //   //   coverDays: this.coverDays,
//   //   //   coverAmounts: this.coverAmounts,
//   //   //   coverCurrency: this.coverCurrency,
//   //   //   owner: this.coverOwner,
//   //   //   referralCode: this.referralCode
//   //   // });
//   //   // console.log('2. Confirming cover premium');
//   //   // const confirmInfo = await confirmCoverPremium(this.chainId, {
//   //   //   chain: this.chain,
//   //   //   params: premiumInfo.params,
//   //   // });
//   //   // console.log(`confirmInfo ${JSON.stringify(confirmInfo)}`);
//   // });

//   // it('Should buy product By ETH', async function () {
//   //   // console.log('1. Getting premium...');
//   //   // const premiumInfo = await getCoverPremium(this.chainId, {
//   //   //   chain: this.chain,
//   //   //   productIds: this.productIds,
//   //   //   coverDays: this.coverDays,
//   //   //   coverAmounts: this.coverAmounts,
//   //   //   coverCurrency: this.coverCurrency,
//   //   //   owner: this.coverOwner,
//   //   //   referralCode: this.referralCode,
//   //   // });
//   //   // console.log('2. Confirming cover premium');
//   //   // const confirmInfo = await confirmCoverPremium(this.chainId, {
//   //   //   chain: this.chain,
//   //   //   params: premiumInfo.params,
//   //   // });
//   //   // const params = confirmInfo.params;
//   //   // console.log('current block', await ethers.provider.getBlockNumber());
//   //   // console.log('target block', params[8], parseInt(params[8][0]) + 2);
//   //   // await advanceBlockTo(parseInt(params[8][0]) + 2);
//   //   // await expect(
//   //   //   this.insureAcePolka.buyCoverByETH(
//   //   //     params[0],
//   //   //     params[1],
//   //   //     params[2],
//   //   //     params[3],
//   //   //     params[4],
//   //   //     params[5],
//   //   //     params[6],
//   //   //     params[7],
//   //   //     params[8],
//   //   //     params[9],
//   //   //     params[10],
//   //   //     params[11],
//   //   //     { value: premiumInfo.premium }
//   //   //   )
//   //   // )
//   //   //   .to.emit(this.insureAcePolka, 'BuyInsureAce')
//   //   //   .withArgs(this.productIds, this.signers[0].address, this.coverCurrency, premiumInfo.premium);
//   // });

//   it('Should buy product by token', async function () {
//     const premiumInfo = await getCoverPremium(this.chainId, {
//       chain: this.chain,
//       productIds: this.productIds,
//       coverDays: this.coverDays,
//       coverAmounts: this.coverAmounts,
//       coverCurrency: this.coverCurrency,
//       owner: this.coverOwner,
//       referralCode: this.referralCode,
//     });
//     console.log('2. Confirming cover premium');
//     const confirmInfo = await confirmCoverPremium(this.chainId, {
//       chain: this.chain,
//       params: premiumInfo.params,
//     });
//     const params = confirmInfo.params;
//     await this.cvr.approve(this.insureAcePolka.address, getBigNumber(10000000000));
//     console.log('current block', await ethers.provider.getBlockNumber());
//     console.log('target block', params[8], parseInt(params[8][0]) + 2);
//     await advanceBlockTo(parseInt(params[8][0]) + 2);
//     await expect(
//       this.insureAcePolka.buyCoverByToken(
//         params[0],
//         params[1],
//         params[2],
//         params[3],
//         params[4],
//         params[5],
//         params[6],
//         params[7],
//         params[8],
//         params[9],
//         params[10],
//         params[11]
//       )
//     )
//       .to.emit(this.insureAcePolka, 'BuyInsureAce')
//       .withArgs(this.productIds, this.signers[0].address, this.coverCurrency, premiumInfo.premium);
//   });
// });
