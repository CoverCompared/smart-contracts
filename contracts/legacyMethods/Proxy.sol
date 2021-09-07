pragma solidity 0.8.7;

import "./Storage.sol";

/*
* @dev this contract is the main contract 
* with which the user will interact
* it calls the Function contract which can be updated 
* by simply updating the new function contract address 
*/

contract LegacyProxy is LegacyStorage{

address public updContract;
string public functionToCall;
/* constructor(address functionContract) {
*     updContract = functionContract;
}*/

function updateContract(address newAddress) public {
    updContract = newAddress;
}



function getTheNumber() public  returns(bytes memory){
   (bool success, bytes memory data) = updContract.delegatecall(
        abi.encodeWithSignature("getNumber()")
    );
    return (data);
}

function setFunction(string memory _newFunction) public {
functionToCall  = _newFunction;
}

function setTheNumber(uint256 toSet) public returns (bool){
    (bool success, bytes memory data) = updContract.delegatecall(
        abi.encodeWithSignature("setTheNumber(uint256)", toSet)
    );
    return success;
}

}