pragma solidity ^0.4.15;
import "./Org.sol";
import "./Loan.sol";
import "./HasLoans.sol";

/// @title Client contract - profile and data storage for a client (aka borrower) belonging to a Bureau
/// @author Nick Gheorghita - <nickgheorghita@gmail.com>
contract Client is HasLoans {

  /*
   *  Storage
   */
  struct SavingsTx {
    uint256 amount;
    uint256 datetime;
    bool txType;  // true = deposit, false = withdrawal
  }
  mapping ( uint256 => SavingsTx ) savingsTxHistory;
  address[] public loanAddresses;
  bytes32 public clientId;
  bytes32 public clientName;
  bytes32 public clientHomeAddress;
  bytes32 public clientBirthday;
  uint256 public clientAge;
  uint8 public clientGender;       // gender 0 = female, 1 = male
  uint8 public clientEducation;    // 0 = none / 1 = ma / 2 = hs / 3 = college / 4 = masters
  uint8 public clientDependents;
  uint8 public clientHouseholdSize;
  bool public clientMarried;
  uint256 public clientPhone;
  address public clientWallet;
  uint256 public numberOfSavingsTxs;
  uint256 public totalNumberOfPayments;
  uint256 public totalNumberOfSuccessfulPayments;
  
  /*
   *  Modifiers
   */
  /// @dev Manages authorization for deposits
  modifier onlyBy(address _account) {require(msg.sender == _account); _;}

  /*
   *  Fallback Function
   */ 
  function () payable { revert(); }

  /*
   *  Public Functions
   */
  /// @dev Constructor sets client storage variables and initializes counters
  function Client(
    bytes32 _id,
    address _clientWallet,
    bytes32 _name,
    bytes32 _homeAddress, 
    bytes32 _birthday, 
    uint256 _age, 
    uint8 _gender, 
    uint8 _education,
    uint8 _householdSize,
    uint8 _dependents,
    bool _married,
    uint256 _phoneNumber
  ) {
    clientId = _id;
    clientName = _name;
    clientHomeAddress = _homeAddress;
    clientBirthday = _birthday;
    clientAge = _age;
    clientGender = _gender;
    clientEducation = _education;
    clientDependents = _dependents;
    clientHouseholdSize = _householdSize;
    clientMarried = _married;
    clientPhone = _phoneNumber;
    clientWallet = _clientWallet;
    totalNumberOfPayments = 0;
    totalNumberOfSuccessfulPayments = 0;
    numberOfSavingsTxs = 0;
  }

  /// @dev Adds a Loan contract address to client's loanAddresses[] when an Org creates one for this client
  function addLoanToClient(address _loanAddress) 
  {
    loanAddresses.push(_loanAddress);
  }

  /// @dev Getter for all Loan contract addresses belonging to this client
  function getLoanAddresses() 
    constant 
    returns (address[]) 
  {
    return loanAddresses;
  }

  /// @dev Getter for count of Loans belonging to this client
  function getNumberOfLoans() 
    constant 
    returns (uint) 
  {
    return loanAddresses.length;
  }

  /// @dev Getter for personal details about this client
  function getPersonalInfo() 
    constant 
  returns (
    address clientWalletAddress,
    bytes32 name, 
    bytes32 homeAddress, 
    bytes32 birthday, 
    uint256 age, 
    uint8 gender, 
    uint8 education,
    uint8 householdSize,
    uint8 dependents,
    bool married,
    uint256 phoneNumber
  ) {
    return ( 
      clientWallet,
      clientName,
      clientHomeAddress,
      clientBirthday,
      clientAge,
      clientGender,
      clientEducation,
      clientHouseholdSize,
      clientDependents,
      clientMarried,
      clientPhone
    );
  }

  /// @dev Deposit collateral/savings/ether into this account
  function deposit() 
    payable 
    returns (bool) 
  {
    uint256 amount = msg.value;
    require(amount > 0);
    numberOfSavingsTxs = numberOfSavingsTxs + 1;
    SavingsTx memory newSavingsTx = SavingsTx(amount, now, true);
    savingsTxHistory[numberOfSavingsTxs] = newSavingsTx;
    return true;
  }

  /// @dev Getter for a particular savings tx (aka deposit or withdrawal)
  function getSavingsTx(uint256 _id) 
    constant 
    returns (uint256, uint256, bool) 
  {
    return (savingsTxHistory[_id].amount, savingsTxHistory[_id].datetime, savingsTxHistory[_id].txType);
  }

  /// @dev Allows only the client to withdraw funds stored in their contract
  function withdrawFunds(uint256 _amount) 
    onlyBy(clientWallet)
    returns (bool) 
  {
    require(_amount <= this.balance);
    numberOfSavingsTxs = numberOfSavingsTxs + 1;
    SavingsTx memory newSavingsTx = SavingsTx(_amount, now, false);
    savingsTxHistory[numberOfSavingsTxs] = newSavingsTx;
    msg.sender.transfer(_amount);
    return true;
  }

  /// @dev Updates stats on clients repayments (totalNumber . . .)
  function updateRepaymentRateStats(bool _paymentMade) 
    public 
  {
    if (_paymentMade)
      totalNumberOfSuccessfulPayments += 1;
    totalNumberOfPayments += 1;
  }
}