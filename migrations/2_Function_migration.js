const Function = artifacts.require("Function");

module.exports = async function (deployer, network, accounts) {

deployer.deploy(Function)

// let proxy = await Proxy.deployed()
// let funk = await Function.deployed()

// console.log(proxy)
// console.log(funk)
    // const funk = await Function.new()
// const proxy = await Proxy.new()

//const proxy = await deployer.deploy(Proxy)

// let pf = await Function.at(proxy.address)
// await pf.setTheNumber('number', 10)

// num = await pf.gettheNumber('number');
// console.log("After change: " + num.toNumber());
};
