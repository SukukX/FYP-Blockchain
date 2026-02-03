// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SmartSukukToken
 * @dev Simplified ERC-1400-style tokenization contract without EnumerableSet (stable across OZ versions).
 */
contract SmartSukukToken is Ownable {
    // --- Partition Structure (mapping inside struct) ---
    struct Partition {
        string name;
        uint256 totalSupply;
        mapping(address => uint256) balances;
    }

    mapping(bytes32 => Partition) private partitions;
    mapping(bytes32 => bool) public existingPartitions;
    bytes32[] private partitionList;

    mapping(address => bool) public whitelistedInvestors;

    string public name = "Smart Sukuk Token";
    string public symbol = "SUKUK";
    uint8 public decimals = 18;

    event PartitionCreated(bytes32 indexed partitionId, string name);
    event Issued(
        bytes32 indexed partitionId,
        address indexed to,
        uint256 amount
    );
    event TransferredByPartition(
        bytes32 indexed partitionId,
        address from,
        address to,
        uint256 amount
    );

    modifier onlyWhitelisted(address user) {
        require(whitelistedInvestors[user], "Not whitelisted");
        _;
    }

    constructor() Ownable(msg.sender) {}

    // --- ADMIN FUNCTIONS ---

    function addToWhitelist(address investor) external onlyOwner {
        whitelistedInvestors[investor] = true;
    }

    function removeFromWhitelist(address investor) external onlyOwner {
        whitelistedInvestors[investor] = false;
    }

    // Create a new partition (e.g., Real Estate Sukuk)
    function createPartition(string calldata partitionName) external onlyOwner {
        bytes32 partitionId = keccak256(abi.encodePacked(partitionName));
        require(!existingPartitions[partitionId], "Partition already exists");

        // initialize partition.name and mark exists
        Partition storage p = partitions[partitionId];
        p.name = partitionName;
        existingPartitions[partitionId] = true;
        partitionList.push(partitionId);

        emit PartitionCreated(partitionId, partitionName);
    }

    // Issue tokens under a specific partition
    function issueByPartition(
        bytes32 partitionId,
        address to,
        uint256 amount
    ) external onlyOwner onlyWhitelisted(to) {
        require(existingPartitions[partitionId], "Partition not found");
        Partition storage p = partitions[partitionId];
        p.balances[to] += amount;
        p.totalSupply += amount;
        emit Issued(partitionId, to, amount);
    }

    // forceful transfer (for legal recovery, lost keys, or admin corrections)
    function operatorTransferByPartition(
        bytes32 partitionId,
        address from,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(existingPartitions[partitionId], "Partition not found");
        Partition storage p = partitions[partitionId];
        require(p.balances[from] >= amount, "Insufficient balance");

        p.balances[from] -= amount;
        p.balances[to] += amount;

        // Check if receiver is whitelisted (optional, but recommended)
        require(whitelistedInvestors[to], "Receiver not whitelisted");

        emit TransferredByPartition(partitionId, from, to, amount);
    }

    // Transfer within a partition
    function transferByPartition(
        bytes32 partitionId,
        address to,
        uint256 amount
    ) external onlyWhitelisted(to) {
        require(whitelistedInvestors[msg.sender], "Sender not whitelisted");
        require(existingPartitions[partitionId], "Partition not found");
        Partition storage p = partitions[partitionId];
        require(p.balances[msg.sender] >= amount, "Insufficient balance");

        p.balances[msg.sender] -= amount;
        p.balances[to] += amount;
        emit TransferredByPartition(partitionId, msg.sender, to, amount);
    }

    // --- VIEW FUNCTIONS ---

    function balanceOfByPartition(
        bytes32 partitionId,
        address user
    ) external view returns (uint256) {
        if (!existingPartitions[partitionId]) return 0;
        return partitions[partitionId].balances[user];
    }

    function totalSupplyByPartition(
        bytes32 partitionId
    ) external view returns (uint256) {
        if (!existingPartitions[partitionId]) return 0;
        return partitions[partitionId].totalSupply;
    }

    function getAllPartitions() external view returns (bytes32[] memory) {
        return partitionList;
    }
}
