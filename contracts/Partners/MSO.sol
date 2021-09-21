pragma solidity 0.8.7;

import "../Storage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
* @dev This contract is accessed by Proxy contract 
* and can be updated if the owner wishes so
* This contract contains the logic of a function
*/

contract MSO is Storage{
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

event insurancBought(bytes32 _partner, address _buyer);

function initialize(address _owner) public {
owner = _owner;
}

// function getTheDetails(address proxyAddress, string memory _variable) public view returns(uint256){
// return uintStorage[_variable];
// }

//BUSD, BNB, DAI, USDC and CVR

function approve(bytes32 _partner, address _currencyContract, uint _amount) public {
    require(partners[_partner].currencies[_currencyContract] == true, 'Not a supported currency');
    IERC20(_currencyContract).approve(_msgSender(), _amount);
}

function buyDeviceInsurance(bytes32 _partner,
bytes memory sig,
uint256 nonce,
address _buyer,
string memory _device,
string memory _company,
uint256 _amountPaid,
string memory _currency,
address _currencyContract,
uint _period) public payable{

//Checking the nonce and increamenting it
require(users[_msgSender()].IntValues['nonce'] == nonce.add(1),'Invalid Nonce');
users[_msgSender()].IntValues['nonce'] = users[_msgSender()].IntValues['nonce'].add(1);

//Verifying the amount, currency and all details against the message and signer
bytes32 message = prefixed(keccak256(abi.encodePacked(_msgSender(), _amountPaid, nonce, address(this), _currencyContract, _period)));

//Verifying the signer
(uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
address signer = ecrecover(message, v, r, s);

require(signer == partners[_partner].addresses['signer'], 'Not a valid signer');
require(signer == address(0), 'Not a valid signer');

//Transferring the funds
 require(partners[_partner].currencies[_currencyContract] == true, 'Not a supported currency');
 IERC20(_currencyContract).transferFrom(_msgSender(), address(this), _amountPaid);

//Storing purchase details

//pd => ProductDetails

productDetails storage pd = everyBought[everyBought.length];
pd.details['Product']['device'] = _device;
pd.details['Product']['company'] = _company;
pd.details['Product']['currency'] = _currency;
pd.IntValues['paid'] = _amountPaid;
pd.IntValues['timeStamp'] = block.timestamp;

//Asserting
assert(users[_msgSender()].IntValues['nonce'] == nonce);

//Declaring that a new purchase has been made
emit insurancBought(_partner, _buyer);

}

function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8 v, bytes32 r, bytes32 s) {
    require(sig.length == 65);
    assembly {
    // first 32 bytes, after the length prefix.
        r := mload(add(sig, 32))
        // second 32 bytes.
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes).
        v := byte(0, mload(add(sig, 96)))
    }
    return (v, r, s);
}

function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}
