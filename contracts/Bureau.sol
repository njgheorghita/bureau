pragma solidity ^0.4.15;
import "./Org.sol";
import "./Client.sol";
import "./Ballot.sol";

contract Bureau {
  /*
    TODO
    better loans ( monthly reports )
    governance / voting 
    auth everywhere
    change deposit to collateral in clients
    

    scope out for now?:
    staking?
    purchasing a client report & kickbacks to orgs &/or client?
    client savings / deposits / collateral

    for ethan
    client's reputation score thing
  /*
    Bureau() : 
    mapping ( orgId => address ) orgList
    mapping ( clientId => address ) clientList
    uint256 numberOfClients
    address ownerAddress
    addOrgToBureau() :
    getOrgInfoById() :
    getOrg() : 
    createClient() : 
    getClientAddressById() :

  */

  // mapping of org id to it's contract address
  mapping ( uint256 => address ) public orgList;
  address[] orgAddresses;
  address public ownerAddress;
  // mapping of client id to it's contract address
  // mapping ( uint256 => address ) public clientList;
  mapping (bytes32 => address) public clientList;
  uint256 public numberOfClients;
  address[] public ballotAddresses;
  
  function Bureau () {
    ownerAddress = msg.sender;
    numberOfClients = 0;
  }

  function addOrgToBureau
  (
    uint256 _id,
    bytes32 _name,
    bytes32 _hqAddress,
    bytes32 _country,
    bytes32 _currency,
    address _orgWallet
  ) 
    returns (address) 
  {
    address newOrgAddress = new Org(
      _id, _name, _hqAddress, _country, _currency, _orgWallet
    );
    orgList[_id] = newOrgAddress;
    orgAddresses.push(newOrgAddress);
    return newOrgAddress;
  }

  function getOrgInfoById(uint256 _id) 
    constant 
    returns (uint256, bytes32, bytes32, bytes32, bytes32, address)
  {
    Org currentOrg = getOrg(_id);
    return currentOrg.getGeneralInfo();
  }

  function getOrg(uint256 _orgId) private returns(Org) {
    address currentOrgAddress = orgList[_orgId];
    Org currentOrg = Org(currentOrgAddress);
    return currentOrg;
  }

  function createClient
  (
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
    address newClientAddress = new Client(
      _id,
      _clientWallet,
      _name,
      _homeAddress,
      _birthday,
      _age,
      _gender,
      _education,
      _householdSize,
      _dependents,
      _married,
      _phoneNumber
    );
    numberOfClients = numberOfClients + 1;
    clientList[_id] = newClientAddress;
  }

  function findClientAddress(bytes32 _id) constant returns(address) {
    require(clientList[_id] != 0x0);
    return clientList[_id];
  }

  function createBallot(bytes32[] _proposals) {
    address newBallotAddress = new Ballot(_proposals, orgAddresses);
    ballotAddresses.push(newBallotAddress);
  }

}