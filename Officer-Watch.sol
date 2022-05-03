// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OfficerWatch {

    address owner; // contract deployer
    mapping(address => bool) accesslistedAddresses; // access control list

    constructor() {
        owner = msg.sender; // setting the owner the contract deployer
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier isAccesslisted(address _address) {
        require(accesslistedAddresses[_address], "You need to be accesslisted");
        _;
    }

    function addUser(address _addressToAccesslist) public onlyOwner {
        accesslistedAddresses[_addressToAccesslist] = true;
    }

    function verifyUser(address _accesslistedAddress) public view returns(bool) {
        bool userIsAccesslisted = accesslistedAddresses[_accesslistedAddress];
        return userIsAccesslisted;
    }

    function exampleFunction() public view isAccesslisted(msg.sender) returns(bool){
    return (true);
    }
}
