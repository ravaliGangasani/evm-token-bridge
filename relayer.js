const Web3 = require('web3')
const Bridge = require('./build/contracts/Bridge.json')
const Tx = require('ethereumjs-tx').Transaction

const HDWalletProvider = require('@truffle/hdwallet-provider')
const fs = require('fs')
const { CountQueuingStrategy } = require('stream/web')
const mnemonic = fs.readFileSync('.secret').toString().trim()

const RINKEBY_WS = `wss://rinkeby.infura.io/ws/v3/b00aa9ce2f74470592a82ed60496939e`
const ROPSTEN_HTTP = `https://ropsten.infura.io/v3/b00aa9ce2f74470592a82ed60496939e`

const web3 = new Web3(RINKEBY_WS)
const web3HTTP = new Web3(new Web3.providers.HttpProvider(ROPSTEN_HTTP))

// get Account
const myAccount = web3.eth.accounts.privateKeyToAccount(mnemonic)
const privateKeyBuffer = Buffer.from(
    myAccount.privateKey.substring(2, 66),
    'hex',
)


const init = async () => {

console.log("Listening for events...")
//chain id
const id = await web3.eth.net.getId()
const deployentNetwork = Bridge.networks[id]
const eventMainBridge = new web3.eth.Contract(
    Bridge.abi,
    deployentNetwork.address,
)

// destination chain
const ropstenID = await web3HTTP.eth.net.getId()
const ropstenDeployentNetwork = Bridge.networks[ropstenID]
const ropstenBridge = new web3HTTP.eth.Contract(
    Bridge.abi,
    ropstenDeployentNetwork.address,
)

    eventMainBridge.events
        .TokensLocked({}, function (error, event) { })
        .on('data', async (event) => {
            if (event.event == 'TokensLocked') {
                let makerContract = event.returnValues.makerContract
                let takerContract = event.returnValues.takerContract

                console.log("Event Captured...")

                let data = web3.eth.abi.decodeParameters(
                    ['address', 'uint256', 'uint'],
                    event.raw.data,
                )

                web3HTTP.eth
                    .getTransactionCount(myAccount.address)
                    .then(async (count) => {
                        nonce = count.toString(16)

                        const rawTx = {
                            from: myAccount.address,
                            to: ropstenDeployentNetwork.address,
                            data: ropstenBridge.methods
                                .mint(takerContract, makerContract, data[0], data[1])
                                .encodeABI(),
                            value: '0x00',
                            gas: web3.utils.toHex(80000),
                            gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'Gwei')),
                            nonce: '0x' + nonce,
                        }

                        const tx = new Tx(rawTx, { chain: 'ropsten' })
                        console.log("building and broadcasting msg for other chain...")
                        tx.sign(privateKeyBuffer)

                        const serializedTx = tx.serialize()
                        const raw = '0x' + serializedTx.toString('hex')

                        var result = await web3HTTP.eth.sendSignedTransaction(raw)
                        console.log(result.status, result.transactionHash)
                    })
            }
        })
}
init();
