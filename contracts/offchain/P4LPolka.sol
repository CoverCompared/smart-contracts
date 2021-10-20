// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BasePolkaOffChain.sol";

contract P4L is Ownable, ReentrancyGuard, BasePolkaOffChain {
    event BuyP4L(uint256 indexed _productId, address _buyer, address _currency, uint256 _amount, uint256 _priceInUSD);

    using Counters for Counters.Counter;

    struct Product {
        uint256 startTime;
        uint128 priceInUSD; // price in USD
        uint128 durPlan;
        uint64 purchMonth;
        string device;
        string brand;
    }

    mapping(uint256 => Product) public products; // productId => product

    constructor(
        address _WETH,
        address _exchangeAgent,
        address _devWallet
    ) BasePolkaOffChain(_WETH, _exchangeAgent, _devWallet) {}

    /**
     * @dev buyProductETH function:
     * this function should be called from user directly
     */
    function buyProductByETH(
        string memory _device,
        string memory _brand,
        uint256 _value,
        uint256 _purchMonth,
        uint256 _durPlan,
        bytes memory sig
    ) external payable nonReentrant {
        bytes32 digest = getSignedMsgHash(_device, _brand, _value, _purchMonth, _durPlan);
        permit(msg.sender, digest, sig);
        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenAmountForUSDC(WETH, _value);

        require(msg.value >= tokenAmount, "Insufficient amount");
        if (msg.value > tokenAmount) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - tokenAmount);
        }
        TransferHelper.safeTransferETH(devWallet, tokenAmount);

        uint256 _pid = buyProduct(uint128(_value), uint128(_durPlan), uint64(_purchMonth), _device, _brand, msg.sender);
        emit BuyP4L(_pid, msg.sender, WETH, tokenAmount, _value);
    }

    /**
     * @dev buyProductByToken: Users can buy products using ERC20 tokens such as CVR and without gas fee
     */
    function buyProductByToken(
        string memory _device,
        string memory _brand,
        uint256 _value,
        uint256 _purchMonth,
        uint256 _durPlan,
        address _token,
        address _sender,
        bytes memory sig
    ) external nonReentrant onlyAvailableToken(_token) {
        bytes32 digest = getSignedMsgHash(_device, _brand, _value, _purchMonth, _durPlan);
        permit(_sender, digest, sig);

        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenAmountForUSDC(_token, _value);
        TransferHelper.safeTransferFrom(_token, _sender, devWallet, tokenAmount);
        uint256 _pid = buyProduct(uint128(_value), uint128(_durPlan), uint64(_purchMonth), _device, _brand, _sender);

        emit BuyP4L(_pid, _sender, _token, tokenAmount, _value);
    }

    function buyProduct(
        uint128 _value,
        uint128 _durPlan,
        uint64 _purchMonth,
        string memory _device,
        string memory _brand,
        address _sender
    ) private returns (uint256 _pid) {
        _pid = productIds.current();
        products[_pid] = Product({
            priceInUSD: _value, // price in USD
            purchMonth: _purchMonth,
            durPlan: _durPlan,
            startTime: block.timestamp,
            device: _device,
            brand: _brand
        });
        _setProductOwner(_pid, _sender);
        _increaseBalance(_sender);
        _buyProduct(_sender, _pid);
        productIds.increment();
    }

    function getSignedMsgHash(
        string memory _device,
        string memory _brand,
        uint256 _value,
        uint256 _purchMonth,
        uint256 _durPlan
    ) internal pure returns (bytes32) {
        bytes32 msgHash = keccak256(abi.encodePacked(_device, _brand, _value, _purchMonth, _durPlan));
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
    }
}
