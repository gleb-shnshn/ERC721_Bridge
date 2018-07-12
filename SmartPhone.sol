pragma solidity ^0.4.24;

contract SmartPhone {

    struct Phone {
        uint weight;//weight of the phone
        bool demolished;//is the phone demolished
        string color;//color of the phone
        address owner;//owner of the phone
        bytes32 id;//unique id of the phone
    }
    
    address dev;//address of person who deployed contract, he has permission of registering vendors
    
    mapping(address=>bool) isVendor;
    
    Phone[] phones;//array of phones
    
    function SmartPhone() public{//constructor of the contract
        isVendor[msg.sender]=true;//giving permission to create phones for person who deployed contract
        dev=msg.sender;//initializing dev
    }
    
    modifier valid(bytes32 _id){//modifier of existing of the phone with gived id
        require(msg.sender==phones[getPhone[_id]].owner);//if sender is an owner of the phone 
        require(phones[getPhone[_id]].demolished==false);//if phone is not demolished
        _;
    }
    
    mapping(bytes32=>uint) getPhone;//get index of the phone in array of phones by id
    
    function registerVendor(address _vendor) public{//registering a new vendor
        require(dev==msg.sender);//if sender is dev
        isVendor[_vendor]=true;//giving permisson to create phones for a new vendor
    }
    
    function transfer(address _to, bytes32 _id) public valid(_id){//transfering the phone to the new owner if the phone is existing
        phones[getPhone[_id]].owner=_to;
    }
    
    function createPhone(uint _weight, string _color) public{
        require(isVendor[msg.sender]);//if sender is a vendor
        phones.push(Phone(_weight,false,_color,msg.sender,keccak256(_color,_weight, phones.length)));
        //generating unique id via keccak256
    }
    
    function demolish(bytes32 _id) public valid(_id){//demolishing the phone if the phone is existing
        phones[getPhone[_id]].demolished=true;
    }
}
