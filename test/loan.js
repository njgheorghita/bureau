let Loan = artifacts.require("./Loan.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Loan', function() {
  let loan; 
  let orgWallet;
  let clientWallet;

  beforeEach(async function() {
    orgWallet = web3.eth.accounts[1];
    clientWallet = web3.eth.accounts[2];

    // create new loan
    loan = await Loan.new(
      120,          // amount
      12,           // durationInMonths
      10,           // monthlyPayment
      "1/1/2001",   // startDate
      orgWallet,
      clientWallet 
    );
  });

  it('it instantiates correctly', async function() {
    let loanInfo = await loan.getLoanInfo();

    assert.equal(web3.toDecimal(loanInfo[0]), 120);
    assert.equal(web3.toDecimal(loanInfo[1]), 12);
    assert.equal(web3.toDecimal(loanInfo[2]), 10);
    assert.equal(web3.toAscii(loanInfo[3]).substring(0,8), "1/1/2001");
    assert.equal(web3.toDecimal(loanInfo[4]), orgWallet);
    assert.equal(web3.toDecimal(loanInfo[5]), clientWallet);
  });
})