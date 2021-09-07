pragma solidity 0.8.7;

import "../Storage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface INexus {
    function buyCover (
    address contractAddress,
    address coverAsset,
    uint sumAssured,
    uint16 coverPeriod,
    uint8 coverType,
    bytes calldata data
  ) external payable returns (uint);

function submitClaim(uint tokenId, bytes calldata data) external returns (uint);

function redeemClaim( uint256 tokenId, uint256 claimId) external;

function getPayoutOutcome(uint claimId) external view returns (IGateway.ClaimStatus status, uint amountPaid, address coverAsset);

}

interface IGateway {
  enum ClaimStatus { IN_PROGRESS, ACCEPTED, REJECTED }
}

/*
* @dev This contract is accessed by Proxy contract 
* and can be updated if the owner wishes so
* This contract contains the logic of a function
*/
contract NexusMutual is Storage {
    using SafeMath for uint256;

address nexusDistributor;

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

function buyNexusCover(address proxyAddress,
address _buyer,
string memory _device, 
string memory _company,
uint256 _amountPaid,
uint256 _amountInsured,
string memory _currency,
uint16 _period,
address contractAddress,
address coverAsset,
uint8 coverType,
bytes calldata data) public {

//Buying the actual Nexus Mutual Insurance
uint _covderID = INexus(nexusDistributor).buyCover(contractAddress, coverAsset, _amountInsured, _period, coverType, data);

//Sroting the transaction details
    uint _totalBought = totalBought[_buyer];

    //pd => ProductDetails
    productDetails storage pd = userBought[_buyer][_totalBought];
    pd.Product['device'] = _device;
    pd.Product['company'] = _company;
    pd.Product['currency'] = _currency;

    pd.IntValues['coverID'] = _covderID;
    pd.IntValues['amountBought'] = _amountPaid;
    pd.IntValues['timeStamp'] = block.timestamp;

    pd.boolValues['exists'] = true;

totalBought[_buyer] = _totalBought.add(1);

emit insurancBought(proxyAddress, _buyer);

}

function submitNexusClaim(address proxyAddress, uint tokenId, bytes calldata data) public {
    INexus(nexusDistributor).submitClaim(tokenId,data);
}

}