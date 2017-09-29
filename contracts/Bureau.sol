pragma solidity ^0.4.15;
import "./Org.sol";
import "./Client.sol";


contract Bureau {
  /*
    TODO
    auth everywhere
    move client creation to bureau 
    client multi-tenancy w/ orgs
    better loans ( monthly reports )
    client search
    stats / reputation scores
    governance 
    

    scope out for now:
    purchasing a client report & kickbacks to orgs &/or client?
  /*
    address ownerAddress
    Bureau() : 
    mapping ( orgId => address ) orgList
    addOrgToBureau() :
    getOrgInfoById() :
    getOrg() : 

  */
  address public ownerAddress;

  function Bureau () {
    ownerAddress = msg.sender;
  }
  // mapping of org id to it's contract address
  mapping ( uint256 => address ) public orgList;

  function addOrgToBureau
  (
    uint256 _id,
    bytes32 _name,
    bytes32 _hqAddress,
    bytes32 _country,
    bytes32 _currency,
    address _orgWallet
  ) {
    address newOrgAddress = new Org(
      _id, _name, _hqAddress, _country, _currency, _orgWallet
    );
    orgList[_id] = newOrgAddress;
  }

  function getOrgInfoById(uint256 _id) constant returns(
    uint256,bytes32,bytes32,bytes32,bytes32,address
  ) {
    Org currentOrg = getOrg(_id);
    return currentOrg.getGeneralInfo();
  }

  function getOrg(uint256 _orgId) returns(Org) {
    address currentOrgAddress = orgList[_orgId];
    Org currentOrg = Org(currentOrgAddress);
    return currentOrg;
  }

  mapping ( uint256 => address ) public clientList;

  function createClient
  (
    uint256 _id,
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
    clientList[_id] = newClientAddress;
  }

  function getClientAddressById(uint256 _id) constant returns(address) {
    return clientList[_id];
  }
}