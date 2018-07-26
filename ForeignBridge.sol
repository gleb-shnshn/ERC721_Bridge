pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract ForeignPhone{
    function recoveryToken(uint256 _tokenId, uint256 _weight, bool _demolished, string _color, string _model, string _brand, address _reciever) public;
    function getData(uint256 _tokenId) public view returns(uint256, bool, string, string, string);
    function deleteToken(uint256 _tokenId) public;
}
contract ForeignBridge{
    
    event CametoBridge(address reciever, uint256 tokenId, uint256 weight, bool demolished, string color, string model, string brand);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4){
        var (_weight, _demolished, _color, _model, _brand)=foreignPhone.getData(_tokenId);
        foreignPhone.deleteToken(_tokenId);
        emit CametoBridge(_from, _tokenId, _weight, _demolished, _color, _model, _brand);
        return(bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    mapping(address => bool) isExtBridge;
    uint requiredSig;
    
    ForeignPhone foreignPhone;
    address dev;
    
    mapping(bytes32=>uint) signsOf;
    mapping(bytes32=>bool) tokenRecovered;
    mapping(bytes32=>bool) isVoted;
    
    event TransferCompleted(uint256);
    
    constructor(address _foreignPhoneContract, address[] _extBridges, uint _requiredSig) public{
        for(uint i=0; i<_extBridges.length; i++){
            isExtBridge[_extBridges[i]]=true;
        }
        requiredSig=_requiredSig;
        foreignPhone=ForeignPhone(_foreignPhoneContract);
        dev=msg.sender;
    }
    
     function preTransfer(bytes32 _txHash, uint256 _tokenId, uint256 _weight, bool _demolished, string _color, string _model, string _brand, address _reciever) public{
        require(isExtBridge[msg.sender]==true);
        bytes32 _hash=keccak256(_reciever, _tokenId, _weight, _demolished, _color, _model, _brand, _txHash);
        require(isVoted[keccak256(_hash,msg.sender)]==false);
        isVoted[keccak256(_hash,msg.sender)]=true;
        signsOf[_hash]++;
        if (signsOf[_hash]>=requiredSig && tokenRecovered[_hash]==false){
            foreignPhone.recoveryToken(_tokenId, _weight, _demolished, _color, _model, _brand,_reciever);
            emit TransferCompleted(_tokenId);
            tokenRecovered[_hash]=true;
        }
    }
    
    function addExtBridge(address _extBridge){
        require(msg.sender==dev);
        isExtBridge[_extBridge]=true;
    }
}