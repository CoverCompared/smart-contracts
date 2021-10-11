// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.0;

interface INexusMutualGateway {
    enum ClaimStatus {
        IN_PROGRESS,
        ACCEPTED,
        REJECTED
    }
    enum CoverType {
        SIGNED_QUOTE_CONTRACT_COVER
    }

    function getCoverPrice(
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        CoverType coverType,
        bytes calldata data
    ) external view returns (uint256 coverPrice);
}
