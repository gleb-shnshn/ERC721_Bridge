pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract ERC721{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}

contract ForeignPhone {

    struct Phone {
        uint weight;//weight of the phone
        bool demolished;//is the phone demolished
        string color;//color of the phone
        address owner;//owner of the phone
        uint256 tokenId;//unique id of the phone
        string model;//model of the phone
        string brand;//brand of vendor who created this phone
    }
    
    function getSerializedData(uint256 _tokenId) public view returns(bytes[]){
        Phone storage _phone = phones[_tokenId-1];
        bytes[] memory data = new bytes[](6);
        data[0]=abi.encodePacked(_phone.weight);
        if (_phone.demolished==true)
            data[1]=abi.encodePacked(1);
        else
            data[1]=abi.encodePacked(0);
        data[2]=abi.encodePacked(_phone.color);
        data[3]=abi.encodePacked(_phone.owner);
        data[4]=abi.encodePacked(_phone.model);
        data[5]=abi.encodePacked(_phone.brand);
        return (data);
    }

    mapping(address=>uint256) getBalance;//return count of tokens for the address
    
    event phoneRecovered(uint, bool, string, address, uint256, string, string);

    mapping(uint=>Phone) phones;//array of phones
    
    address foreignBridge;
    
    function setForeignBridge(address _foreignBridgeContract) public{
        require(msg.sender==dev);
        foreignBridge=_foreignBridgeContract;
    }
    
    address dev;
    
    constructor(){
        dev=msg.sender;
    }
    
    function recoveryToken(uint256 _tokenId, bytes[] _data) public{
        require(msg.sender==foreignBridge);
        Phone storage _phone;
        _phone.weight=(bytesToUint(_data[0]));
        if (bytesToUint(_data[1])==1)
            _phone.demolished=true;
        else
            _phone.demolished=false;
        _phone.color=string(_data[2]);
        _phone.owner=bytesToAddr(_data[3]);
        _phone.tokenId=_tokenId;
        _phone.model=string(_data[4]);
        _phone.brand=string(_data[5]);
        emit phoneRecovered(_phone.weight, _phone.demolished, _phone.color,_phone.owner, _phone.tokenId, _phone.model, _phone.brand);
        phones[_tokenId-1]=_phone;
    }
    
    function bytesToUint(bytes b) public returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(b[i])*(2**(8*(b.length-(i+1))));
        }
        return number;
    } 
    
    function bytesToAddr (bytes b) constant returns (address) {
        uint result = 0;
        for (uint i = b.length-1; i+1 > 0; i--) {
            uint c = uint(b[i]);
            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
            result += to_inc;
        }
        return address(result); 
    }
    
    function isContract(address addr) public view returns (bool) {//checking if addr is a contract
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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
    
    function deleteToken(uint256 _tokenId){
        require(dev==foreignBridge);
        delete phones[_tokenId-1];
    }
}
