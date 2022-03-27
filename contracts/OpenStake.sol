// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "./Calculations.sol";
import "./Constants.sol";


contract OpenStake is Calculations {

    bool private _isEmergency = false;

    event Stake(address indexed user, uint256 amount, uint256 time);
    event Unstake(address indexed user, uint256 amount, uint256 time);
    event UnstakeWithPenalty(address indexed user, uint256 amount, uint256 time);
    event Withdraw(address indexed user, uint256 amount, uint256 time);
    event Compound(address indexed user, uint256 amount, uint256 time);
    event EmergencySet(address indexed owner, uint256 time);
    event EmergencyUnstake(address indexed user, uint256 amount, uint256 time);
    event EmergencyWithdrawal(address indexed user, uint256 amount, uint256 time);

    constructor() {
        //Placeholder, will be updated
        adjustMinRewardDuration(10);
        //Placeholder, will be updated to value in ether
        adjustMinStakingAmount(100);
        //0.27 in decimal for %27 APY is 270000000000000000
        //270000000000000000 / 31536000 is the number below 
        //for rewards in second in decimal
        adjustRewardMultiplier(8561643835);
        //Placeholder, will be updated
        adjustValorDuration(10);
        //0.9 in decimal for 10% penalty
        adjustPenaltyConstant(900000000000000000);
    }

    function depositToTreasuy() public payable onlyOwner {}

    function withdrawFromTreasury(uint256 amount) public onlyOwner {
        address payable receiver = payable(msg.sender);
        receiver.transfer(amount);
    }

    function stake() public payable {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(!_hasStake(msg.sender),"OpenStake: Already have stake");
        require(msg.value >= _minStakingAmount,"OpenStake: stake amount too low");
        _addStakeEntry(msg.sender, msg.value);
        emit Stake(msg.sender, msg.value, block.timestamp);
    }

    function unstake() public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasStake(msg.sender),"OpenStake: You dont have a stake");
        require(_canRemoveStake(msg.sender),"OpenStake: You cant remove stake now");
        _addWithdrawalEntry(msg.sender, calculateReward(msg.sender));
        emit Unstake(msg.sender,calculateReward(msg.sender),block.timestamp);
        _deleteStakeEntry(msg.sender);
    }

    function unstakeWithPenalty() public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasStake(msg.sender),"OpenStake: You dont have a stake");
        require(!_canRemoveStake(msg.sender),"OpenStake: You can remove stake normally");
        _addWithdrawalEntry(msg.sender, _calculatePenalty(_stakedAmount(msg.sender)));
        emit UnstakeWithPenalty(msg.sender, _calculatePenalty(_stakedAmount(msg.sender)), block.timestamp);
        _deleteStakeEntry(msg.sender);
    }

    function withdraw() public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasWithdrawal(msg.sender),"OpenStake: You dont have a withdrawal");
        require(_canWithdraw(msg.sender),"OpenStake: You cant withdraw now");
        address payable receiver = payable(msg.sender);
        receiver.transfer(_withdrawalAmount(msg.sender));
        emit Withdraw(msg.sender, _withdrawalAmount(msg.sender), block.timestamp);
        _deleteWithdrawalEntry(msg.sender);
    }

    function compound() public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasStake(msg.sender),"OpenStake: You dont have a stake");
        require(_canRemoveStake(msg.sender),"OpenStake: You cant compound stake now");
        emit Compound(msg.sender, calculateReward(msg.sender), block.timestamp);
        _addStakeEntry(msg.sender,calculateReward(msg.sender));
    }

    function setEmergency(bool status) public onlyOwner {
        _isEmergency = status;
        emit EmergencySet(msg.sender, block.timestamp);
    }

    function emergencyUnstake() public {
        require(_isEmergency,"OpenStake: there is no emergency");
        require(_hasStake(msg.sender),"OpenStake: You dont have a stake");
        address payable receiver = payable(msg.sender);
        receiver.transfer(_stakedAmount(msg.sender));
        emit EmergencyUnstake(msg.sender, _stakedAmount(msg.sender), block.timestamp);
        _deleteStakeEntry(msg.sender);
    }

    function emergencyWithdrawal() public {
        require(_isEmergency,"OpenStake: there is no emergency");
        require(_hasWithdrawal(msg.sender),"OpenStake: You dont have a stake");
        address payable receiver = payable(msg.sender);
        receiver.transfer(_withdrawalAmount(msg.sender));
        emit EmergencyWithdrawal(msg.sender, _withdrawalAmount(msg.sender), block.timestamp);
        _deleteWithdrawalEntry(msg.sender);
    }
}