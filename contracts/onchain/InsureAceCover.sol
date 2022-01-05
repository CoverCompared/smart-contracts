// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/IExchangeAgent.sol";
import {IInsureAce} from "../interfaces/IInsureAce.sol";
import "./BaseCoverOnChain.sol";

/**
 * We are supporting only CVR for InsureAce
 */
contract InsureAceCover is BaseCoverOnChain, ReentrancyGuard {
    event BuyInsureAce(uint16[] productIds, address _buyer, address _currency, address _token, uint256 _amount);

    address public coverContractAddress;
    // This is the WETH address of InsureAce smart contract
    address public constant WETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(
        address _CVR,
        address _exchangeAgent,
        address _coverContractAddress
    ) BaseCoverOnChain(_CVR, _exchangeAgent) {
        require(_coverContractAddress != address(0), "S:1");
        coverContractAddress = _coverContractAddress;
    }

    function setup(address _coverContractAddress) external onlyOwner {
        require(_coverContractAddress != address(0), "S:1");
        coverContractAddress = _coverContractAddress;
    }

    function buyETHCoverByETH(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable nonReentrant whenNotPaused {
        require(currency == WETH, "Should be ETH product");
        require(msg.value >= premiumAmount, "Insufficient amount");
        if (msg.value - premiumAmount > 0) {
            TransferHelper.safeTransferETH(msgSender(), msg.value - premiumAmount);
        }

        IInsureAce(coverContractAddress).buyCover{value: premiumAmount}(
            products,
            durationInDays,
            amounts,
            currency,
            msgSender(),
            referralCode,
            premiumAmount,
            helperParameters,
            securityParameters,
            v,
            r,
            s
        );

        emit BuyInsureAce(products, msgSender(), currency, currency, premiumAmount);
    }

    /**
     * @dev Through this function, users can get covers from Insure by some tokens such as CVR...
     */
    function buyETHCoverByToken(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address _token,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable nonReentrant whenNotPaused {
        require(currency == WETH, "Should be ETH product");
        uint256 amount = IExchangeAgent(exchangeAgent).getTokenAmountForETH(_token, premiumAmount);

        TransferHelper.safeTransferFrom(_token, msgSender(), address(this), amount);
        // TransferHelper.safeApprove(_token, exchangeAgent, amount);

        IExchangeAgent(exchangeAgent).swapTokenWithETH(_token, amount, premiumAmount);

        IInsureAce(coverContractAddress).buyCover{value: premiumAmount}(
            products,
            durationInDays,
            amounts,
            currency,
            msgSender(),
            referralCode,
            premiumAmount,
            helperParameters,
            securityParameters,
            v,
            r,
            s
        );

        emit BuyInsureAce(products, msgSender(), currency, _token, premiumAmount);
    }

    /**
     * @dev Through this function, users can get covers from Insure by some tokens such as CVR...
     */
    function buyTokenCoverByToken(
        uint16[] memory products,
        uint16[] memory durationInDays,
        uint256[] memory amounts,
        address currency,
        address _token,
        uint256 referralCode,
        uint256 premiumAmount,
        uint256[] memory helperParameters,
        uint256[] memory securityParameters,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external payable nonReentrant whenNotPaused {
        require(currency != WETH, "Should be ERC20 token product");
        uint256 amount = IExchangeAgent(exchangeAgent).getNeededTokenAmount(_token, currency, premiumAmount);

        TransferHelper.safeTransferFrom(_token, msgSender(), address(this), amount);
        // TransferHelper.safeApprove(_token, exchangeAgent, amount);

        IExchangeAgent(exchangeAgent).swapTokenWithToken(_token, currency, amount, premiumAmount);
        TransferHelper.safeApprove(currency, coverContractAddress, premiumAmount);

        IInsureAce(coverContractAddress).buyCover(
            products,
            durationInDays,
            amounts,
            currency,
            msgSender(),
            referralCode,
            premiumAmount,
            helperParameters,
            securityParameters,
            v,
            r,
            s
        );

        emit BuyInsureAce(products, msgSender(), currency, _token, premiumAmount);
    }
}
