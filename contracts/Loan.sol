pragma solidity ^0.4.15;

contract Loan {
  /*
    address orgWallet
    address clientWallet
    enum Status {pending -> complete} as loanStatus
    struct LoanInfo as loanInfo
    getLoanInfo() : 

    ?? - add proposal logic so client can accept/decline
    implement onlyWithStatus & auth
  */
  struct LoanInfo {
    uint256 amount;
    uint256 durationInMonths;
    uint256 monthlyPayment;
    bytes32 startDate;
  }
  enum Status { Started, Default, Complete }
  modifier onlyWithStatus(Status _loanStatus) {require(loanStatus == _loanStatus); _;}
  mapping ( uint256 => bool ) paymentHistory;
  LoanInfo public loanInfo;
  Status public loanStatus;
  address public orgWallet;
  address public clientWallet;
  uint256 public currentPaymentCount;
  uint256 public currentSuccessfulPayments;

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
    loanStatus = Status.Started;
    loanInfo = newLoan;
    orgWallet = _orgWallet;
    clientWallet = _clientWallet;
    currentPaymentCount = 0;
    currentSuccessfulPayments = 0;
  }

  function getLoanStatus() constant returns(bytes32) {
    if (loanStatus == Status.Complete) {
      return "Complete";
    } else if (loanStatus == Status.Default) {
      return "Default";
    } else {
      return "Started";
    }
  }

  function getLoanInfo() constant returns
  (
    uint256, 
    uint256, 
    uint256, 
    bytes32, 
    address, 
    address
  ) {
    return (
      loanInfo.amount, loanInfo.durationInMonths, loanInfo.monthlyPayment,
      loanInfo.startDate, orgWallet, clientWallet
    );
  }

  function updateLoanPayment(bool _paymentMade) {
    currentPaymentCount = currentPaymentCount + 1;
    paymentHistory[currentPaymentCount] = _paymentMade;
    if (_paymentMade == true) {
      currentSuccessfulPayments = currentSuccessfulPayments + 1;
    }
  }

  function finalizeLoan(bool _onTime) {
    if (_onTime == true) {
      loanStatus = Status.Complete;
    } else {
      loanStatus = Status.Default;
    }
  }
}