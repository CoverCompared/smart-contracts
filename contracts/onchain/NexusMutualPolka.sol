// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
// import {INexusMutual} from "../interfaces/INexusMutual.sol";
// import {INexusMutualGateway} from "../interfaces/INexusMutualGateway.sol";
// import "../interfaces/IExchangeAgent.sol";
// import "../libs/TransferHelper.sol";
// import "./BasePolkaOnChain.sol";

// contract NexusMutualPolka is ERC721Holder, BasePolkaOnChain {
//     address public nexusGateWay;

//     // event BuyNexusMutual(address indexed distributor, uint256 indexed pid, address converAsset, uint price, address _buyToken, uint _tokenAmount);
//     event BuyNexusMutual(address indexed distributor, uint256 indexed pid, address _buyToken, uint256 _tokenAmount);

//     constructor(
//         address _CVR,
//         address _exchangeAgent,
//         address _nexusGateWay
//     ) BasePolkaOnChain(_CVR, _exchangeAgent) {
//         nexusGateWay = _nexusGateWay;
//     }

//     function getProductPrice(
//         address _distributor,
//         address contractAddress,
//         address coverAsset,
//         uint256 sumAssured,
//         uint16 coverPeriod,
//         uint8 coverType,
//         bytes calldata data
//     ) public view returns (uint256) {
//         uint256 coverPrice = INexusMutualGateway(nexusGateWay).getCoverPrice(
//             contractAddress,
//             coverAsset,
//             sumAssured,
//             coverPeriod,
//             INexusMutualGateway.CoverType(coverType),
//             data
//         );
//         uint256 _feePercentage = INexusMutual(_distributor).feePercentage();
//         uint256 coverPriceWithFee = (_feePercentage * coverPrice) / 10000 + coverPrice;

//         return coverPriceWithFee;
//     }

//     /**
//      * @dev User will buy product directly using his ETH
//      */
//     function buyCoverByETH(
//         address _distributor,
//         address contractAddress,
//         address coverAsset,
//         uint256 sumAssured,
//         uint16 coverPeriod,
//         uint8 coverType,
//         uint256 maxPriceWithFee,
//         bytes calldata data
//     ) external payable {
//         address _weth = INexusMutual(_distributor).WETH();
//         require(coverAsset == _weth, "Should pay in ETH");
//         uint256 productPrice = getProductPrice(
//             _distributor,
//             contractAddress,
//             coverAsset,
//             sumAssured,
//             coverPeriod,
//             coverType,
//             data
//         );

//         require(msg.value >= productPrice, "Insufficient amount");
//         if (msg.value > productPrice) {
//             TransferHelper.safeTransferETH(msg.sender, msg.value - productPrice);
//         }

//         uint256 productId = INexusMutual(_distributor).buyCover{value: productPrice}(
//             contractAddress,
//             coverAsset,
//             sumAssured,
//             coverPeriod,
//             coverType,
//             maxPriceWithFee,
//             data
//         );

//         buyCover(_distributor, productId);

//         emit BuyNexusMutual(_distributor, productId, coverAsset, productPrice);
//     }

//     function buyCoverByToken(
//         address _distributor,
//         address[] memory _assets, // _token, contractAddress, coverAsset
//         uint256 sumAssured,
//         uint16 coverPeriod,
//         uint8 coverType,
//         uint256 maxPriceWithFee,
//         bytes calldata data
//     ) external onlyAvailableToken(_assets[0]) {
//         uint256 productPrice = getProductPrice(_distributor, _assets[1], _assets[2], sumAssured, coverPeriod, coverType, data);

//         uint256 amount;
//         uint256 value;

//         if (_assets[2] == INexusMutual(_distributor).WETH()) {
//             amount = IExchangeAgent(exchangeAgent).getTokenAmountForETH(_assets[0], productPrice);
//             value = productPrice;
//         } else {
//             amount = IExchangeAgent(exchangeAgent).getNeededTokenAmount(_assets[0], _assets[2], productPrice);
//         }

//         TransferHelper.safeTransferFrom(_assets[0], msg.sender, address(this), amount);
//         TransferHelper.safeApprove(_assets[0], exchangeAgent, amount);

//         if (_assets[2] == INexusMutual(_distributor).WETH()) {
//             IExchangeAgent(exchangeAgent).swapTokenWithETH(_assets[0], amount);
//         } else {
//             IExchangeAgent(exchangeAgent).swapTokenWithToken(_assets[0], _assets[2], amount);
//             TransferHelper.safeApprove(_assets[2], _distributor, productPrice);
//         }

//         uint256 productId = INexusMutual(_distributor).buyCover{value: value}(
//             _assets[1],
//             _assets[2],
//             sumAssured,
//             coverPeriod,
//             coverType,
//             maxPriceWithFee,
//             data
//         );

//         buyCover(_distributor, productId);
//         emit BuyNexusMutual(_distributor, productId, _assets[0], amount);
//     }

//     function buyCover(address _distributor, uint256 productId) private {
//         _setProductOwner(productId, msg.sender);
//         _increaseBalance(msg.sender);
//         _buyProduct(msg.sender, productId);

//         IERC721(_distributor).transferFrom(address(this), msg.sender, productId);
//     }
// }
