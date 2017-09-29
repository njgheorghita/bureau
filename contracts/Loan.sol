pragma solidity ^0.4.15;

contract Loan {
  /*
    address orgWallet
    address clientWallet
    enum Status {pending -> complete} as loanStatus
    struct LoanInfo {amount, durationInMonths, monthlyPayment, startDate}
      as loanInfo
    getLoanInfo() : 
  */
  address public orgWallet;
  address public clientWallet;
  Status public loanStatus;
  LoanInfo public loanInfo;
  
  enum Status { PendingApproval, Declined, Started, Default, Complete }

  struct LoanInfo {
    uint256 amount;
    uint256 durationInMonths;
    uint256 monthlyPayment;
    bytes32 startDate;
  }

  function Loan
  (
    uint256 _amount,
    uint256 _durationInMonths,
    uint256 _monthlyPayment,
    bytes32 _startDate,
    address _orgWallet,
    address _clientWallet
  ) {
    // require (monthlyPayment * durationInMonths) == amount ??
    LoanInfo memory newLoan = LoanInfo(
      _amount, _durationInMonths, _monthlyPayment, _startDate
    );
    loanInfo = newLoan;
    orgWallet = _orgWallet;
    clientWallet = _clientWallet;
  }

  function getLoanInfo() constant returns
  (
    uint256, uint256, uint256, bytes32, address, address
  ) {
    return (
      loanInfo.amount, loanInfo.durationInMonths, loanInfo.monthlyPayment,
      loanInfo.startDate, orgWallet, clientWallet
    );
  }
}