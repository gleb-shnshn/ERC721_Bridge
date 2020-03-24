from web3 import Web3, HTTPProvider
import time
import json


class EventListener:
    def __init__(self, contract_address, abi_name, tag, from_web3, to_web3):
        abi = open(abi_name).read()
        self.contract_address = Web3.toChecksumAddress(contract_address)
        self.web3 = from_web3
        self.tag = tag
        self.to_web3 = to_web3
        self.contract = self.web3.eth.contract(address=self.contract_address, abi=abi)
        self.account = self.web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
        self.account_to = self.to_web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
        self.address = self.account.address
        blocks = json.loads(open("lastBlocks.json").read())
        self.from_block = blocks[self.tag]
        self.to_block = blocks[self.tag]

    def listen(self):
        self.to_block = self.web3.eth.getBlock("latest")["number"]  # getting last block
        filter_settings = {"fromBlock": self.from_block, "toBlock": self.to_block,
                           "address": self.contract_address}  # initializing a filter
        logs = self.web3.eth.getLogs(filter_settings)  # getting logs
        for log in logs:  # processing every log
            tx_hash = log["transactionHash"]  # getting hash of every transaction
            receipt = self.web3.eth.getTransactionReceipt(tx_hash)  # getting receipt of every transaction
            events = self.contract.events.CametoBridge().processReceipt(receipt)  # getting events of every receipt
            for event in events:  # processing every event
                # getting parameters from event
                _weight = event.args['weight']
                _demolished = event.args['demolished']
                _color = event.args['color']
                _model = event.args['model']
                _brand = event.args['brand']
                _tokenId = event.args['tokenId']
                _receiver = event.args['reciever']

                nonce = self.to_web3.eth.getTransactionCount(self.address)
                TX_SAMPLE["nonce"] = nonce
                tx = self.contract.functions.preTransfer(tx_hash,
                                                         _tokenId,
                                                         _weight,
                                                         _demolished,
                                                         _color,
                                                         _model,
                                                         _brand,
                                                         _receiver).buildTransaction(TX_SAMPLE)
                signed_tx = self.account_to.signTransaction(tx)
                tx_hash = self.to_web3.eth.sendRawTransaction(
                    signed_tx.rawTransaction)  # transact function to another bridge
                self.to_web3.eth.waitForTransactionReceipt(tx_hash)
        self.from_block = self.to_block + 1

        blocks = json.load(open("lastBlocks.json", "r"))
        blocks[self.tag] = self.from_block
        json.dump(blocks, open("lastBlocks.json", "w"))


PRIVATE_KEY = Web3.toHex(Web3.sha3(text="The Great Bridge between BlockChains"))  # private key for External Bridge
DELAY = 5  # delay between checks

kovan_address = "0xa957b650ae9fa405a56e6d5c9dba171d5a60a1df"  # address of the kovan contract
sokol_address = "0xa56319b3f889f3ef0b52b658df101ab66a305214"  # address of the sokol contract

# all addresses
# ForeignPhone 0x972e2d8cf6d42c4af7a35c4a0ef38aa40ed720ac
# ForeignBridge 0xa957b650ae9fa405a56e6d5c9dba171d5a60a1df
# HomePhone 0xe4ed463889a926006f0de7b34cbfaad7deedfc62
# HomeBridge 0xa56319b3f889f3ef0b52b658df101ab66a305214
kovan_web3 = Web3(HTTPProvider("https://kovan.infura.io/"))
sokol_web3 = Web3(HTTPProvider("https://sokol.poa.network/"))
kovan_listener = EventListener(kovan_address, "ABIk.txt", "lastBlockKovan", kovan_web3, sokol_web3)
sokol_listener = EventListener(sokol_address, "ABIs.txt", "lastBlockSokol", sokol_web3, kovan_web3)

# transaction body
TX_SAMPLE = {"from": kovan_listener.address, 'gas': 8000000, 'gasPrice': Web3.toWei(20, "gwei")}

while True:
    kovan_listener.listen()
    sokol_listener.listen()
    time.sleep(DELAY)
