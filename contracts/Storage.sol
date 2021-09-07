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
* mapping(string => uint) uintStorage;
* Instead of doing uint256 public number, we do the above mentined mapping 
* a mapping for "number"=> uint256. 
* Benefit : tomorrow if we need to add more variables like cat, dog, crocodile
* Then we can just define those variables in the mapping and store it.
* Like cat=> uint256, dog=> uint256, crocodile=> uint256
* Like uintStorage["dog"] = 10;
*/


/**
* Listing of all partners
*/

mapping (string => partnerDetails) partners;

struct partnerDetails {
    mapping(string => uint) IntValues;
    mapping (string => mapping(string => string)) details;
    mapping (string => bool) boolValues;

    mapping(string => address) addresses;
    mapping(string => bytes) byteValue;
    mapping (string => string) moreDetails;

}
/**
* @dev the triple mapping above will store atleast 3 type of data
* Status, Type and moreDetails.
* The IntValues will store totalNo. of cover sold, partner joining epoch,
* THe boolValues will store => isActive, exists.
* Last 3 mappings are provisional to incapsulate future needs.
*/

string [] public partnerList;

//Storing all the products bought on a per user basis mapping
mapping (address => mapping (uint => productDetails)) internal userBought;

//Storing amount of products bought per user
mapping (address => uint) totalBought;

//Stpring the addresses of each user that has bought cover from the platform
address [] public buyers;

//Storing all the covers bought on a per partner basis
mapping (string => mapping (uint => productDetails)) internal soldPerPartner;

/**
* Keys : Amount, Poduct, Currency, Period, Provider => 5,Curve pool cover, Eth, 4, Nexus Mutual
* mapping (string => string)public Product;
* Keys : Amount, product, currency, period => Wei, "Address of the pool cover", Wei, weeks, address of Nexus Mutual
* mapping (string => string) public Units;
*/

struct productDetails {
//This is for demo, this will fall under the triple string mapping.
mapping (string => string) Product;
mapping (string => string) Units;

mapping(string => uint) IntValues;
mapping(string => address) addresses;
mapping(string => bytes) byteValue;
mapping (string => string) moreDetails;
mapping (string => bool) boolValues;

mapping (string => mapping(string => string)) details;
}

/**
* To discuss : do we need an array 
* for defining all the keys that we are using
*/

// Potentially useless
mapping (string => mapping (string => string)) Units;
//mapping (string => string) moreDetails;

/* This mapping is to map all the active 
* proxy addresses to true it's bool value  
*/
mapping (address => addressStatus) proxyAddresses;

struct addressStatus {
    mapping(string => string) details;
    mapping(string => bool) boolValues;
}

/* @dev This address is a special address
* In case of chaning data in this storage contract
* There is a provision to set a pointer to an contract 
* Where we can define the functions we want to edit
* the data according to our needs */
address public updateStorage;

address public owner;
bool public _initialized;

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
