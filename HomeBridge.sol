pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract HomePhone{
    function recoveryToken(uint256 _tokenId, bytes[] _data) public;
    function getSerializedData(uint256 _tokenId) public view returns(bytes[]);
}
contract HomeBridge{
    
    event CametoBridge(address reciever, uint256 tokenId, bytes[] data);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4){
         emit CametoBridge(_from, _tokenId, homePhone.getSerializedData(_tokenId));
         return( bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    mapping(address => bool) isExtBridge;
    uint requiredSig;
    
    HomePhone homePhone;
    address dev;
    
    mapping(bytes32=>uint) signsOf;
    mapping(bytes32=>bool) tokenRecovered;
    mapping(bytes32=>bool) isVoted;
    
    event TransferCompleted(uint256);
    
    constructor(address _homePhoneContract, address[] _extBridges, uint _requiredSig) public{
        for(uint i=0; i<_extBridges.length; i++){
            isExtBridge[_extBridges[i]]=true;
        }
        requiredSig=_requiredSig;
        homePhone=HomePhone(_homePhoneContract);
        dev=msg.sender;
    }
    
    function preTrasfer(bytes32 _txHash, uint256 _tokenId, bytes[] _data, address _reciever) public{
        require(isExtBridge[msg.sender]==true);
        bytes memory __data;
        for (uint i=0; i<_data.length;i++){
            __data=abi.encodePacked(__data,_data[i]);
        }
        bytes32 _hash=keccak256(_reciever, _tokenId, __data, _txHash);
        require(isVoted[keccak256(_hash,msg.sender)]==false);
        isVoted[keccak256(_hash,msg.sender)]=true;
        signsOf[_hash]++;
        if (signsOf[_hash]>=requiredSig && tokenRecovered[_hash]==false){
            transferApproved(_tokenId, _data);
            tokenRecovered[_hash]=true;
        }
        
    }
    
    function addExtBridge(address _extBridge){
        require(msg.sender==dev);
        isExtBridge[_extBridge]=true;
    }
    
    function transferApproved(uint256 _tokenId, bytes[] _data){
        homePhone.recoveryToken(_tokenId,_data);
        emit TransferCompleted(_tokenId);
    }
}
