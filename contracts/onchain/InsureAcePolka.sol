// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {IInsureAce} from "../interfaces/IInsureAce.sol";
import "../libs/TransferHelper.sol";
import "./BasePolkaOnChain.sol";

import "hardhat/console.sol";

contract InsureAcePolka is BasePolkaOnChain {
    address public coverContractAddress;

    constructor(
        address _CVR,
        address _exchangeAgent,
        address _coverContractAddress
    ) BasePolkaOnChain(_CVR, _exchangeAgent) {
        require(_coverContractAddress != address(0), "S:1");
        coverContractAddress = _coverContractAddress;
    }

    function setup(address _coverContractAddress) external onlyOwner {
        require(_coverContractAddress != address(0), "S:1");
        coverContractAddress = _coverContractAddress;
    }

    function buyCoverByETH(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address owner,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable {
        require(msg.value >= premiumAmount, "Insufficient amount");
        if (msg.value - premiumAmount > 0) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - premiumAmount);
        }

        IInsureAce(coverContractAddress).buyCover{value: premiumAmount}(
            products,
            durationInDays,
            amounts,
            currency,
            owner,
            referralCode,
            premiumAmount,
            helperParameters,
            securityParameters,
            v,
            r,
            s
        );

        // emit PurchasedProduct(coverContractAddress, "InsureAce", 0, msg.sender, currency, premiumAmount);
    }

    // function buyCoverByToken(
    //     uint16[] memory products,
    //     uint16[] memory durationInDays,
    //     uint256[] memory amounts,
    //     address currency,
    //     address owner,
    //     uint256 referralCode,
    //     uint256 premiumAmount,
    //     uint256[] memory helperParameters,
    //     uint256[] memory securityParameters,
    //     uint8[] memory v,
    //     bytes32[] memory r,
    //     bytes32[] memory s
    // ) external {
    //     // ensure you have enough premium in current contract as the coverContract will utilize
    //     // safeTransferFrom for ERC20 token or
    //     // check msg.value in case you are using native token
    //     TransferHelper.safeTransferFrom(currency, owner, address(this), premiumAmount);
    //     TransferHelper.safeApprove(currency, coverContractAddress, premiumAmount);

    //     // IInsureAce(coverContractAddress).buyCover(
    //     //     products,
    //     //     durationInDays,
    //     //     amounts,
    //     //     currency,
    //     //     owner,
    //     //     referralCode,
    //     //     premiumAmount,
    //     //     helperParameters,
    //     //     securityParameters,
    //     //     v,
    //     //     r,
    //     //     s
    //     // );

    //     address tmp = IInsureAce(coverContractAddress).data();

    //     // emit PurchasedProduct(coverContractAddress, "InsureAce", 0, msg.sender, currency, premiumAmount);
    // }
}
