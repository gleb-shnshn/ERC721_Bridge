pragma solidity ^0.4.24;
contract ERC721{
    function onERC721Received(address _operator, address _from, bytes32 _tokenId, bytes data) external returns(bytes4);
}
contract SmartPhone {

    struct Phone {
        uint weight;//weight of the phone
        bool demolished;//is the phone demolished
        string color;//color of the phone
        address owner;//owner of the phone
        bytes32 tokenId;//unique id of the phone
    }
    
    address dev;//address of person who deployed contract, he has the permission of registering vendors
    
    mapping(address=>bool) isVendor;
    
    Phone[] phones;//array of phones
    
    function SmartPhone() public{//constructor of the contract
        isVendor[msg.sender]=true;//giving permission of creating phones for person who deployed contract
        dev=msg.sender;//initializing dev
    }
    
    mapping(bytes32=>uint) getPhone;//get index of the phone in array of phones by id
    
    function registerVendor(address _vendor) public{//registering a new vendor
        require(dev==msg.sender);//if sender is dev
        isVendor[_vendor]=true;//giving permisson of creating phones for a new vendor
    }
    
    function isContract(address addr) returns (bool) {//checking if addr is a contract
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function onERC721Received(address _operator, address _from, bytes32 _tokenId, bytes data) external returns(bytes4){
       return( bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    function safeTransferFrom(address _from, address _to, bytes32 _tokenId) public payable{//transfering the phone to the new owner if the phone is existing
        require(_from==msg.sender);//if sender is an owner of address _from
        require(_from==phones[getPhone[_tokenId]].owner);//if sender is an owner of the phone 
        require(_tokenId==phones[getPhone[_tokenId]].tokenId);//if token exists
        require(phones[getPhone[_tokenId]].demolished==false);//if phone is not demolished
        phones[getPhone[_tokenId]].owner=_to;//changing owner
        if (isContract(_to)){
            ERC721 erc721 = ERC721(_to);
            require(erc721.onERC721Received(_from,_from, _tokenId, "")==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
    }
    
    function createPhone(uint _weight, string _color) public{
        require(isVendor[msg.sender]);//if sender is a vendor
        bytes32 _tokenId = keccak256(_color,_weight, phones.length);//generating unique id via keccak256
        phones.push(Phone(_weight,false,_color,msg.sender,_tokenId));//adding new phone in array
        getPhone[_tokenId]=phones.length-2;
    }
    
    function demolish(bytes32 _tokenId) public{//demolishing the phone if the phone is existing
        require(msg.sender==phones[getPhone[_tokenId]].owner);//if sender is an owner of the phone 
        require(phones[getPhone[_tokenId]].demolished==false);//if phone is not demolished
        phones[getPhone[_tokenId]].demolished=true;
    }
}
