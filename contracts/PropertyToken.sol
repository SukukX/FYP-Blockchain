// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PropertyToken is ERC20, Ownable {
    struct Property {
        string name;         // e.g. "Green Villa"
        uint256 valuation;   // e.g. 1000000 (in USD or any off-chain currency you agree on)
        uint256 tokenSupply; // how many tokens minted to represent the property
        address owner;       // who submitted/owns this property
        bool exists;
    }

    // propertyId → Property details
    mapping(uint256 => Property) public properties;
    uint256 public propertyCounter;

    constructor() ERC20("Property Token", "PROP") Ownable(msg.sender) {}

    /// @notice Tokenize a property (create record + mint tokens)
    function tokenizeProperty(
        string memory _name,
        uint256 _valuation,
        uint256 _tokenSupply
    ) public {
        require(_tokenSupply > 0, "Supply must be > 0");

        // increase property ID
        propertyCounter++;

        // create struct
        properties[propertyCounter] = Property({
            name: _name,
            valuation: _valuation,
            tokenSupply: _tokenSupply,
            owner: msg.sender,
            exists: true
        });

        // mint tokens for property owner
        _mint(msg.sender, _tokenSupply);
    }

    /// @notice Get details of a property
    function getProperty(uint256 _propertyId)
        public
        view
        returns (Property memory)
    {
        require(properties[_propertyId].exists, "Property does not exist");
        return properties[_propertyId];
    }
}
