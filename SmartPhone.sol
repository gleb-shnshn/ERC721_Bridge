pragma solidity ^0.4.24;
contract ERC721{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}
contract SmartPhone {

    struct Phone {
        uint weight;//weight of the phone
        bool demolished;//is the phone demolished
        string color;//color of the phone
        address owner;//owner of the phone
        uint256 tokenId;//unique id of the phone
        string model;//model of the phone
        string brand;//brand of vendor who creates this phone
    }
    
    address dev;//address of person who deployed contract, he has the permission of registering vendors
    
    mapping(address=>bool) isVendor;
    
    mapping(address=>uint256) getBalance;
    
    mapping(address=>string) getName;
    
    Phone[] phones;//array of phones
    
    function SmartPhone() public{//constructor of the contract
        isVendor[msg.sender]=true;//giving permission of creating phones for person who deployed contract
        dev=msg.sender;//initializing dev
    }
    
    function registerVendor(address _vendor, string _name) public{//registering a new vendor
        require(dev==msg.sender);//if sender is dev
        getName[_vendor]=_name;//giving the name for the vendor
        isVendor[_vendor]=true;//giving permisson of creating phones for a new vendor
    }
    
    function isContract(address addr) public view returns (bool) {//checking if addr is a contract
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function getColor(uint256 _tokenId) public view returns(string){
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].color);
    }
    
     function getWeight(uint256 _tokenId) public view returns(uint){
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].weight);
    }
    
     function ownerOf(uint256 _tokenId) public view returns(address){
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].owner);
    }
    
    function balanceOf(address _owner) public view returns(uint256){
        return(getBalance[_owner]);
    }
    
    function getFullInfo(uint256 _tokenId) public view returns(string){
        Phone _phone= phones[_tokenId-1];
        return string(abi.encodePacked(_phone.brand, " ", _phone.model));
    }

    event sent();
    event newToken(uint256);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4){
         return( bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable{//transfering the phone to the new owner if the phone is existing
        require(_from==msg.sender);//if sender is an owner of address _from
        require(_from==phones[_tokenId-1].owner);//if sender is an owner of the phone
        require(phones[_tokenId-1].demolished==false);//if phone is not demolished
        phones[_tokenId-1].owner=_to;//changing owner
        getBalance[_from]--;
        getBalance[_to]++;
        if (isContract(_to)){
            ERC721 erc721 = ERC721(_to);
            require(erc721.onERC721Received(_from,_from, _tokenId, "")==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
        emit sent();//emit event of successful sending money
    }
    
    function createPhone(string _model, uint _weight, string _color) public{
        require(isVendor[msg.sender]);//if sender is a vendor
        uint256 _tokenId = phones.length+1;//a token id is a index in array
        phones.push(Phone(_weight,false,_color,msg.sender,_tokenId,_model,getName[msg.sender]));//adding new phone in array'
        getBalance[msg.sender]++;
    }
    
    function demolish(uint256 _tokenId) public{//demolishing the phone if the phone is existing
        require(msg.sender==phones[_tokenId-1].owner);//if sender is an owner of the phone 
        require(phones[_tokenId-1].demolished==false);//if phone is not demolished
        phones[_tokenId-1].demolished=true;
    }
}
