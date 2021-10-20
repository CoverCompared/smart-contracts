// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface INexusMutual {
    function buyCover(
        address contractAddress,
        address coverAsset,
        uint256 sumAssured,
        uint16 coverPeriod,
        uint8 coverType,
        uint256 maxPriceWithFee,
        bytes calldata data
    ) external payable returns (uint256);

    function WETH() external view returns (address);

    function feePercentage() external view returns (uint256);
}
