const Proxy = artifacts.require('Proxy');

module.exports = async function (deployer, network, accounts) {

deployer.deploy(Proxy)
//
// const funk = await Function.new()
// const proxy = await Proxy.new()

//const proxy = await deployer.deploy(Proxy)

//let pf = await Function.at(proxy.address)
// await pf.setTheNumber('number', 10)

// num = await pf.gettheNumber('number');
// console.log("After change: " + num.toNumber());
};
