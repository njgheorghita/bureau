let Loan = artifacts.require("./Loan.sol");
require("../node_modules/web3/packages/web3-utils/src/index.js");

contract('Loan', function() {
  let loan; 

  beforeEach(async function() {
    loan = await Loan.new(



    );
  });

  it('it instantiates correctly', async function() {
    let loanInfo = await loan.getInfo();

    assert.equal(web3.toDecimal(orgInfo[0]), 123);
  });
})