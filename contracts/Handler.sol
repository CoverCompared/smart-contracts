pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Handler is AccessControlEnumerable{

address owner;

bytes32 public constant MANAGER_ROLE = keccak256("MANAGERS");
bytes32 public constant UPGRADE_OFFICER = keccak256("UPGRADE_OFFICER");
bytes32 public constant EMERGENCY_OFFICERS = keccak256("EMERGENCY_OFFICERS");
bytes32 public constant PARTNERS = keccak256("PARTNERS");

constructor() public {
    owner = msg.sender;
    //updContract = functionContract;

    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(MANAGER_ROLE, _msgSender());
    _setupRole(UPGRADE_OFFICER, _msgSender());
    _setupRole(EMERGENCY_OFFICERS, _msgSender());
    _setupRole(PARTNERS, _msgSender());

}

}