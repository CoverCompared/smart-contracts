// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {INexusMutual} from "../interfaces/INexusMutual.sol";
import {INexusMutualGateway} from "../interfaces/INexusMutualGateway.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BasePolkaOnChain.sol";

contract NexusMutualPolka is ERC721Holder, BasePolkaOnChain {
    // event BuyNexusMutual(address indexed distributor, uint256 indexed pid, address converAsset, uint price, address _buyToken, uint _tokenAmount);
    event BuyNexusMutual(uint256 indexed pid, address _buyToken, uint256 _tokenAmount);

    /** TODO if it is immutable?  */
    address public immutable distributor;

    constructor(
        address _CVR,
        address _exchangeAgent,
        address _distributor
    ) BasePolkaOnChain(_CVR, _exchangeAgent) {
        distributor = _distributor;
    }

    /**
     * @dev return maxPriceWithFee value
     */
    function getProductPrice(
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        bytes calldata data
    ) public view returns (uint256) {
        address nexusGateWay = INexusMutual(distributor).gateway();
        uint256 coverPrice = INexusMutualGateway(nexusGateWay).getCoverPrice(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            INexusMutualGateway.CoverType(coverType),
            data
        );
        uint256 _feePercentage = INexusMutual(distributor).feePercentage();
        uint256 coverPriceWithFee = (_feePercentage * coverPrice) / 10000 + coverPrice;

        return coverPriceWithFee;
    }

    /**
     * @dev User will buy product directly using his ETH
     */
    function buyCoverByETH(
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external payable {
        address _weth = INexusMutual(distributor).ETH();
        require(coverAsset == _weth, "Should pay in ETH");
        uint256 productPrice = getProductPrice(contractAddress, coverAsset, sumAssured, coverPeriod, coverType, data);

        require(msg.value >= productPrice, "Insufficient amount");
        if (msg.value > productPrice) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - productPrice);
        }

        uint256 productId = INexusMutual(distributor).buyCover{value: productPrice}(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            maxPriceWithFee,
            data
        );

        buyCover(productId);

        emit BuyNexusMutual(productId, coverAsset, productPrice);
    }

    function buyCoverByToken(
        address[] memory _assets, // _token, contractAddress, coverAsset
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external payable onlyAvailableToken(_assets[0]) {
        require(_assets.length == 3, "Assets param length should be 3");
        uint256 productPrice = getProductPrice(_assets[1], _assets[2], sumAssured, coverPeriod, coverType, data);

        uint256 amount;
        uint256 value;

        if (_assets[2] == INexusMutual(distributor).ETH()) {
            amount = IExchangeAgent(exchangeAgent).getTokenAmountForETH(_assets[0], productPrice);
            value = productPrice;
        } else {
            amount = IExchangeAgent(exchangeAgent).getNeededTokenAmount(_assets[0], _assets[2], productPrice);
        }

        TransferHelper.safeTransferFrom(_assets[0], msg.sender, address(this), amount);
        TransferHelper.safeApprove(_assets[0], exchangeAgent, amount);

        if (_assets[2] == INexusMutual(distributor).ETH()) {
            IExchangeAgent(exchangeAgent).swapTokenWithETH(_assets[0], amount, productPrice);
        } else {
            IExchangeAgent(exchangeAgent).swapTokenWithToken(_assets[0], _assets[2], amount, productPrice);
            TransferHelper.safeApprove(_assets[2], distributor, productPrice);
        }

        uint256 productId = INexusMutual(distributor).buyCover{value: value}(
            _assets[1],
            _assets[2],
            sumAssured,
            coverPeriod,
            coverType,
            maxPriceWithFee,
            data
        );

        buyCover(productId);
        emit BuyNexusMutual(productId, _assets[0], amount);
    }

    function buyCover(uint256 productId) private {
        IERC721(distributor).transferFrom(address(this), msg.sender, productId);
    }
}
