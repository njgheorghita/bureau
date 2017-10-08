pragma solidity 0.4.15;

contract HasLoans {
  address[] public loanAddresses;

  function getNumberOfLoans() constant returns(uint);
}