// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// ObjectDataStore uses a mirror pattern
// due to limitations in solidity, we will mirror data in multiple data structures
// to get the benefits of each one
// solidity's mapping provides fast lookup by our own arbitrary object key
// solidity's array allow for easy access to a collection of objects
contract ObjectDataStore 
{
    // structure of data store
    struct Obj 
    {
        string id;         
        string objType;   
        string name;
        string ipfsHash;
        string parent;
        string children;
        bool isSet;
    }
 
    // for fast lookup by object id
    mapping(string => Obj) public objects;

    // array of objects for collecting all/subset of objects
    Obj[] public objectsArray;

    // contract deployer
    address owner;

    // access control list
    mapping(address => bool) acl;

    // initialize smart contract
    constructor()
    {
        // setting the owner as the contract deployer
        owner = msg.sender;

        // adding contract deployer to ACL
        acl[owner] = true;
    }

    // used to restrict functions to only contract deployer
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Access Restricted");
        _;
    }

    // used to restrict functions to only a dynamic access control list
    modifier isAccesslisted(address _address)
    {
        require(acl[_address], "Access Restricted");
        _;
    }

    // how contract deployer can add other members to the ACL
    function addUser(address _addressToAccesslist) 
                    public 
                    onlyOwner
    {
        acl[_addressToAccesslist] = true;
    }

    // validates if a specific address is on the ACL
    function verifyUser(address _accesslistedAddress) 
                        public 
                        view 
                        returns(bool)
    {
        bool userIsAccesslisted = acl[_accesslistedAddress];
        return userIsAccesslisted;
    }

    function exampleFunction() public view isAccesslisted(msg.sender) returns(bool){
    return (true);
    }

    // create a new object
    function objectSet(string memory _id, 
                        string memory _objType, 
                        string memory _name, 
                        string memory _ipfsHash,
                        string memory _parent, 
                        string memory _children) 
                        public 
                        isAccesslisted(msg.sender) 
                        returns(bool)
    {
        
        // add objects to mapping stored on chain
        objects[_id].id = _id;
        objects[_id].objType = _objType;
        objects[_id].name = _name;
        objects[_id].ipfsHash = _ipfsHash;
        objects[_id].parent = _parent;
        objects[_id].children = _children;
        objects[_id].isSet = true;

        // add objects to array stored on chain
        objectsArray.push
        (
            Obj(_id, _objType, _name, _ipfsHash, _parent, _children, true)
        );

        // emit event to blockchain
        emit objectCreationEvent
        (
            msg.sender, _id, _objType, _name, _ipfsHash, _parent, _children
        );

        return true;
    }

    // structure of event that will be emitted
    event objectCreationEvent
    (
        address indexed createdBy,
        string id,
        string objType,
        string name,
        string ipfsHash,
        string parent,
        string children
    );

    // gets an individual object from mapping
    function objectGet(string memory _id) 
                        external 
                        view 
                        returns(Obj memory)
    {
        return objects[_id];
    }

    // returns entire data set from array
    function objectGetArray() 
                            public 
                            view 
                            returns(Obj[] memory) 
    {
        return objectsArray;
    }

    // returns count of all objects
    function objectGetCount() 
                            public 
                            view 
                            returns(uint) 
    {
        return objectsArray.length;
    }
}
