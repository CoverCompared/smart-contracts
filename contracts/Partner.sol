pragma solidity 0.8.7;

import "./Storage.sol";
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

event partnerAdded(address _partner, uint _timeStamp);

function initialize(address _owner) public {
owner = _owner;
}

// function getTheDetails(address proxyAddress, string memory _variable) public view returns(uint256){
// return uintStorage[_variable];
// }

function addPartner(address proxyAddress, 
string memory _name, Type _type , Status _status) public {

require (!partners[_name].exists, 'Partner already exists');
partnerList.push(_name);

partners[_name]._type = _type;
partners[_name].status = _status;

partners[_name].exists = true;
emit partnerAdded(proxyAddress, block.timestamp);

}

}