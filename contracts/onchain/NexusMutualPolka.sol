// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import ""
import "./BasePolka.sol";
import {INexusMutual} from "../interfaces/INexusMutual.sol";
import {INexusMutualGateway} from "../interfaces/INexusMutualGateway.sol";

contract NexusMutualPolka is BasePolka {
    address public nexusGateWay;

    constructor(address _nexusGateWay) {
        nexusGateWay = _nexusGateWay;
    }

    function buyCover(
        address _distributor,
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external payable {
        uint256 coverPrice = INexusMutualGateway(nexusGateWay).getCoverPrice(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            INexusMutualGateway.CoverType(coverType),
            data
        );
        uint256 productId = INexusMutual(_distributor).buyCover(
            contractAddress,
            coverAsset,
            sumAssured,
            coverPeriod,
            coverType,
            maxPriceWithFee,
            data
        );
        // TODO we should check cover price and should retain remain dust

        emit PurchasedProduct(_distributor, "NexusMutual", productId, msg.sender, coverAsset, coverPrice);
    }
}
