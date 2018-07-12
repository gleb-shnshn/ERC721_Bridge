pragma solidity ^0.4.24;
contract SmartPhone {

    struct Phone {
        uint weight;
        bool demolished;
        string color;
        address owner;
        bytes32 id;
    }
    
    address vendor;
    
    Phone[] phones;
    
    function SmartPhone() public{
        vendor=msg.sender;
    }
    
    modifier valid(bytes32 _id){
        require(msg.sender==phones[getPhone[_id]].owner);
        require(phones[getPhone[_id]].demolished==false);
        _;
    }
    
    mapping(bytes32=>uint) getPhone;
    
    function transfer(address _to, bytes32 _id) public valid(_id){
        phones[getPhone[_id]].owner=_to;
    }
    
    function createPhone(uint _weight, string _color) public{
        require(msg.sender==vendor);
        phones.push(Phone(_weight,false,_color,vendor,keccak256(_color,_weight, phones.length)));
    }
    
    function demolish(bytes32 _id) public valid(_id){
        phones[getPhone[_id]].demolished=true;
    }
}
