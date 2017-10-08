let Controller = artifacts.require("./Controller.sol");
let Org = artifacts.require("./Org.sol");
let Client = artifacts.require("./Client.sol");
let Bureau = artifacts.require("./Bureau.sol");
let Ballot = artifacts.require("./Ballot.sol");
let Loan = artifacts.require("./Loan.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Controller', function () {
  let controller;
  let org1;
  let org1wallet;
  let org2;
  let org2wallet;
  let bureau;
  let client1;
  let client1Wallet;
  let client2;
  let client2Wallet;
  let org1Address;
  let org2Address;
  let client1Address;
  let client2Address;
  beforeEach(async function() {
    org1Wallet = web3.eth.accounts[1];
    org2Wallet = web3.eth.accounts[2];
    client1Wallet = web3.eth.accounts[3];
    client2Wallet = web3.eth.accounts[4];
    
    bureau = await Bureau.new();
    controller = await Controller.new(bureau.address);

    await bureau.addOrgToBureau(123,"MFI1","111 First St.","USA","USD",org1Wallet);
    await bureau.addOrgToBureau(321,"MFI2","222 Second St.","MEX","PESO",org2Wallet);
    org1Address = await bureau.getOrgAddressById(123)  
    org2Address = await bureau.getOrgAddressById(321)
    org1 = await Org.at(org1Address);
    org2 = await Org.at(org2Address);

    await bureau.createClient("BOBDOE-01/01/2001",client1Wallet,"Bob Doe","333 Third St.","01/01/2001",21,1,2,5,2,true,2120334223);
    await bureau.createClient("ALICESMITH-10/10/2002",client2Wallet,"Alice Smith","444 Fourth St.","10/10/2002",43,0,3,3,1,true,8160372823);

    client1Address = await bureau.findClientAddress("BOBDOE-01/01/2001");
    client2Address = await bureau.findClientAddress("ALICESMITH-10/10/2002");

    client1 = await Client.at(client1Address);
    client2 = await Client.at(client2Address);

    await org1.createLoan("BOBDOE-01/01/2001",1000,10,100,"04/04/2014")
    await org1.createLoan("ALICESMITH-10/10/2002",2000,5,400,"05/05/2015")
  })

  it("can return appropriate loan data for a client or org", async function() {
    let orgLoanData = await controller.getAllLoanDataForAddresses(org1Address);
    let clientLoanData = await controller.getAllLoanDataForAddresses(client1Address);
    
    assert.equal(orgLoanData.length, 6);
    assert.equal(web3.toDecimal(orgLoanData[0][0]), 1000);
    assert.equal(web3.toDecimal(orgLoanData[0][1]), 2000);
    assert.equal(web3.toDecimal(orgLoanData[5][0]), 0);
    assert.equal(web3.toDecimal(orgLoanData[5][1]), 0);

    assert.equal(clientLoanData.length, 6);
    assert.equal(web3.toDecimal(clientLoanData[0][0]), 1000);
  });

  it('can return detailed data for an org', async function() {
    let orgLoanData = await controller.getBasicOrgInfoById(123);
    let orgLoanDetails = await controller.getDetailedOrgInfoById(123);

    assert.equal(orgLoanData.length, 5);
    assert.equal(orgLoanDetails.length, 4);
  });

  it('can return quarterly report data', async function() {
    await org1.addQuarterlyReport(20011, 10000, 42, 2424242, 28);
    let qrData = await org1.getQuarterlyReportData();
    
    assert.equal(qrData.length, 6);
    assert.equal(web3.toDecimal(qrData[0][0]), 20011);
  })

  it('can return list of clientIds that belong to an Org', async function() {
    let clientIds = await controller.getClientIdsForOrg(123);
    assert.equal(clientIds.length, 2);
    assert.equal(web3.toAscii(clientIds[0]).substring(0,17), "BOBDOE-01/01/2001");
  })

  it('can return a list of all clientIds', async function() {
    let clientIds = await controller.getAllClientIds();
    assert.equal(clientIds.length, 2);
    assert.equal(web3.toAscii(clientIds[0]).substring(0,17), "BOBDOE-01/01/2001");
  })

  it('can return detailed info for a client', async function() {
    let clientInfo = await controller.getClientDetailsById("BOBDOE-01/01/2001");
    assert.equal(clientInfo.length, 9);
  })

  it('can return all proposal data', async function() {
    let ballotAddress = await bureau.ballotAddress();
    let ballot = await Ballot.at(ballotAddress);
    await ballot.addProposal('More Stuff');
    await ballot.addProposal('More Things');
    await ballot.voteFor(0);
    await ballot.voteFor(0);
    await ballot.voteAgainst(0);
    await ballot.voteFor(1);
    await ballot.voteAgainst(1);
    await ballot.voteAgainst(1);
    await ballot.voteAgainst(1);
    await ballot.voteFor(1);

    let ballotData = await controller.getBallotData();
    assert.equal(ballotData.length, 3);
  })

  it('can interact with ballot via controller', async function() {
    await controller.addProposal('More Stuff');
    await controller.addProposal('More Things');
    await controller.voteFor(0);
    await controller.voteFor(0);
    await controller.voteAgainst(0);
    await controller.voteFor(1);
    await controller.voteAgainst(1);
    await controller.voteAgainst(1);
    await controller.voteAgainst(1);
    await controller.voteFor(1);

    let ballotData = await controller.getBallotData();
    assert.equal(ballotData.length, 3);
    assert.equal(web3.toDecimal(ballotData[1][1]), 2);
  })

  // from org.js
  // it('can retrieve accurate loan data for a clients profile view', async function() {
  //   await org2.createLoan(111,100,10,10,"1/1/1111");
  //   let clientLoans = await org2.getLoansByClientId(111);
  //   await org2.updateLoanByAddress(clientLoans[0], true);
  //   await org2.updateLoanByAddress(clientLoans[0], true);
  //   await org2.updateLoanByAddress(clientLoans[0], false);
  //   let clientLoanData = await client.getAllLoanData();
  //   // let orgLoanData = await org2.getAllLoanData();
    
  //   assert.equal(clientLoanData.length, 6);
  //   assert.equal(web3.toDecimal(clientLoanData[0][0]), 100);
  //   assert.equal(web3.toDecimal(clientLoanData[1][0]), 10);
  //   // assert.equal(orgLoanData.length, 6);
  //   // assert.equal(web3.toDecimal(orgLoanData[0][0]), 100);
  //   // assert.equal(web3.toDecimal(orgLoanData[1][0]), 10);
  // })

  // it('can retrieve accurate client data for an orgs profile view', async function() {
  //   await org2.createLoan(111,100,10,10,"1/1/1111");
  //   let clientLoans = await org2.getLoansByClientId(111);
  //   await org2.updateLoanByAddress(clientLoans[0], true);
  //   await org2.updateLoanByAddress(clientLoans[0], true);
  //   await org2.updateLoanByAddress(clientLoans[0], false);
  //   let clientLoanData = await client.getAllClientData();
  //   console.log(clientLoanData);
  //   assert.equal(clientLoanData.length, 6);
  // })


  // from client.js
  // it('returns right data for frontend client show view', async function() {
  //   await client.deposit({value: 100, from: clientWallet});
  //   let personalInfo = await client.getFrontEndData();
    
  //   assert.equal(personalInfo.length, 10);
  //   assert.equal(web3.toAscii(personalInfo[0]).substring(0,6), "Client");
  //   assert.equal(web3.toAscii(personalInfo[1]).substring(0,10), "01/01/2000");
  //   assert.equal(web3.toDecimal(personalInfo[2]), 100);
  //   assert.equal(web3.toDecimal(personalInfo[3]), 0);
  //   assert.equal(web3.toDecimal(personalInfo[4]), 4);
  //   assert.equal(personalInfo[5], false);
  //   assert.equal(web3.toDecimal(personalInfo[6]), 1231221323);
  //   assert.equal(web3.toDecimal(personalInfo[7]), 100);
  //   assert.equal(web3.toDecimal(personalInfo[8]), 0);
  //   assert.equal(web3.toDecimal(personalInfo[9]), 0);
  // })
});
