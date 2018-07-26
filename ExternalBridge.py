from web3 import Web3, HTTPProvider
import web3
import time

addrk="0xa957b650ae9fa405a56e6d5c9dba171d5a60a1df"#address of the kovan contract 
addrs="0xa56319b3f889f3ef0b52b658df101ab66a305214"#address of the sokol contract 

#all addresses
#ForeignPhone 0x972e2d8cf6d42c4af7a35c4a0ef38aa40ed720ac
#ForeignBridge 0xa957b650ae9fa405a56e6d5c9dba171d5a60a1df
#HomePhone 0xe4ed463889a926006f0de7b34cbfaad7deedfc62
#HomeBridge 0xa56319b3f889f3ef0b52b658df101ab66a305214

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
txDict={"from":localak.address, 'gas': 8000000, 'gasPrice':Web3.toWei(20, "gwei")}

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
    for event in events:#processing every event
      #getting parameters from event
      _weight=event.args['weight']
      _demolished=event.args['demolished']
      _color=event.args['color']
      _model=event.args['model']
      _brand=event.args['brand']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      nonce =sokol.eth.getTransactionCount(localas.address)
      txDict["nonce"]=nonce
      tx = contr_s.functions.preTransfer(tx,_tokenId,_weight, _demolished, _color, _model, _brand, _reciever).buildTransaction(txDict)
      signed_tx = localas.signTransaction(tx)
      tx_hash = sokol.eth.sendRawTransaction(signed_tx.rawTransaction)#transact function to another bridge
      sokol.eth.waitForTransactionReceipt(tx_hash)
      print(tx_hash)
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
      _weight=event.args['weight']
      _demolished=event.args['demolished']
      _color=event.args['color']
      _model=event.args['model']
      _brand=event.args['brand']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      nonce = kovan.eth.getTransactionCount(localak.address)
      txDict["nonce"]=nonce
      tx = contr_k.functions.preTransfer(tx,_tokenId,_weight, _demolished, _color, _model, _brand, _reciever).buildTransaction(txDict)
      signed_tx = localak.signTransaction(tx)
      tx_hash = kovan.eth.sendRawTransaction(signed_tx.rawTransaction)#transact function to another bridge
      kovan.eth.waitForTransactionReceipt(tx_hash)
      print(tx_hash)
  s1=s2+1;#updating starting block for sokol

  time.sleep(10)#sleeping to do not make too many requests
