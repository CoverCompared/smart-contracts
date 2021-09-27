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

contract CoverCompared is Storage, ReentrancyGuard, Pausable{

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

function pause(string memory _message) public ifEmergencyOfficer {
    _pause();

    emit contractPaused(_msgSender(),_message );
}

function resume(string memory _message) public ifEmergencyOfficer {
    _unpause();
    emit contractResumed(_msgSender(),_message );
}

function addProxy(address proxyAddress, bytes32 _name) public ifManager{

require(partners[_name].boolValues['exists'] != true, 'Partner already exists');
require(proxyAddress != address(0));

partners[_name].boolValues['exists'] = true;
partnerList.push(_name);
partners[_name].addresses['proxy'] = proxyAddress;

    emit newPartnerAdded(proxyAddress, _msgSender());
}

function removeProxy(bytes32 _name) public ifManager{
    require(partners[_name].boolValues['exists']== true, 'Is not a proxy');
    require(partners[_name].boolValues['isActive']!= false, 'Is already unactive');

    partners[_name].boolValues['isActive']= false;
}

function activateProxy(bytes32 _name) public ifManager {
    require(partners[_name].boolValues['exists'] == true, 'Partner does not exist');

    partners[_name].boolValues['active'] = true;

    emit partnerMadeActive(partners[_name].addresses['proxy'], _msgSender());
}

function updateProxyInfo(bytes32 _name, string[] memory _keyValues, string memory _heading, string[] memory info) public ifManager {
    require(partners[_name].boolValues['exists']== true, 'Is not a proxy');
    require(_keyValues.length == info.length);

    for(uint i=0; i<_keyValues.length; i++) {
    partners[_name].details[_heading][_keyValues[i]] = info[i];
}
}

function updateBoolInfo(bytes32 _name, string[] memory _keyValues, bool[] memory info) public ifManager {
    require(partners[_name].boolValues['exists']== true, 'Is not a proxy');
    require(_keyValues.length == info.length);

for(uint i=0; i<_keyValues.length; i++) {
require(keccak256(abi.encodePacked(_keyValues[i])) != keccak256(abi.encodePacked('exists')));
require(keccak256(abi.encodePacked(_keyValues[i])) != keccak256(abi.encodePacked('exists')));

}

     for(uint i=0; i<_keyValues.length; i++) {
    partners[_name].boolValues[_keyValues[i]] = info[i];
}
}

function updateCurrencyStatus(address _currency, bool _status) public ifManager {
    currencies[_currency] = _status;
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
bytes32 _partner;

assembly {
        calldatacopy(0x0, 4, 36)
        _partner := mload(0x0)
}

address proxy;

if (operators[_partner].exists == true && operators[_partner].exists == true ) {
     proxy = operators[_partner].operation;

} else if(partners[_partner].boolValues['isActive'] == true){

    proxy = partners[_partner].addresses['proxy'];

} else {
    revert();
}

//For security setting the condition that address is a one which we recognize
require(proxy != address(0));

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
