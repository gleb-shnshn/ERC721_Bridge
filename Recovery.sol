pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract Recovery{
    
     struct Phone {
        uint weight;//weight of the phone
        bool demolished;//is the phone demolished
        string color;//color of the phone
        address owner;//owner of the phone
        uint256 tokenId;//unique id of the phone
        string model;//model of the phone
        string brand;//brand of vendor who created this phone
    }
    
    Phone[] phones;
    
    function recovery(uint256 _tokenId, bytes[] _data) public{
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
        phones.push(_phone);
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
}
