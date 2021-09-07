pragma solidity 0.8.7;

import "./Storage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/*
* @dev this contract is the main contract 
* with which the user will interact
* it calls the Function contract which can be updated 
* by simply updating the new function contract address 
*/

contract Proxy is Storage, ReentrancyGuard, Pausable{

modifier onlyOwner()  {
require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "You are not the owner");
_;
}

modifier ifAdmin() {
   if(hasRole(DEFAULT_ADMIN_ROLE, _msgSender())){
       _;
   }else {
       _fallback();
   }
}

modifier ifManager() {
   if(hasRole(DEFAULT_ADMIN_ROLE, _msgSender())){
       _;
   }else if (hasRole(MANAGER_ROLE, _msgSender())){
       _;
   } else {
       _fallback();
   }
}

modifier ifUserOrUpgradeOfficer () {
    if(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || hasRole(EMERGENCY_OFFICERS, _msgSender()) || hasRole(MANAGER_ROLE, _msgSender())) {
        revert();
    } else if(hasRole(UPGRADE_OFFICER, _msgSender())) {
        _;
    }
    else {
       _;
    }
}

modifier ifEmergencyOfficer () {
    if(hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
        _;
    } else if(hasRole(EMERGENCY_OFFICERS, _msgSender())) {
        _;
    }
    else {
       _fallback();
    }
}

constructor(address _manager, address _emergencyOfficer, address upgradeOfficer) {
    
    //When role variables are decided we will remove the above 
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MANAGER_ROLE, _manager);
    _setupRole(UPGRADE_OFFICER, upgradeOfficer);
    _setupRole(EMERGENCY_OFFICERS, _emergencyOfficer);

}

event newPartnerAdded(address _proxyAddress, address _partnerAddress);

event partnerMadeActive(address _proxyAddress, address _partnerAddress);

event contractPaused(address _pauser, string _message);

event contractResumed(address _resumer, string _message);

function _pause() internal override whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
}

function _unpause() internal override whenPaused{
    _paused = false;
    emit Unpaused(_msgSender());
}

function stop(string memory _message) public ifEmergencyOfficer {
    _pause();

    emit contractPaused(_msgSender(),_message );
}

function resume(string memory _message) public ifEmergencyOfficer {
    _unpause();
    emit contractResumed(_msgSender(),_message );
}

function addProxy(address newAddress, string memory _name) public ifManager{
    proxyAddresses[newAddress].details['name'] = _name;
    proxyAddresses[newAddress].boolValues['exists']= true;

    emit newPartnerAdded(newAddress, _msgSender());
}

function removeProxy(address oldAddress) public ifManager{
    require(proxyAddresses[oldAddress].boolValues['exists']== true, 'Is not a proxy');
    require(proxyAddresses[oldAddress].boolValues['active']!= false, 'Is already unactive');

    proxyAddresses[oldAddress].boolValues['active']= false;
}

function activateProxy(address proxyAddress) public ifManager {
    proxyAddresses[proxyAddress].boolValues['active'] = true;

    emit partnerMadeActive(proxyAddress, _msgSender());
}

function updateProxyInfo(string[] memory _keyValues, string[] memory info, address proxyAddress) public ifManager {
    require(proxyAddresses[proxyAddress].boolValues['exists']== true, 'Is not a proxy');

    for(uint i=0; i<_keyValues.length; i++) {
    proxyAddresses[proxyAddress].details[_keyValues[i]] = info[i];
}
}

function updateBoolInfo(string[] memory _keyValues, bool[] memory info, address proxyAddress) public ifManager {
    require(proxyAddresses[proxyAddress].boolValues['exists']== true, 'Is not a proxy');

     for(uint i=0; i<_keyValues.length; i++) {
    proxyAddresses[proxyAddress].boolValues[_keyValues[i]] = info[i];
}
}

/** 
* @dev User calls a function --> is directly directed to fallback
* Admin calls a function --> is directed to the function
* If upgrade officer calls a function --> is directly directed to fallback
* rest of the admins are prohibited from using the fallback
*/

function _fallback() internal ifUserOrUpgradeOfficer whenNotPaused nonReentrant{

//Setting variable for the data of the function 
//This is all the input values of the function
bytes memory data = msg.data;

//Setting the proxy contract address
//My addition : 
bytes20 _address;

assembly {
        calldatacopy(0x0, 16, 36)
        _address := mload(0x0)
}

address proxy = address(_address);

//For security setting the condition that address is a one which we recognize
require(proxy != address(0));
require(proxyAddresses[proxy].boolValues['active'] || proxy == updateStorage);

//The fun begins
assembly {
let result := delegatecall(gas(), proxy, add(data, 0x20), mload(data), 0, 0)
let size := returndatasize()
let ptr := mload(0x40)
returndatacopy(ptr, 0, size)

switch result
case 0 {revert(ptr, size)}
default {return (ptr, size)}
}
}


fallback() external payable {
    _fallback();
}

}