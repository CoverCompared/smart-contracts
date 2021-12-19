// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libs/TransferHelper.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/ITwapOraclePriceFeedFactory.sol";
import "./interfaces/ITwapOraclePriceFeed.sol";
import "./interfaces/IExchangeAgent.sol";

/**
 * @dev This smart contract is for getting CVR_ETH, CVR_USDT price
 */
contract ExchangeAgent is Ownable, IExchangeAgent, ReentrancyGuard {
    event AddGateway(address _sender, address _gateway);
    event RemoveGateway(address _sender, address _gateway);
    event AddAvailableCurrency(address _sender, address _currency);
    event RemoveAvailableCurrency(address _sender, address _currency);
    event UpdateSlippage(address _sender, uint256 _slippage);
    event WithdrawAsset(address _user, address _to, address _token, uint256 _amount);
    event UpdateSlippageRate(address _user, uint256 _slippageRate);

    mapping(address => bool) public whiteList; // white listed CoverCompared gateways

    // available currencies in CoverCompared, token => bool
    // for now we allow CVR
    mapping(address => bool) public availableCurrencies;

    address public immutable USDC_ADDRESS;
    address public immutable WETH;
    address public immutable UNISWAP_FACTORY;
    address public immutable TWAP_ORACLE_PRICE_FEED_FACTORY;

    uint256 public SLIPPPAGE_RAGE;
    /**
     * when users try to use CVR to buy products, we will discount some percentage(25% at first stage)
     */
    uint256 public discountPercentage = 75;

    constructor(
        address _USDC_ADDRESS,
        address _WETH,
        address _UNISWAP_FACTORY,
        address _TWAP_ORACLE_PRICE_FEED_FACTORY
    ) {
        USDC_ADDRESS = _USDC_ADDRESS;
        WETH = _WETH;
        UNISWAP_FACTORY = _UNISWAP_FACTORY;
        TWAP_ORACLE_PRICE_FEED_FACTORY = _TWAP_ORACLE_PRICE_FEED_FACTORY;
        SLIPPPAGE_RAGE = 100;
    }

    receive() external payable {}

    modifier onlyWhiteListed(address _gateway) {
        require(whiteList[_gateway], "Only white listed addresses are acceptable");
        _;
    }

    function setDiscountPercentage(uint256 _discountPercentage) external onlyOwner {
        discountPercentage = _discountPercentage;
    }

    /**
     * @dev Get needed _token0 amount for _desiredAmount of _token1
     * _desiredAmount should consider decimals based on _token1
     */
    function _getNeededTokenAmount(
        address _token0,
        address _token1,
        uint256 _desiredAmount
    ) private view returns (uint256) {
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(_token0, _token1);
        require(pair != address(0), "There's no pair");

        address twapOraclePriceFeed = ITwapOraclePriceFeedFactory(TWAP_ORACLE_PRICE_FEED_FACTORY).getTwapOraclePriceFeed(
            _token0,
            _token1
        );

        require(twapOraclePriceFeed != address(0), "There's no twap oracle for this pair");

        uint256 neededAmount = ITwapOraclePriceFeed(twapOraclePriceFeed).consult(_token1, _desiredAmount);
        neededAmount = (neededAmount * discountPercentage) / 100;
        return neededAmount;
    }

    /**
     * @dev Get needed _token0 amount for _desiredAmount of _token1
     */
    function getNeededTokenAmount(
        address _token0,
        address _token1,
        uint256 _desiredAmount
    ) external view override returns (uint256) {
        return _getNeededTokenAmount(_token0, _token1, _desiredAmount);
    }

    function getETHAmountForUSDC(uint256 _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(WETH, USDC_ADDRESS, _desiredAmount);
    }

    /**
     * get needed _token amount for _desiredAmount of USDC
     */
    function getTokenAmountForUSDC(address _token, uint256 _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(_token, USDC_ADDRESS, _desiredAmount);
    }

    /**
     * get needed _token amount for _desiredAmount of ETH
     */
    function getTokenAmountForETH(address _token, uint256 _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(_token, WETH, _desiredAmount);
    }

    /**
     * @param _amount: this one is the value with decimals
     */
    function swapTokenWithETH(
        address _token,
        uint256 _amount,
        uint256 _desiredAmount
    ) external override onlyWhiteListed(msg.sender) nonReentrant {
        // store CVR in this exchagne contract
        // send eth to buy gateway based on the uniswap price
        require(availableCurrencies[_token], "Token should be added in available list");
        _swapTokenWithToken(_token, WETH, _amount, _desiredAmount);
    }

    function swapTokenWithToken(
        address _token0,
        address _token1,
        uint256 _amount,
        uint256 _desiredAmount
    ) external override onlyWhiteListed(msg.sender) nonReentrant {
        require(availableCurrencies[_token0], "Token should be added in available list");
        _swapTokenWithToken(_token0, _token1, _amount, _desiredAmount);
    }

    /**
     * @dev exchange _amount of _token0 with _token1 by twap oracle price
     */
    function _swapTokenWithToken(
        address _token0,
        address _token1,
        uint256 _amount,
        uint256 _desiredAmount
    ) private {
        address twapOraclePriceFeed = ITwapOraclePriceFeedFactory(TWAP_ORACLE_PRICE_FEED_FACTORY).getTwapOraclePriceFeed(
            _token0,
            _token1
        );

        uint256 swapAmount = ITwapOraclePriceFeed(twapOraclePriceFeed).consult(_token0, _amount);
        require(swapAmount <= address(this).balance, "Insufficient ETH balance");
        uint256 availableMinAmount = (_desiredAmount * (10000 - SLIPPPAGE_RAGE)) / 10000;
        require(swapAmount > availableMinAmount, "Overflow min amount");

        TransferHelper.safeTransferFrom(_token0, msg.sender, address(this), _amount);

        if (_token1 == WETH) {
            TransferHelper.safeTransferETH(msg.sender, _desiredAmount);
        } else {
            TransferHelper.safeTransfer(_token1, msg.sender, _desiredAmount);
        }
    }

    function addWhiteList(address _gateway) external onlyOwner {
        require(!whiteList[_gateway], "Already white listed");
        whiteList[_gateway] = true;
        emit AddGateway(msg.sender, _gateway);
    }

    function removeWhiteList(address _gateway) external onlyOwner {
        require(whiteList[_gateway], "Not white listed");
        whiteList[_gateway] = false;
        emit RemoveGateway(msg.sender, _gateway);
    }

    function addCurrency(address _currency) external onlyOwner {
        require(!availableCurrencies[_currency], "Already available");
        availableCurrencies[_currency] = true;
        emit AddAvailableCurrency(msg.sender, _currency);
    }

    function removeCurrency(address _currency) external onlyOwner {
        require(availableCurrencies[_currency], "Not available yet");
        availableCurrencies[_currency] = false;
        emit RemoveAvailableCurrency(msg.sender, _currency);
    }

    function setSlippageRate(uint256 _slippageRate) external onlyOwner {
        require(_slippageRate > 0 && _slippageRate < 100, "Overflow range");
        SLIPPPAGE_RAGE = _slippageRate * 100;
        emit UpdateSlippageRate(msg.sender, _slippageRate);
    }

    function withdrawAsset(
        address _to,
        address _token,
        uint256 _amount
    ) external onlyOwner {
        if (_token == address(0)) {
            TransferHelper.safeTransferETH(_to, _amount);
        } else {
            TransferHelper.safeTransfer(_token, _to, _amount);
        }
        emit WithdrawAsset(owner(), _to, _token, _amount);
    }
}
