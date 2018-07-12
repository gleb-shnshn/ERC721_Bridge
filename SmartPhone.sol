pragma solidity ^0.4.24;

contract SmartPhone {

    struct Phone {
        uint weight;
        bool demolished;
        string color;
        address owner;
        bytes32 id;
    }
    
    address dev;
    
    mapping(address=>bool) isVendor;
    
    Phone[] phones;
    
    function SmartPhone() public{
        isVendor[msg.sender]=true;
        dev=msg.sender;
    }
    
    modifier valid(bytes32 _id){
        require(msg.sender==phones[getPhone[_id]].owner);
        require(phones[getPhone[_id]].demolished==false);
        _;
    }
    
    mapping(bytes32=>uint) getPhone;
    
    function registerVendor(address _vendor) public{
        require(dev==msg.sender);
        isVendor[_vendor]=true;
    }
    
    function transfer(address _to, bytes32 _id) public valid(_id){
        phones[getPhone[_id]].owner=_to;
    }
    
    function createPhone(uint _weight, string _color) public{
        require(isVendor[msg.sender]);
        phones.push(Phone(_weight,false,_color,msg.sender,keccak256(_color,_weight, phones.length)));
    }
    
    function demolish(bytes32 _id) public valid(_id){
        phones[getPhone[_id]].demolished=true;
    }
}
