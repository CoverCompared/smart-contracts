// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import "../libs/TransferHelper.sol";
import "./BaseCoverOffChain.sol";

contract P4LCover is Ownable, ReentrancyGuard, BaseCoverOffChain {
    event BuyP4L(uint256 indexed _productId, address _buyer, address _currency, uint256 _amount, uint256 _priceInUSD);

    using Counters for Counters.Counter;

    struct Product {
        uint256 startTime;
        uint128 priceInUSD; // price in USD
        uint128 durPlan;
        string policyId;
    }

    mapping(uint256 => Product) public products; // productId => product

    constructor(
        address _WETH,
        address _exchangeAgent,
        address _devWallet,
        address _signer
    ) BaseCoverOffChain(_WETH, _exchangeAgent, _devWallet, _signer) {}

    /**
     * @dev buyProductETH function:
     * this function should be called from user directly
     */
    function buyProductByETH(
        string memory _policyId,
        uint256 _value, // price in USD
        uint256 _durPlan,
        bytes memory sig
    ) external payable nonReentrant whenNotPaused {
        bytes32 digest = getSignedMsgHash(_policyId, _value, _durPlan);
        permit(signer, digest, sig);
        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getETHAmountForUSDC(_value);

        require(msg.value >= tokenAmount, "Insufficient amount");
        if (msg.value > tokenAmount) {
            TransferHelper.safeTransferETH(msgSender(), msg.value - tokenAmount);
        }
        TransferHelper.safeTransferETH(devWallet, tokenAmount);

        uint256 _pid = buyProduct(uint128(_value), uint128(_durPlan), _policyId, msgSender());
        emit BuyP4L(_pid, msgSender(), WETH, tokenAmount, _value);
    }

    /**
     * @dev buyProductByToken: Users can buy products using ERC20 tokens such as CVR and without gas fee
     */
    function buyProductByToken(
        string memory _policyId,
        uint256 _value,
        uint256 _durPlan,
        address _token,
        bytes memory sig
    ) external nonReentrant whenNotPaused onlyAvailableToken(_token) {
        bytes32 digest = getSignedMsgHash(_policyId, _value, _durPlan);
        permit(signer, digest, sig);

        uint256 tokenAmount = IExchangeAgent(exchangeAgent).getTokenAmountForUSDC(_token, _value);
        TransferHelper.safeTransferFrom(_token, msgSender(), devWallet, tokenAmount);
        uint256 _pid = buyProduct(uint128(_value), uint128(_durPlan), _policyId, msgSender());
        emit BuyP4L(_pid, msgSender(), _token, tokenAmount, _value);
    }

    function buyProduct(
        uint128 _value,
        uint128 _durPlan,
        string memory _policyId,
        address _sender
    ) private returns (uint256 _pid) {
        _pid = productIds.current();
        products[_pid] = Product({
            startTime: block.timestamp,
            priceInUSD: _value, // price in USD
            durPlan: _durPlan,
            policyId: _policyId
        });
        _setProductOwner(_pid, _sender);
        _increaseBalance(_sender);
        _buyProduct(_sender, _pid);
        productIds.increment();
    }

    function getSignedMsgHash(
        string memory _policyId,
        uint256 _value,
        uint256 _durPlan
    ) internal pure returns (bytes32) {
        bytes32 msgHash = keccak256(abi.encodePacked(_policyId, _value, _durPlan));
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
    }
}
