// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";

/**
 * @dev This smart contract is for getting CVR_ETH, CVR_USDT price
 */
contract ExchangeAgent is Ownable {
    event AddedGateway(address _sender, address _gateway);
    event RemovedGateway(address _sender, address _gateway);
    event SetCurrency(address _sender, address _currency, address _pair);
    event RemovedCurrency(address _sender, address _currency);

    mapping(address => bool) public whiteList; // white listed polka gateways
    // available currencies in Polkacover, token => pair
    // for now we allow ETH and CVR
    mapping(address => address) public uniStablePairs;

    address public wethStablePair; // WETH_STABLECOIN pair

    constructor() {}

    receive() external payable {}

    modifier onlyWhiteListed(address _gateway) {
        require(whiteList[_gateway], "Only white listed addresses are acceptable");
        _;
    }

    /**
     * @dev we set amount param here to reduce decimal round issue when deviding...
     */
    function getTokenUSDPrice(address _token, uint256 _desiredUSD) public view returns (uint256) {
        address pair = uniStablePairs[_token];
        if (uniStablePairs[_token] == address(0)) {
            return 0;
        }
        address token0 = IUniswapV2Pair(pair).token0();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();

        uint256 denominator;
        uint256 numerator;
        if (_token == token0) {
            denominator = reserve1;
            numerator = reserve0 * _desiredUSD;
        } else {
            denominator = reserve0;
            numerator = reserve1 * _desiredUSD;
        }

        return (numerator * (10**IERC20Metadata(_token).decimals())) / denominator;
    }

    function swapCVRWithETH(uint256 amount) public onlyWhiteListed(msg.sender) {}

    function addWhiteList(address _gateway) external onlyOwner {
        require(!whiteList[_gateway], "Already white listed");
        whiteList[_gateway] = true;
    }

    function removeWhiteList(address _gateway) external onlyOwner {
        require(whiteList[_gateway], "Not white listed");
        whiteList[_gateway] = false;
    }

    function setCurrency(address _currency, address _pair) external onlyOwner {
        require(_currency != address(0) && _pair != address(0), "ZERO address");
        uniStablePairs[_currency] = _pair;
        SetCurrency(msg.sender, _currency, _pair);
    }

    function removeCurrency(address _currency) external onlyOwner {
        require(_currency != address(0) && uniStablePairs[_currency] != address(0), "ZERO address or removed already");
        uniStablePairs[_currency] = address(0);
        RemovedCurrency(msg.sender, _currency);
    }
}
