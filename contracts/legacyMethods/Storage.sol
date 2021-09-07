pragma solidity 0.8.7;

/*
* @dev this contract is to set common 
* storage which will be inherited by both
* proxy and Function contract
*/

contract LegacyStorage {
    uint256 public number;

    function getNumber() internal view returns(uint256) {
return number;
    }
    
    function setNumber(uint256 _number) internal  {
    number = _number;
    }
}