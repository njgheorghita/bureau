pragma solidity ^0.4.15;
import "./Org.sol";

contract Client {
  /*
    CLIENT INFO
    struct PersonalInfo
    PersonalInfo clientInfo
    address clientWallet
    address orgWallet // not good
    Client() : 
    getPersonalInfo() : onlyByOrgOrClient

    !! add fields for monthlyHouseholdIncome, numOfBusinesses, numOfEmployees?

    JOBS
    struct Job
    mapping (#job => Job )
    uint256 numberofjobs
    addJob() : onlyBy(orgWallet)
    getJob() :

    LOANS
    struct Loan
    mapping (_id => Loan) loanHistory
    uint256[] loanIds
    addLoan() : onlyBy(orgWallet)
    getLoanRepaymentRate() : 
    getLoan() : 

    SAVINGS
    struct SavingsTx
    uint256 numOfSavingsTx
    mapping (#ofSavingsTx => SavingsTx) savingsTxHistory
    deposit() : onlyBy(clientWallet)
    getSavingsTx() :
    withdrawFunds() : onlyBy(clientWallet)

  */
  struct PersonalInfo {
    bytes32 name;
    bytes32 homeAddress;
    bytes32 birthday;
    uint256 age; 
    uint8 gender; // gender 0 = female, 1 = male
    uint8 education; // 0 = none / 1 = ma / 2 = hs / 3 = college / 4 = masters
    uint8 householdSize;
    uint8 dependents;
    bool married;
    uint256 phoneNumber; // 0 for doesn't have one
  }
  struct Job {
    bytes32 title;
    bytes32 employer;
    bytes32 workAddress;
    bytes32 startDate;
    bytes32 endDate;
    uint256 monthlySalary;
  }
  struct SavingsTx {
    uint256 amount;
    uint256 datetime;
    bool txType;  // true = deposit, false = withdrawal
  }
  mapping ( uint256 => SavingsTx ) savingsTxHistory;
  mapping ( uint256 => Job ) public jobHistory;
  PersonalInfo public clientInfo;
  address[] public loanAddresses;
  bytes32 public clientId;
  uint256 public numberOfJobs;
  bytes32 public clientName;
  bytes32 public clientBirthday;
  address public clientWallet;
  address public orgWallet;
  uint256 public numberOfSavingsTxs;
  uint256 public totalNumberOfPayments;
  uint256 public totalNumberOfSuccessfulPayments;
  modifier onlyBy(address _account) {require(msg.sender == _account); _;}
  modifier onlyByOrgOrClient() {
    require(msg.sender == orgWallet || msg.sender == clientWallet); _;
  }

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
    clientInfo = PersonalInfo({
      name: _name,
      homeAddress: _homeAddress,
      birthday: _birthday,
      age: _age,
      gender: _gender,
      education: _education,
      householdSize: _householdSize,
      dependents: _dependents,
      married: _married,
      phoneNumber: _phoneNumber
    });
    orgWallet = msg.sender;
    clientWallet = _clientWallet;
    totalNumberOfPayments = 0;
    totalNumberOfSuccessfulPayments = 0;
    numberOfJobs = 0;
    numberOfSavingsTxs = 0;
    clientName = _name;
    clientBirthday = _birthday;
    clientId = _id;
  }

  function addLoanToClient(address _loanAddress) {
    loanAddresses.push(_loanAddress);
  }

  function getLoanAddresses() constant returns(address[]) {
    return loanAddresses;
  }

  function getPersonalInfo() constant onlyByOrgOrClient() returns (
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
      clientInfo.name,
      clientInfo.homeAddress,
      clientInfo.birthday,
      clientInfo.age,
      clientInfo.gender,
      clientInfo.education,
      clientInfo.householdSize,
      clientInfo.dependents,
      clientInfo.married,
      clientInfo.phoneNumber
    );
  }

  function addJob(
    bytes32 _title,
    bytes32 _employer,
    bytes32 _workAddress,
    bytes32 _startDate,
    bytes32 _endDate,
    uint256 _monthlySalary
  ) 
    onlyBy(orgWallet) 
  {
    numberOfJobs = numberOfJobs + 1;
    Job memory newJob = Job(_title, _employer, _workAddress, _startDate, _endDate, _monthlySalary);
    jobHistory[numberOfJobs] = newJob;
  }

  function getJob(uint256 _id) constant returns (bytes32, bytes32, bytes32, bytes32, bytes32, uint256) {
    Job memory currentJob = jobHistory[_id];
    return (
      currentJob.title,
      currentJob.employer,
      currentJob.workAddress,
      currentJob.startDate,
      currentJob.endDate,
      currentJob.monthlySalary
    );
  }

  function deposit() 
    payable 
    onlyBy(clientWallet)
    returns(bool) 
  {
    uint256 amount = msg.value;
    require(amount > 0);
    numberOfSavingsTxs = numberOfSavingsTxs + 1;
    SavingsTx memory newSavingsTx = SavingsTx(amount, now, true);
    savingsTxHistory[numberOfSavingsTxs] = newSavingsTx;
    // why do these throw?
    // Org(orgWallet).updateGrossDeposits(amount, true);
    return true;
  }

  function getSavingsTx(uint256 _id) constant returns(uint256, uint256, bool) {
    return (savingsTxHistory[_id].amount, savingsTxHistory[_id].datetime, savingsTxHistory[_id].txType);
  }

  function withdrawFunds(uint256 _amount) 
    onlyBy(clientWallet)
    returns (bool) 
  {
    require(_amount <= this.balance);
    numberOfSavingsTxs = numberOfSavingsTxs + 1;
    SavingsTx memory newSavingsTx = SavingsTx(_amount, now, false);
    savingsTxHistory[numberOfSavingsTxs] = newSavingsTx;
    // why do these throw?
    // Org(orgWallet).updateGrossDeposits(_amount, false);
    msg.sender.transfer(_amount);
    return true;
  }

  function updateRepaymentRateStats(bool _paymentMade) public {
    if (_paymentMade)
      totalNumberOfSuccessfulPayments += 1;
    totalNumberOfPayments += 1;
  }
}