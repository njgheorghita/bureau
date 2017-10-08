let Bureau = artifacts.require("./Bureau.sol");
let Client = artifacts.require("./Client.sol");

require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Bureau', function() {
  let bureau;
  let clientWallet;

  beforeEach(async function() {
    bureau = await Bureau.new();
    clientWallet = web3.eth.accounts[2]
  });

  it('it instantiates correctly', async function() {
    let bureauOwner = await bureau.ownerAddress();

    assert.equal(web3.eth.accounts[0], bureauOwner)
  });

  it('it can add an org to the bureau', async function() {
    await bureau.addOrgToBureau(
      123,                // id
      "MFI",              // name
      "111 First St.",    // hqAddress
      "USA",              // country
      "USD",              // currency
      web3.eth.accounts[5]
    );

    let newOrg = await bureau.getOrgInfoById(123);
    assert.equal(newOrg[1], 123);
  });

  it('can return appropriate data for front end', async function() {
    await bureau.addOrgToBureau(1,"MFI1","ADDRESS1","USA","USD",web3.eth.accounts[5]);
    await bureau.addOrgToBureau(2,"MFI2","ADDRESS2","MEX","PESO",web3.eth.accounts[6]);
    let orgData = await bureau.getAllOrgInfo();
    assert.equal(web3.toDecimal(orgData[0][0]), 1)
    assert.equal(web3.toDecimal(orgData[0][1]), 2)
    assert.equal(web3.toAscii(orgData[1][0]).substring(0,4), "MFI1")
    assert.equal(web3.toAscii(orgData[1][1]).substring(0,4), "MFI2")
  });

  // context("voting", async function() {
  //   it('it can create a ballot', async function() {
  //     await bureau.createBallot(["First", "Second"]);
  //     let ballotAddresses = await bureau.ballotAddresses(0);

  //     assert.notInclude(ballotAddresses[0], "0000000")
  //   })
  // })

  context("with a client", async function() {
    beforeEach(async function() {
      await bureau.createClient(
        "Client-01/01/2000",                // id
        clientWallet,                       // Client wallet address
        "Client",                           // name
        "1234 5th Street, Denver CO 80218", // homeAddress
        "01/01/2000",                       // birthday
        100,                                // age
        0,                                  // gender
        4,                                  // education
        6,                                  // householdSize
        3,                                  // dependents
        false,                              // married
        1231221323                          // phoneNumber
      )
      await bureau.createClient("Other-01/20/2003", web3.eth.accounts[9], "Other", "Address", "01/20/2003",
        123, 0, 3, 3, 1, true, 1412333234234
      )
    });

    it('can create a new client', async function() {
      let clientAddress = await bureau.findClientAddress("Client-01/01/2000");
      let clientContract = await Client.at(clientAddress);
      let clientContractWallet = await clientContract.clientWallet();

      assert.equal(clientContractWallet, clientWallet);
    });

    it('can search for a client', async function() {
      let clientAddress = await bureau.findClientAddress("Client-01/01/2000")
      
      assert.notInclude(clientAddress, "00000000000");
    })


    // it("can add a job to a clients profile", async function() {
    //   let clientAddress = await org.getClientAddressById(1);

    //   // clientId, title, employer, workAddress, startDate, endDate, monthlySalary
    //   await org.addJobToClientProfile(1, "Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000, {from: orgWallet});

    //   let client = await Client.at(clientAddress);
    //   let jobHistory = await client.getJob(1);
    //   assert.equal(jobHistory.length, 6);
    //   assert.equal(web3.toAscii(jobHistory[1]).substring(0,6), "Paddys");
    // });
  
    // it("only allows the orgWallet to add job to client", async function() {
    //   try {
    //     await org.addJobToClientProfile(1,"Janitor", "Paddys", "Philadelphia", "1/1/2001", "1/1/2002", 1000, {from: web3.eth.accounts[4]})
    //   } catch(err) {
    //     assert.include(String(err), "invalid opcode");
    //   }
    // });
  });
});