// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IExchangeAgent {
    function getTokenUSDPrice(address _token, uint256 _desiredUSD) external view returns (uint256);

    function swapCVRWithETH(uint256 amount) external;
}
