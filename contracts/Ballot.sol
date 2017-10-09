pragma solidity ^0.4.15;

/// @title Ballot contract - manages proposals and voting
/// @author Nick Gheorghita - <nickgheorghita@gmail.com>
contract Ballot {
    /*
     *  Storage
     */
    /// @dev Array of all proposal names 
    /// @dev A proposals id is their index in this array
    bytes32[] public proposalNames;

    /// @dev Array of tally of forCounts for a proposal (based on index)
    uint256[] public forCounts;

    /// @dev Array of tally of againstCount for a proposal (based on index)
    uint256[] public againstCounts;

    /// @dev Address of chairperson (the owning Bureau contract)
    address public chairperson;

    /// @dev Create a new ballot to choose one of `proposalNames`.
    function Ballot() {
        chairperson = msg.sender;
    }

    /*
     *  Fallback Function
     */ 
    function () payable { revert(); }

    /*
     *  Public Functions
     */
    /// @dev Getter for number of proposals - used by Controller.sol
    function getNumberOfProposals() 
        returns (uint) 
    {
        return proposalNames.length;
    }

    /// @dev Add a proposal to Ballot and push a 0 to forCounts[] and againstCounts[]
    function addProposal(bytes32 _propName) 
    {
        proposalNames.push(_propName);
        forCounts.push(0);
        againstCounts.push(0);
    }

    /// @dev Increment the forCounts[] index for a proposal
    function voteFor(uint _propNum) 
    {
        require(_propNum < proposalNames.length);
        forCounts[_propNum] += 1;
    }
    
    /// @dev Increment the againstCounts[] for a proposal
    function voteAgainst(uint _propNum) 
    {
        require(_propNum < proposalNames.length);
        againstCounts[_propNum] += 1;
    }
}