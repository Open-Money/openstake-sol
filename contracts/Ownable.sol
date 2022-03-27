// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner,"Ownable: you are not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
        emit OwnershipTransferred(_owner);
    }
}