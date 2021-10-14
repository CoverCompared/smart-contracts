// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libs/TransferHelper.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IExchangeAgent.sol";

/**
 * @dev This smart contract is for getting CVR_ETH, CVR_USDT price
 */
contract ExchangeAgent is Ownable, IExchangeAgent {
    event AddedGateway(address _sender, address _gateway);
    event RemovedGateway(address _sender, address _gateway);
    event SetCurrency(address _sender, address _currency, address _pair);
    event RemovedCurrency(address _sender, address _currency);

    mapping(address => bool) public whiteList; // white listed polka gateways
    // available currencies in Polkacover, token => pair
    // for now we allow ETH and CVR
    mapping(address => bool) public availableCurrencies;

    address public immutable USDC_ADDRESS;
    address public immutable WETH;
    address public immutable UNISWAP_FACTORY;

    constructor(
        address _USDC_ADDRESS,
        address _WETH,
        address _UNISWAP_FACTORY
    ) {
        USDC_ADDRESS = _USDC_ADDRESS;
        WETH = _WETH;
        UNISWAP_FACTORY = _UNISWAP_FACTORY;
    }

    receive() external payable {}

    modifier onlyWhiteListed(address _gateway) {
        require(whiteList[_gateway], "Only white listed addresses are acceptable");
        _;
    }

    /**
     * @dev we set amount param here to reduce decimal round issue when deviding...
     */
    function _getNeededTokenAmount(address _token0, address _token1,  uint256 _desiredAmount) private view returns (uint256) {
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(_token0, _token1);
        require(pair != address(0), "There's no stable pair");

        address token0 = IUniswapV2Pair(pair).token0();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();

        uint256 denominator;
        uint256 numerator;
        if (_token0 == token0) {
            denominator = reserve1;
            numerator = reserve0 * _desiredAmount;
        } else {
            denominator = reserve0;
            numerator = reserve1 * _desiredAmount;
        }

        return (numerator * (10**IERC20Metadata(_token0).decimals())) / denominator;
    }

    function getNeededTokenAmount(address _token0, address _token1,  uint256 _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(_token0, _token1,  _desiredAmount);
    }

    function getTokenAmountForUSDC(address _token, uint _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(_token, USDC_ADDRESS, _desiredAmount);
    }

    function getTokenAmountForETH(address _token, uint _desiredAmount) external view override returns (uint256) {
        return _getNeededTokenAmount(_token, WETH, _desiredAmount);
    }

    /**
     * @param _amount: this one is the value with decimals 
     */
    function swapTokenWithETH(address _token, uint256 _amount) external override onlyWhiteListed(msg.sender) {
        // store CVR in this exchagne contract
        // send eth to buy gateway based on the uniswap price
        require(availableCurrencies[_token], "Token should be added in available list");
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(_token, WETH);
        require(pair != address(0), "There's no stable pair");

        address token0 = IUniswapV2Pair(pair).token0();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();

        uint256 denominator;
        uint256 numerator;
        if (_token == token0) {
            denominator = reserve0;
            numerator = reserve1 * _amount;
        } else {
            denominator = reserve1;
            numerator = reserve0 * _amount;
        }

        uint value = numerator / denominator;
        require(value <= address(this).balance, "Insufficient ETH balance");
        TransferHelper.safeTransferETH(msg.sender, numerator / denominator);
    }

    function addWhiteList(address _gateway) external onlyOwner {
        require(!whiteList[_gateway], "Already white listed");
        whiteList[_gateway] = true;
    }

    function removeWhiteList(address _gateway) external onlyOwner {
        require(whiteList[_gateway], "Not white listed");
        whiteList[_gateway] = false;
    }

    function addCurrency(address _currency) external onlyOwner {
        require(!availableCurrencies[_currency], "Already available");
        availableCurrencies[_currency] = true;
    }

    function removeCurrency(address _currency) external onlyOwner {
        require(availableCurrencies[_currency], "Not available yet");
        availableCurrencies[_currency] = false;
    }
}
