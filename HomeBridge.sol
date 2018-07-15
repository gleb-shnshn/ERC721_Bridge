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
    
    HomePhone homePhone;
    
    event TransferCompleted(uint256);
    
    constructor(address _homePhoneContract) public{
        homePhone=HomePhone(_homePhoneContract);
    }
    
    function transferApproved(uint256 _tokenId, bytes[] _data){
        homePhone.recoveryToken(_tokenId,_data);
        emit TransferCompleted(_tokenId);
    }
}
