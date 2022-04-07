// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "./Calculations.sol";

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
        require(msg.value >= _minStakingAmount,"OpenStake: stake amount too low");
        _addStakeEntry(msg.sender, msg.value);
        emit Stake(msg.sender, msg.value, block.timestamp);
    }

    function unstake(uint index) public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasIndexedStake(msg.sender, index),"OpenStake: You dont have a stake");
        require(_canRemoveStake(msg.sender, index),"OpenStake: You cant remove this stake now");
        uint calculatedReward = calculateReward(msg.sender, index);
        _addRewardsDistributed(msg.sender, calculatedReward - _stakedAmount(msg.sender, index));
        _addWithdrawalEntry(msg.sender, calculatedReward);
        emit Unstake(msg.sender,calculatedReward,block.timestamp);
        _deleteStakeEntry(msg.sender, index);
    }

    function unstakeWithPenalty(uint index) public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasIndexedStake(msg.sender, index),"OpenStake: You dont have a stake");
        require(!_canRemoveStake(msg.sender, index),"OpenStake: You can remove stake normally");
        uint penalty = _calculatePenalty(_stakedAmount(msg.sender, index));
        _addWithdrawalEntry(msg.sender, penalty);
        emit UnstakeWithPenalty(msg.sender, penalty, block.timestamp);
        _deleteStakeEntry(msg.sender, index);
    }

    function withdraw(uint index) public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasIndexedWithdrawal(msg.sender, index),"OpenStake: You dont have a withdrawal");
        require(_canWithdraw(msg.sender, index),"OpenStake: You cant withdraw now");
        address payable receiver = payable(msg.sender);
        receiver.transfer(_withdrawalAmount(msg.sender, index));
        emit Withdraw(msg.sender, _withdrawalAmount(msg.sender, index), block.timestamp);
        _deleteWithdrawalEntry(msg.sender, index);
    }

    function compound(uint index) public {
        require(!_isEmergency,"OpenStake: There is an emergency");
        require(_hasIndexedStake(msg.sender, index),"OpenStake: You dont have a stake");
        require(_canRemoveStake(msg.sender, index),"OpenStake: You cant compound stake now");
        uint reward = calculateReward(msg.sender, index);
        emit Compound(msg.sender, reward, block.timestamp);
        _deleteStakeEntry(msg.sender, index);
        _addStakeEntry(msg.sender, reward);
    }

    function setEmergency(bool status) public onlyOwner {
        _isEmergency = status;
        emit EmergencySet(msg.sender, block.timestamp);
    }

    function emergencyUnstake(uint index) public {
        require(_isEmergency,"OpenStake: there is no emergency");
        require(_hasIndexedStake(msg.sender, index),"OpenStake: You dont have a stake");
        address payable receiver = payable(msg.sender);
        uint stakedAmount = _stakedAmount(msg.sender, index);
        receiver.transfer(stakedAmount);
        emit EmergencyUnstake(msg.sender, stakedAmount, block.timestamp);
        _deleteStakeEntry(msg.sender, index);
    }

    function emergencyWithdrawal(uint index) public {
        require(_isEmergency,"OpenStake: there is no emergency");
        require(_hasIndexedWithdrawal(msg.sender, index),"OpenStake: You dont have a stake");
        address payable receiver = payable(msg.sender);
        uint withdrawalAmount = _withdrawalAmount(msg.sender, index);
        receiver.transfer(withdrawalAmount);
        emit EmergencyWithdrawal(msg.sender, withdrawalAmount, block.timestamp);
        _deleteWithdrawalEntry(msg.sender, index);
    }
}