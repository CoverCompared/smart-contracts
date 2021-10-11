// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BasePolkaOffChain.sol";

contract P4L is Ownable, ReentrancyGuard, BasePolkaOffChain {
    using Counters for Counters.Counter;

    struct Product {
        uint256 priceInUSD; // price in USD
        uint256 purchMonth;
        uint256 durPlan;
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
     * @dev buyProduct function:
     */
    function buyProduct(
        string calldata _device,
        string calldata _brand,
        uint256 _value,
        uint256 _purchMonth,
        uint256 _durPlan,
        address _token,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        uint256 _pid = productIds.current();
        bytes32 digest = getSignedMsgHash(_device, _brand, _value, _purchMonth, _durPlan);
        permit(msg.sender, digest, v, r, s);
        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenUSDPrice(_token, _value);
    
        if(_token == WETH) {
            require(msg.value >= tokenAmount, "Insufficient amount");
            if (msg.value > tokenAmount) {
                TransferHelper.safeTransferETH(msg.sender, msg.value - tokenAmount);
            }
        } else {
            TransferHelper.safeTransferFrom(_token, msg.sender, address(this), tokenAmount);
        }

        products[_pid] = Product({
            priceInUSD: _value, // price in USD
            purchMonth: _purchMonth,
            durPlan: _durPlan,
            device: _device,
            brand: _brand
        });
        _setProductOwner(_pid, msg.sender);
        _increaseBalance(msg.sender);
        _buyProduct(msg.sender, _pid);

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
