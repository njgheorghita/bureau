pragma solidity ^0.4.15;

contract Loan {

  enum Status { Started, Default, Complete }
  modifier onlyWithStatus(Status _loanStatus) {require(loanStatus == _loanStatus); _;}
  mapping ( uint256 => bool ) paymentHistory;
  uint256 public loanAmount;
  uint256 public loanDurationInMonths;
  uint256 public loanMonthlyPayment;
  bytes32 public loanStartDate;
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
    loanStatus = Status.Started;
    orgWallet = _orgWallet;
    clientWallet = _clientWallet;
    currentPaymentCount = 0;
    currentSuccessfulPayments = 0;
    loanAmount = _amount;
    loanDurationInMonths = _durationInMonths;
    loanMonthlyPayment = _monthlyPayment;
    loanStartDate = _startDate;
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
      loanAmount, loanDurationInMonths, loanMonthlyPayment,
      loanStartDate, orgWallet, clientWallet
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