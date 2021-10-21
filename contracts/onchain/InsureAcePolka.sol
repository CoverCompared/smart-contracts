// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {IInsureAce} from "../interfaces/IInsureAce.sol";
import "./BasePolkaOnChain.sol";

contract BuyCoverExample is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    function initializeLocalBuyCoverExample() public initializer {
        __Ownable_init();
    }

    address public coverContractAddress;

    function setup(address _coverContractAddress) external onlyOwner {
        require(_coverContractAddress != address(0), "S:1");
        coverContractAddress = _coverContractAddress;
    }

    function myOwnBuyCoverFunc(
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
        require(coverContractAddress != address(0), "myOwnBuyCoverFunc:1");

        // ensure you have enough premium in current contract as the coverContract will utilize
        // safeTransferFrom for ERC20 token or
        // check msg.value in case you are using native token
        // TODO how much should user pay? what does param show it?

        IInsureAce(coverContractAddress).buyCover(
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
}
