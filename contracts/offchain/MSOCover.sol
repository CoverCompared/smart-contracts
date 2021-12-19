// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BaseCoverOffChain.sol";

contract MSOCover is Ownable, ReentrancyGuard, BaseCoverOffChain {
    using Counters for Counters.Counter;

    event BuyMSO(
        uint256 indexed _productId,
        uint256 _amount,
        uint256 _priceInUSD,
        uint256 _conciergePrice,
        address _buyer,
        address _currency
    );

    struct Product {
        string policyId;
        uint256 priceInUSD;
        uint256 period;
        uint256 startTime;
        uint256 conciergePrice;
    }

    mapping(uint256 => Product) public products; // productId => product

    constructor(
        address _WETH,
        address _exchangeAgent,
        address _devWallet
    ) BaseCoverOffChain(_WETH, _exchangeAgent, _devWallet) {}

    /**
     * @dev buyProductByETH function:
     */
    function buyProductByETH(
        string memory policyId,
        uint256 priceInUSD,
        uint256 period,
        uint256 conciergePrice,
        bytes memory sig
    ) external payable nonReentrant {
        uint256 usdPrice = priceInUSD + conciergePrice;

        bytes32 digest = getSignedMsgHash(policyId, priceInUSD, period, conciergePrice);
        permit(msg.sender, digest, sig);

        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getETHAmountForUSDC(usdPrice);
        require(msg.value >= tokenAmount, "Insufficient amount");
        if (msg.value > tokenAmount) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - tokenAmount);
        }
        TransferHelper.safeTransferETH(devWallet, tokenAmount);

        uint256 _pid = buyProduct(policyId, priceInUSD, period, conciergePrice, msg.sender);

        emit BuyMSO(_pid, tokenAmount, priceInUSD, conciergePrice, msg.sender, WETH);
    }

    /**
     * @dev buyProductByToken function:
     */
    function buyProductByToken(
        string calldata policyId,
        uint256 priceInUSD,
        uint256 period,
        address _token,
        uint256 conciergePrice,
        bytes memory sig
    ) external nonReentrant onlyAvailableToken(_token) {
        uint256 usdPrice = priceInUSD + conciergePrice;

        bytes32 digest = getSignedMsgHash(policyId, priceInUSD, period, conciergePrice);
        permit(msg.sender, digest, sig);

        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenAmountForUSDC(_token, usdPrice);
        TransferHelper.safeTransferFrom(_token, msg.sender, devWallet, tokenAmount);

        uint256 _pid = buyProduct(policyId, priceInUSD, period, conciergePrice, msg.sender);
        emit BuyMSO(_pid, tokenAmount, priceInUSD, conciergePrice, msg.sender, _token);
    }

    function buyProduct(
        string memory _policyId,
        uint256 priceInUSD,
        uint256 period,
        uint256 conciergePrice,
        address _sender
    ) private returns (uint256 _pid) {
        _pid = productIds.current();
        products[_pid] = Product({
            policyId: _policyId,
            priceInUSD: priceInUSD,
            period: period,
            startTime: block.timestamp,
            conciergePrice: conciergePrice
        });

        _setProductOwner(_pid, _sender);
        _increaseBalance(_sender);
        _buyProduct(_sender, _pid);
        productIds.increment();
    }

    function getSignedMsgHash(
        string memory productName,
        uint256 priceInUSD,
        uint256 period,
        uint256 conciergePrice
    ) internal pure returns (bytes32) {
        bytes32 msgHash = keccak256(abi.encodePacked(productName, priceInUSD, period, conciergePrice));
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
    }
}
