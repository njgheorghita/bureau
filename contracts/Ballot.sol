pragma solidity ^0.4.15;

contract Ballot {

    bytes32[] public proposalNames;
    uint256[] public forCounts;
    uint256[] public againstCounts;

    address public chairperson;

    /// Create a new ballot to choose one of `proposalNames`.
    function Ballot() {
        chairperson = msg.sender;
    }

    function getNumberOfProposals() returns(uint) {
        return proposalNames.length;
    }

    function addProposal(bytes32 _propName) {
        proposalNames.push(_propName);
        forCounts.push(0);
        againstCounts.push(0);
    }

    function voteFor(uint _propNum) {
        require(_propNum < proposalNames.length);
        forCounts[_propNum] += 1;
    }
    
    function voteAgainst(uint _propNum) {
        require(_propNum < proposalNames.length);
        againstCounts[_propNum] += 1;
    }
}