pragma solidity 0.8.7;

import "../Storage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/*
* @dev This contract is accessed by Proxy contract 
* and can be updated if the owner wishes so
* This contract contains the logic of a function
*/

contract P4L is Storage{
    using SafeMath for uint256;

modifier onlyOwner () {
    require(msg.sender == owner, 'You are not the owner');
    _;
}

constructor () public {
    require(!_initialized);
    _initialized = true;
    initialize(msg.sender);
}

event insurancBought(address _P4L, address _buyer);

function initialize(address _owner) public {
owner = _owner;
}

// function getTheDetails(address proxyAddress, string memory _variable) public view returns(uint256){
// return uintStorage[_variable];
// }

function buyDeviceInsurance(address proxyAddress,
address _buyer,
string memory _device,
string memory _company,
uint256 _amountPaid,
string memory _currency,
uint _period) public {
uint _totalBought = totalBought[_buyer];

    //pd => ProductDetails
    productDetails storage pd = userBought[_buyer][_totalBought];
    pd.Product['device'] = _device;
    pd.Product['company'] = _company;
    pd.Product['currency'] = _currency;

pd.details['amount'] = _amountPaid;
pd.timeStamp = block.timestamp;
pd.exists = true;

totalBought[_buyer] = _totalBought.add(1);
emit insurancBought(proxyAddress, _buyer);

}

}