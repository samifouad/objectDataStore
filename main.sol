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
    // structure of data store mapping
    struct Obj
    {
        string id;
        string objType;
        string name;
        string ipfsHash;
        string parent;
        string children;
        bool isSet;
        uint256 index;
    }

    // structure of data store array
    struct ObjArray
    {
        string id;
        string objType;
        string name;
        string ipfsHash;
        string parent;
        string children;
    }  
 
    // for fast lookup by object id
    mapping(string => Obj) private objects;

    // array of objects for collecting all/subset of objects
    ObjArray[] private objectsArray;

    // contract deployer
    address owner;

    // access control list
    mapping(address => bool) private acl;

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

    // how contract deployer can add members to the ACL
    function addUser(address _addressToAccesslist) 
                    public 
                    onlyOwner
    {
        acl[_addressToAccesslist] = true;
    }

    // how contract deployer can remove members from the ACL
    function removeUser(address _addressToAccesslist) 
                    public 
                    onlyOwner
    {
        acl[_addressToAccesslist] = false;
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
        require (objects[_id].isSet == false, "Object ID already exists.");
        
        // add objects to mapping stored on chain
        objects[_id].id = _id;
        objects[_id].objType = _objType;
        objects[_id].name = _name;
        objects[_id].ipfsHash = _ipfsHash;
        objects[_id].parent = _parent;
        objects[_id].children = _children;
        objects[_id].isSet = true;

        // add objects to array stored on chain
        objectsArray.push( ObjArray( _id,
                                        _objType,
                                        _name,
                                        _ipfsHash,
                                        _parent,
                                        _children
                                    ));

        // get objectsArray length, subtract 1, that's the new id
        objects[_id].index = objectsArray.length-1;

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

    // structure of event that will be emitted
    event objectDeleteEvent
    (
        address indexed deletedBy,
        string id,
        string objType,
        string ipfsHash
    );

    // gets an individual object from mapping
    function objectGet(string memory _id) 
                        external 
                        view 
                        returns(Obj memory)
    {
        return objects[_id];
    }

    // gets an individual object from mapping
    function objectExists(string memory _id) 
                        external 
                        view 
                        returns(bool)
    {
        return objects[_id].isSet;
    }

    // returns entire data set from array
    function objectGetArray() 
                            public 
                            view 
                            returns(ObjArray[] memory) 
    {
        return objectsArray;
    }

    // returns data set from array for specific key
    function objectGetArrayItem(uint256 _key) 
                            public 
                            view
                            returns
                            (
                                string memory,
                                string memory,
                                string memory,
                                string memory,
                                string memory,
                                string memory
                            ) 
    {
        return (objectsArray[_key].id,
                objectsArray[_key].objType,
                objectsArray[_key].name,
                objectsArray[_key].ipfsHash,
                objectsArray[_key].parent,
                objectsArray[_key].children);
    }

    // returns count of all objects
    function objectGetCount() 
                            public 
                            view 
                            returns(uint256) 
    {
        return objectsArray.length;
    }

    // returns count of array minus 1
    function objectLastkey() 
                            public 
                            view 
                            returns(uint256) 
    {
        return objectsArray.length-1;
    }

    // delete object
    // p.s. this pattern is so stupid, but necessary for solidity
    function removeObject(string memory _obj) 
                    public
                    returns (bool)
    {
        // find array key of object 
        uint256 rowToDelete = objects[_obj].index;

        // find key of last item in array
        uint arrayLastKey = objectLastkey();

        // get values of last key in array
        ObjArray memory keyToMove = objectsArray[arrayLastKey];

        //move data from last to delete slot
        objectsArray[rowToDelete] = keyToMove;

        // get id of transplanted object
        string memory transplant = keyToMove.id;

        // update object with new array location
        objects[transplant].index = rowToDelete; 

        // delete last item of array
        objectsArray.pop();

        // reset mapping struct to default values
        delete objects[_obj];

        // fin
        return true;
    }
}
