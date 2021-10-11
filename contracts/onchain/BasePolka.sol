// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasePolka {
    event PurchasedProduct(
        address indexed _partner,
        string _name,
        uint256 _productId,
        address _user,
        address _currency,
        uint256 _price
    );
}
