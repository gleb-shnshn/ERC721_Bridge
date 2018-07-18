from web3 import Web3, HTTPProvider

pk=""

addrk=""
addrs=""

abik=open("abik.txt").read()
abis=open("abis.txt").read()

kovan=Web3(HTTPProvider("https://kovan.infura.io/"))
sokol=Web3(HTTPProvider("https://sokol.poa.network/"))

localak=kovan.eth.account.privateKeyToAccount(pk)
localas=sokol.eth.account.privateKeyToAccount(pk)

contr_k=kovan.eth.contract(address=Web3.toChecksumAddress(addrk), abi=abik)
contr_s=sokol.eth.contract(address=Web3.toChecksumAddress(addrs), abi=abis)

txDict={"from":localak.address, 'gas': 4000000}

k1=0
k2=0

s1=0
s2=0

while (k2==0):
  k2=kovan.eth.getBlock("latest")["number"]
  filter_k={"fromBlock":k1,"toBlock":k2,"address":addrk}
  logs_k=kovan.eth.getLogs(filter_k)
  for log in logs_k:
    tx=log["transactionHash"]
    rec=kovan.eth.getTransactionReceipt(tx)
    events=contr_k.events.CametoBridge().processReceipt(rec)
    for event in events:
      _data=event.args['data']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      sokol_c.functions.preTransfer(tx,_tokenId,_data,_reciever).transact(txDict)
      "psevdokod of resending"
  k1=k2+1;
  print(k2)

  s2=sokol.eth.getBlock("latest")["number"]
  filter_s={"fromBlock":s1,"toBlock":s2,"address":addrs}
  logs_s=sokol.eth.getLogs(filter_s)
  for log in logs_s:
    tx=log["transactionHash"]
    rec=sokol.eth.getTransactionReceipt(tx)
    events=contr_s.events.CametoBridge().processReceipt(rec)
    for event in events:
      _data=event.args['data']
      _tokenId=event.args['tokenId']
      _reciever=event.args['reciever']
      kovan_c.functions.preTransfer(tx,_tokenId,_data,_reciever).transact(txDict)
      "psevdokod of resending"
  s1=s2+1;
  print(s2)
