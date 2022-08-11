var Bridge = artifacts.require("Bridge");
var SampleToken = artifacts.require("SampleToken")

// Rinkeby Testnet Deploy
// module.exports = async function(deployer, network,accounts) {
  

//       // Bridge Deployment;
//       await deployer.deploy(Bridge,accounts[0]);
//       const deployedBridgeInstance = await Bridge.deployed()
//       console.log("Bridge Token Deployed: ", deployedBridgeInstance.address);

//     // Token Deployment
//   await deployer.deploy(SampleToken,"100000000000000000000000",accounts[0]);
//   const deployedInstance = await SampleToken.deployed()
//   console.log("Sample Token Deployed: ", deployedInstance.address);
  
  
    
// };
// Ropsten network for minting 
module.exports = async function(deployer, network,accounts) {
  

    // Bridge Deployment;
    await deployer.deploy(Bridge,accounts[0]);
    const deployedBridgeInstance = await Bridge.deployed()
    console.log("Bridge Token Deployed: ", deployedBridgeInstance.address);
    
  // Token Deployment
await deployer.deploy(SampleToken,"100000000000000000000000",deployedBridgeInstance.address);
const deployedInstance = await SampleToken.deployed()
console.log("Sample Token Deployed: ", deployedInstance.address);
};


