pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

/**
* @dev this contract is to set a common 
*storage which will be inherited by both
* proxy and Function contract. It is designed to be future proof 
* to encapsulate needs that we can not even predict right now.
*/

contract Storage is AccessControlEnumerable {

/**
* Listing of all partners
*/

mapping (bytes32 => partnerDetails) partners;

struct partnerDetails {
    mapping(string => uint) IntValues;
    mapping (string => mapping(string => string)) details;
    mapping (string => bool) boolValues;
    uint256 [] indexes;
    mapping(string => address) addresses;
    mapping(address => bool) currencies;
    mapping(string => bytes) byteValue;
}

bytes32 [] public partnerList;

struct productDetails {
mapping (string => string) Product;
mapping (string => string) Units;

mapping(string => uint) IntValues;
mapping(string => address) addresses;
mapping(string => bytes) byteValue;
mapping (string => bool) boolValues;

mapping (string => mapping(string => string)) details;
}

//Array of all bought products
productDetails [] everyBought;


//User details
mapping (address=> userDetails) users;

struct userDetails {
    mapping(string => uint) IntValues;
    mapping (string => mapping(string => string)) details;
    mapping (string => bool) boolValues;

    uint256 [] indexes;

    mapping(string => address) addresses;
    mapping(string => bytes) byteValue;
}

/** @dev This address is a special address
* In case of chaning data in this storage contract
* There is a provision to set a pointer to an contract 
* Where we can define the functions we want to edit
* the data according to our needs 
*
* All address of priceFeeds, updateStarage smart contract
* will be stored here
*
*/
mapping (bytes32 => operator) operators;

struct operator{
    address operation;
    bool exists;
    bool isActive;
}

bytes32 [] operatorList;

address public owner;
bool public _initialized;

/** @dev
* Spported currency list
*/

mapping (address => bool) currencies;

/**
* All the listing of essential participants in the 
* cover, they all have different rights of functions
* Above them all sits the "DEFAULT_ADMIN_ROLE"
*/
bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
bytes32 public constant UPGRADE_OFFICER = keccak256("UPGRADE_OFFICERS");
bytes32 public constant EMERGENCY_OFFICERS = keccak256("EMERGENCY_OFFICERS");
bytes32 public constant PARTNERS = keccak256("PARTNERS");

}
