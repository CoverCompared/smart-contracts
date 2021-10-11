// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";

contract MSOPolka_copy is Ownable {
    event AddedType(uint256 indexed typeId);
    event UpdatedType(uint256 indexed typeId);
    event BuyProduct(uint256 indexed _productId, address _buyer, address _currency, uint256 _amount, uint256 _priceInUSD);

    using Counters for Counters.Counter;

    struct ProductType {
        uint256 priceInUSD;
        string productName;
    }

    struct Product {
        uint256 period;
        uint256 startTime;
        uint16 typeId;
        bool concierge;
    }

    mapping(uint256 => ProductType) public productTypes;
    Counters.Counter public productTypeIds;

    Counters.Counter public productIds;
    mapping(uint256 => Product) public products; // productId => product
    mapping(uint256 => address) private _ownerOf; // productId => owner
    mapping(address => uint64) private _balanceOf; // owner => balance We can think one user can buy max 2**64 products
    mapping(address => uint64[]) private _productsOf; // owner => productIds[]

    address public immutable WETH;
    uint256 public conciergePrice;
    // TODO should it be public?
    address public exchangeAgent;
    address public devWallet;

    constructor(
        address _WETH,
        uint256 _conciergePrice,
        address _exchangeAgent,
        address _devWallet
    ) {
        WETH = _WETH;
        conciergePrice = _conciergePrice;
        exchangeAgent = _exchangeAgent;
        devWallet = _devWallet;
    }

    function ownerOf(uint256 _prodId) public view returns (address) {
        return _ownerOf[_prodId];
    }

    function balanceOf(address _owner) public view returns (uint64) {
        return _balanceOf[_owner];
    }

    function productOf(address _owner, uint64 _idx) public view returns (uint64) {
        return _productsOf[_owner][_idx];
    }

    function addProduct(uint256 _price, string calldata _name) external onlyOwner {
        uint256 _typeId = productTypeIds.current();
        productTypes[_typeId] = ProductType({priceInUSD: _price, productName: _name});
        productTypeIds.increment();
        emit AddedType(_typeId);
    }

    function updateProduct(
        uint256 _typeId,
        uint256 _price,
        string calldata _name
    ) external onlyOwner {
        productTypes[_typeId] = ProductType({priceInUSD: _price, productName: _name});
        emit UpdatedType(_typeId);
    }

    /**
     * @dev buyProduct function:
     * @param period - it can be 1 month or 1 year at the moment
     */
    function buyProduct(
        uint256 _typeId,
        address _token,
        bool concierge,
        uint256 period
    ) external payable {
        uint256 _pid = productIds.current();
        uint256 usdPrice = concierge ? productTypes[_typeId].priceInUSD : productTypes[_typeId].priceInUSD + conciergePrice;
        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenUSDPrice(_token, usdPrice);

        if (_token == WETH) {
            require(msg.value >= tokenAmount, "Insufficient amount");
            if (msg.value > tokenAmount) {
                TransferHelper.safeTransferETH(msg.sender, msg.value - tokenAmount);
            }
        } else {
            TransferHelper.safeTransferFrom(_token, msg.sender, devWallet, tokenAmount);
        }
        // if
        products[_pid] = Product({period: period, startTime: block.timestamp, typeId: uint16(_typeId), concierge: concierge});
        _ownerOf[_pid] = msg.sender;
        _balanceOf[msg.sender]++;
        _productsOf[msg.sender].push(uint64(_pid));

        productIds.increment();

        emit BuyProduct(_pid, msg.sender, _token, tokenAmount, usdPrice);
    }
}
