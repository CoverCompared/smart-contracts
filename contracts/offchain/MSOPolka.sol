// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BasePolkaOffChain.sol";

contract MSOPolka is Ownable, ReentrancyGuard, BasePolkaOffChain {
    using Counters for Counters.Counter;

    event BuyMSO(uint256 indexed _productId, address _buyer, address _currency, uint256 _amount, uint256 _priceInUSD, bool _concierge);

    struct Product {
        string productName;
        uint256 priceInUSD;
        uint256 period;
        uint256 startTime;
        bool concierge;
    }

    mapping(uint256 => Product) public products; // productId => product
    uint256 public conciergePrice;

    constructor(
        address _WETH,
        uint256 _conciergePrice,
        address _exchangeAgent,
        address _devWallet
    ) BasePolkaOffChain(_WETH, _exchangeAgent, _devWallet) {
        conciergePrice = _conciergePrice;
    }

    /**
     * @dev buyProduct function:
     * @param period - it can be 1 month or 1 year at the moment
     */
    function buyProduct(
        string memory productName,
        uint256 priceInUSD,
        uint256 period,
        address _token,
        bool concierge
    ) external payable nonReentrant {
        uint256 _pid = productIds.current();
        uint256 usdPrice = concierge ? priceInUSD + conciergePrice : priceInUSD;
        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenUSDPrice(_token, usdPrice);

        if (_token == WETH) {
            require(msg.value >= tokenAmount, "Insufficient amount");
            if (msg.value > tokenAmount) {
                TransferHelper.safeTransferETH(msg.sender, msg.value - tokenAmount);
            }
        } else {
            TransferHelper.safeTransferFrom(_token, msg.sender, devWallet, tokenAmount);
        }

        products[_pid] = Product({
            productName: productName,
            priceInUSD: usdPrice,
            period: period, startTime: block.timestamp, concierge: concierge});

        _setProductOwner(_pid, msg.sender);
        _increaseBalance(msg.sender);
        _buyProduct(msg.sender, _pid);

        productIds.increment();

        emit BuyMSO(_pid, msg.sender, _token, tokenAmount, usdPrice, concierge);
    }
}
