// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasePolkaOffChain is Ownable {
    using Counters for Counters.Counter;

    event BuyProduct(uint256 indexed _productId, address _buyer);
    
    Counters.Counter public productIds;
    mapping(uint256 => address) private _ownerOf; // productId => owner
    mapping(address => uint64) private _balanceOf; // owner => balance We can think one user can buy max 2**64 products
    mapping(address => uint64[]) private _productsOf; // owner => productIds[]

    address public immutable WETH;
    // TODO should it be public?
    address public exchangeAgent;
    address public devWallet;

    constructor(
        address _WETH,
        address _exchangeAgent,
        address _devWallet
    ) {
        WETH = _WETH;
        exchangeAgent = _exchangeAgent;
        devWallet = _devWallet;
    }

    function _setProductOwner(uint _prodId, address _owner) internal {
        _ownerOf[_prodId] = _owner;
    }

    function ownerOf(uint _prodId) public view returns (address) {
        return _ownerOf[_prodId];
    }

    function _increaseBalance(address _account) internal {
        _balanceOf[_account]++;
    }

    function balanceOf(address _account) public view returns (uint64) {
        return _balanceOf[_account];
    }

    function _buyProduct(address _buyer, uint _pid) internal {
        require(_pid < productIds.current(), "Invalid product ID");
        _productsOf[_buyer].push(uint64(_pid));
        emit BuyProduct(_pid, _buyer);
    }

    function productOf(address _owner, uint64 _idx) public view returns (uint64) {
        return _productsOf[_owner][_idx];
    }

    function permit(
        address _sender,
        bytes32 _digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure virtual {
        address recoveredAddress = ecrecover(_digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == _sender, "PolkaCompare: INVALID_SIGNATURE");
    }
}
