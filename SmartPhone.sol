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
    
    mapping(address=>bool) isVendor;//true if address is a vendor
    
    mapping(address=>uint256) getBalance;//return count of tokens for the address
    
    mapping(address=>string) getName;//return the name of a vendor
    
    Phone[] phones;//array of phones
    
    function tokenByIndex(uint256 _index) external view returns (uint256){//return token id of phone with given index
        require(_index<phones.length);
        require(_index>=0);
        return phones[_index].tokenId;
    }
    
    function totalSupply() external view returns (uint256){//return count of all tokens
        return phones.length;
    }
    
    constructor() public{//constructor of the contract
        isVendor[msg.sender]=true;//giving permission of creating phones for person who deployed contract
        dev=msg.sender;//initializing dev
        getName[msg.sender]="Developer";
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
    
    function changeVendorName(string _newName) public{
        require(isVendor[msg.sender]==true);//if sender is a vemdor
        getName[msg.sender]=_newName;//rename the  vendor
    }
    
    function getColor(uint256 _tokenId) public view returns(string){//returning the color of the phone
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].color);
    }
    
     function getWeight(uint256 _tokenId) public view returns(uint){//returning the weight of the phone
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].weight);
    }
    
     function ownerOf(uint256 _tokenId) public view returns(address){//returning the owner of the token by id
        require(phones[_tokenId-1].tokenId!=0);
        return(phones[_tokenId-1].owner);
    }
    
    function balanceOf(address _owner) public view returns(uint256){//returning the count of tokens on address
        return(getBalance[_owner]);
    }
    
    function getFullInfo(uint256 _tokenId) public view returns(string){//returning the full info about the phone
        Phone memory _phone= phones[_tokenId-1];
        return string(abi.encodePacked(_phone.brand, " ", _phone.model));
    }

    event sent();
    event newToken(uint256);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external pure returns(bytes4){
         return( bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable{//transfering the phone to the new owner if the phone is existing
        require(_from==msg.sender);//if sender is an owner of address _from
        require(_from==phones[_tokenId-1].owner);//if sender is the owner of the phone
        require(phones[_tokenId-1].demolished==false);//if phone is not demolished
        phones[_tokenId-1].owner=_to;//changing owner
        getBalance[_from]--;//changing the balance of the sender
        getBalance[_to]++;//changing the balance of the getter
        if (isContract(_to)){//if getter is a contract
            ERC721 erc721 = ERC721(_to);
            require(erc721.onERC721Received(_from,_from, _tokenId, "")==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
        emit sent();//emit event of successful sending money
    }
    
    function createPhone(string _model, uint _weight, string _color) public{//creating a new phone
        require(isVendor[msg.sender]);//if sender is a vendor
        uint256 _tokenId = phones.length+1;//a token id is a index in array
        phones.push(Phone(_weight,false,_color,msg.sender,_tokenId,_model,getName[msg.sender]));//adding new phone in array'
        getBalance[msg.sender]++;//changing the balance of the vendor
    }
    
    function demolish(uint256 _tokenId) public{//demolishing the phone if the phone is existing
        require(msg.sender==phones[_tokenId-1].owner);//if sender is an owner of the phone 
        require(phones[_tokenId-1].demolished==false);//if phone is not demolished
        phones[_tokenId-1].demolished=true;
    }
}
