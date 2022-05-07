var TestComplete = artifacts.require('Test');

contract('TestOK', accounts => {
    const inID = 20;
    const x = 20;
    const y = 31;
    describe('just for test', function () {
        beforeEach(async function () {
            this.contract = await TestComplete.new(inID);
        });
        it('just for testing', async function() {
            const myValue = await this.contract.getA.call(x, y) ;
            assert.equal(myValue, y-x, 'error: Values do not match');
        });
    });
});