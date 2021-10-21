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
    address public nexusGateWay;

    constructor(
        address _WETH,
        address _CVR,
        address _exchangeAgent,
        address _nexusGateWay
    ) BasePolkaOnChain(_WETH, _CVR, _exchangeAgent) {
        nexusGateWay = _nexusGateWay;
    }

    function getProductPrice(
        address _distributor,
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        bytes calldata data
    ) public view returns (uint256) {
        uint256 coverPrice = INexusMutualGateway(nexusGateWay).getCoverPrice(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            INexusMutualGateway.CoverType(coverType),
            data
        );
        uint256 _feePercentage = INexusMutual(_distributor).feePercentage();
        uint256 coverPriceWithFee = (_feePercentage * coverPrice) / 10000 + coverPrice;

        return coverPriceWithFee;
    }

    /**
     * User will buy product directly using his ETH
     */
    function buyCoverByETH(
        address _distributor,
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external payable {
        address _weth = INexusMutual(_distributor).WETH();
        require(coverAsset == _weth, "Should pay in ETH");
        uint256 productPrice = getProductPrice(
            _distributor,
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            data
        );

        require(msg.value >= productPrice, "Insufficient amount");
        if (msg.value > productPrice) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - productPrice);
        }

        uint256 productId = INexusMutual(_distributor).buyCover{value: productPrice}(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            maxPriceWithFee,
            data
        );

        buyCover(_distributor, productId);
    }

    // TODO check _token can be ETH?
    function buyCoverByToken(
        address _token,
        address _distributor,
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external onlyAvailableToken(_token) {
        uint256 productPrice = getProductPrice(
            _distributor,
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            data
        );

        uint256 amount;
        uint256 value;
        if (coverAsset == INexusMutual(_distributor).WETH()) {
            amount = IExchangeAgent(exchangeAgent).getTokenAmountForETH(_token, productPrice);
            TransferHelper.safeTransferFrom(_token, msg.sender, address(this), amount);
            TransferHelper.safeApprove(_token, exchangeAgent, amount);
            IExchangeAgent(exchangeAgent).swapTokenWithETH(_token, amount);
            value = productPrice;
        } else {
            amount = IExchangeAgent(exchangeAgent).getNeededTokenAmount(_token, coverAsset, productPrice);
            TransferHelper.safeTransferFrom(_token, msg.sender, address(this), amount);
            TransferHelper.safeApprove(_token, exchangeAgent, amount);
            IExchangeAgent(exchangeAgent).swapTokenWithToken(_token, coverAsset, amount);
        }

        uint256 productId = INexusMutual(_distributor).buyCover{value: productPrice}(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            maxPriceWithFee,
            data
        );

        buyCover(_distributor, productId);
    }

    function buyCover(address _distributor, uint256 productId) private {
        _setProductOwner(productId, msg.sender);
        _increaseBalance(msg.sender);
        _buyProduct(msg.sender, productId);

        // Transfer ERC721 to msg.sender
        IERC721(_distributor).transferFrom(address(this), msg.sender, productId);
        // emit PurchasedProduct(_distributor, "NexusMutual", productId, msg.sender, coverAsset, coverPrice);
    }
}
