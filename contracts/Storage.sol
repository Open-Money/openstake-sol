// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

contract Storage {

    uint256 public _rewardsDistributed;
    mapping(address => uint256) public _rewardsClaimed;

    struct Stakes {
        uint256 entranceTimestamp_;
        uint256 entranceAmount_;
    }

    struct Withdrawals {
        uint256 entranceTimestamp_;
        uint256 entranceAmount_;
    }

    mapping(address => Stakes) public _stakes;
    mapping(address => Withdrawals) public _withdrawals;

    event StakeEntryAdded(address indexed user, uint256 amount, uint256 time);
    event StakeEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryAdded(address indexed, uint256 amount, uint256 time);

    modifier onlyStaker() {
        require(_stakes[msg.sender].entranceAmount_ != 0,"Storage: not a staker");
        _;
    }

    function _hasStake(address user) internal view returns(bool) {
        return _stakes[user].entranceAmount_ != 0 ? true : false;
    }

    function _hasWithdrawal(address user) internal view returns(bool) {
        return _withdrawals[user].entranceAmount_ != 0 ? true : false;
    }

    function _stakedAmount(address user) internal view returns(uint256) {
        return _stakes[user].entranceAmount_;
    }

    function _stakeTime(address user) internal view returns(uint256) {
        return _stakes[user].entranceTimestamp_;
    }

    function _withdrawalAmount(address user) internal view returns(uint256) {
        return _withdrawals[user].entranceAmount_;
    }

    function _withdrawalTime(address user) internal view returns(uint256) {
        return _withdrawals[user].entranceTimestamp_;
    }

    function _deleteStakeEntry(address user) internal {
        emit StakeEntryRemoved(user,_stakes[user].entranceAmount_,block.timestamp);
        delete _stakes[user];
    }

    function _addStakeEntry(address user, uint256 amount) internal {
        _stakes[user].entranceAmount_ = amount;
        _stakes[user].entranceTimestamp_ = block.timestamp;
        emit StakeEntryAdded(user, amount, block.timestamp);
    }

    function _deleteWithdrawalEntry(address user) internal {
        emit WithdrawalEntryRemoved(user,_withdrawals[user].entranceAmount_,block.timestamp);
        delete _withdrawals[user];
    }

    function _addWithdrawalEntry(address user, uint256 amount) internal {
        _withdrawals[user].entranceAmount_ = amount;
        _withdrawals[user].entranceTimestamp_ = block.timestamp;
        emit WithdrawalEntryAdded(user,amount,block.timestamp);
    }

    function _addRewardsDistributed(address user, uint256 amount) internal {
        _rewardsDistributed += amount;
        _rewardsClaimed[user] += amount;
    }
}