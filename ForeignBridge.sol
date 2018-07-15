pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract ForeignPhone{
    function recoveryToken(uint256 _tokenId, bytes[] _data) public;
    function getSerializedData(uint256 _tokenId) public view returns(bytes[]);
    function deleteToken(uint256 _tokenId) public;
}
contract ForeignBridge{
    
    event CametoBridge(address reciever, uint256 tokenId, bytes[] data);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4){
        foreignPhone.deleteToken(_tokenId);
         emit CametoBridge(_from, _tokenId, foreignPhone.getSerializedData(_tokenId));
         return(bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    ForeignPhone foreignPhone;
    
    event TransferCompleted(uint256);
    
    constructor(address _foreignPhoneContract) public{
        foreignPhone=ForeignPhone(_foreignPhoneContract);
    }
    
    function transferApproved(uint256 _tokenId, bytes[] _data) public{
        foreignPhone.recoveryToken(_tokenId,_data);
        emit TransferCompleted(_tokenId);
    }
}
