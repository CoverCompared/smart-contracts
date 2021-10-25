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

    // TODO it should be EnumerableSet
    mapping(address => bool) public availableCurrencies;

    address public immutable WETH;
    // TODO should it be public?
    address public exchangeAgent;
    address public devWallet;

    constructor(
        address _WETH,
        address _exchangeAgent,
        address _devWallet,
        address _multiSigWallet
    ) {
        WETH = _WETH;
        exchangeAgent = _exchangeAgent;
        devWallet = _devWallet;
        transferOwnership(_multiSigWallet);
    }

    modifier onlyAvailableToken(address _token) {
        require(availableCurrencies[_token], "Not allowed token");
        _;
    }

    receive() external payable {}

    function _setProductOwner(uint256 _prodId, address _owner) internal {
        _ownerOf[_prodId] = _owner;
    }

    function ownerOf(uint256 _prodId) public view returns (address) {
        require(_prodId < productIds.current() + 1, "Invalid product ID");
        return _ownerOf[_prodId];
    }

    function _increaseBalance(address _account) internal {
        _balanceOf[_account]++;
    }

    function balanceOf(address _account) public view returns (uint64) {
        return _balanceOf[_account];
    }

    function _buyProduct(address _buyer, uint256 _pid) internal {
        _productsOf[_buyer].push(uint64(_pid));
        emit BuyProduct(_pid, _buyer);
    }

    function productOf(address _owner, uint64 _idx) public view returns (uint64) {
        return _productsOf[_owner][_idx];
    }

    function addCurrency(address _currency) external onlyOwner {
        require(!availableCurrencies[_currency], "Already available");
        availableCurrencies[_currency] = true;
    }

    function removeCurrency(address _currency) external onlyOwner {
        require(availableCurrencies[_currency], "Not available yet");
        availableCurrencies[_currency] = false;
    }

    function permit(
        address _sender,
        bytes32 _digest,
        bytes memory sig
    ) internal pure virtual {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(sig);
        address recoveredAddress = ecrecover(_digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == _sender, "PolkaCompare: INVALID_SIGNATURE");
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
