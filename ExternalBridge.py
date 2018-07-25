from web3 import Web3, HTTPProvider
import web3
import time

addrk="0x703b9c628ca22f898de9a869f53e0e970b02af3d"#address of the kovan contract 
addrs="0x3a66634c93990215f4cffa84c96d2c9e69314df6"#address of the sokol contract 

#all addresses
#ForeignPhone 0xd620fb2e91ba691becab3dc43bc644ea71e8df46
#ForeignBridge 0x703b9c628ca22f898de9a869f53e0e970b02af3d
#HomePhone 0xa63976e06cba60b0a828e3092fea05ee7370b1d9
#HomeBridge 0x3a66634c93990215f4cffa84c96d2c9e69314df6

pk=web3.eth.to_hex(Web3.sha3(text="The Great Bridge between BlockChains"))#private key for External Bridge

abik=open("ABIk.txt").read()#reading abi of the kovan contract
abis=open("ABIs.txt").read()#reading abi of the sokol contract

kovan=Web3(HTTPProvider("https://kovan.infura.io/"))#connecting to the kovan
sokol=Web3(HTTPProvider("https://sokol.poa.network/"))#connecting to the sokol

#initializing accounts for BlockChains
localak=kovan.eth.account.privateKeyToAccount(pk)
localas=sokol.eth.account.privateKeyToAccount(pk)
#0x9c069F7Dbeec58ce2a6DF486De239e32b397D475

#initializing contracts
contr_k=kovan.eth.contract(address=Web3.toChecksumAddress(addrk), abi=abik)
contr_s=sokol.eth.contract(address=Web3.toChecksumAddress(addrs), abi=abis)

#transaction body
txDict={"from":localak.address, 'gas': 4000000, 'gasPrice':1000}

k1=0#starting block for kovan
k2=0#ending block for kovan

s1=0#starting block for sokol
s2=0#ending block for sokol

while (True):
  k2=kovan.eth.getBlock("latest")["number"]#getting last block of kovan
  filter_k={"fromBlock":k1,"toBlock":k2,"address":addrk}#initializing a filter for kovan
  logs_k=kovan.eth.getLogs(filter_k)#getting logs for kovan
  for log in logs_k:#processing every log
    tx=log["transactionHash"]#getting hash of every transaction
    rec=kovan.eth.getTransactionReceipt(tx)#getting receipt of every transaction
    events=contr_k.events.CametoBridge().processReceipt(rec)#getting events of every receipt
    print(events)
    for event in events:#processing every event
      #getting parameters from event
      _data=event.args['data']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      contr_s.functions.preTransfer(tx,_tokenId,_data,_reciever).transact(txDict)#transact function from another bridge
  k1=k2+1;#updating starting block for kovan

  s2=sokol.eth.getBlock("latest")["number"]#getting last block of sokol
  filter_s={"fromBlock":s1,"toBlock":s2,"address":addrs}#initializing a filter for sokol
  logs_s=sokol.eth.getLogs(filter_s)#getting logs for sokol
  for log in logs_s:#processing every log
    tx=log["transactionHash"]#getting hash of every transaction
    rec=sokol.eth.getTransactionReceipt(tx)#getting receipt of every transaction
    events=contr_s.events.CametoBridge().processReceipt(rec)#getting events of every receipt
    for event in events:
      #getting parameters from event
      _data=event.args['data']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      contr_k.functions.preTransfer(tx,_tokenId,_data,_reciever).transact(txDict)#transact function from another bridge
  s1=s2+1;#updating starting block for sokol

  time.sleep(10)#sleeping to do not make too many requests
