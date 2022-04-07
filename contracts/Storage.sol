// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

contract Storage {

    uint256 public _rewardsDistributed;
    mapping(address => uint256) public _rewardsClaimed;

    struct StakeWithdraw {
        uint256 entranceTimestamp_;
        uint256 entranceAmount_;
    }

    mapping(address => StakeWithdraw[]) public _stakes;
    mapping(address => StakeWithdraw[]) public _withdrawals;

    event StakeEntryAdded(address indexed user, uint256 amount, uint256 time);
    event StakeEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryAdded(address indexed, uint256 amount, uint256 time);

    modifier onlyStaker() {
        require(_stakes[msg.sender].length != 0,"Storage: not a staker");
        _;
    }

    function stakes(address user) public view returns (StakeWithdraw[] memory) {
        return _stakes[user];
    }

    function withdrawals(address user) public view returns (StakeWithdraw[] memory) {
        return _withdrawals[user];
    }

    function _hasStake(address user) internal view returns(bool) {
        return _stakes[user].length != 0 ? true : false;
    }

    function _hasIndexedStake(address user, uint index) internal view returns(bool) {
        return _stakes[user][index].entranceAmount_ != 0 ? true : false;
    }

    function _hasIndexedWithdrawal(address user, uint index) internal view returns(bool) {
        return _withdrawals[user][index].entranceAmount_ != 0 ? true : false;
    }

    function _hasWithdrawal(address user) internal view returns(bool) {
        return _withdrawals[user].length != 0 ? true : false;
    }

    function _stakedAmount(address user, uint index) internal view returns(uint256) {
        return _stakes[user][index].entranceAmount_;
    }

    function _stakeTime(address user, uint index) internal view returns(uint256) {
        return _stakes[user][index].entranceTimestamp_;
    }

    function _withdrawalAmount(address user, uint index) internal view returns(uint256) {
        return _withdrawals[user][index].entranceAmount_;
    }

    function _withdrawalTime(address user, uint index) internal view returns(uint256) {
        return _withdrawals[user][index].entranceTimestamp_;
    }

    function _deleteStakeEntry(address user, uint index) internal {
        emit StakeEntryRemoved(user,_stakes[user][index].entranceAmount_,block.timestamp);
        for (uint i = index; i < _stakes[user].length - 1; i++) {
            _stakes[user][i] = _stakes[user][i+1];
        }  
        delete _stakes[user][_stakes[user].length];
    }

    function _addStakeEntry(address user, uint256 amount) internal {
        _stakes[user][_stakes[user].length].entranceAmount_ = amount;
        _stakes[user][_stakes[user].length].entranceTimestamp_ = block.timestamp;
        emit StakeEntryAdded(user, amount, block.timestamp);
    }

    function _deleteWithdrawalEntry(address user, uint index) internal {
        emit WithdrawalEntryRemoved(user,_withdrawals[user][index].entranceAmount_,block.timestamp);
        for (uint i = index; i < _stakes[user].length - 1; i++) {
            _withdrawals[user][i] = _withdrawals[user][i+1];
        }
        delete _withdrawals[user][_withdrawals[user].length];
    }

    function _addWithdrawalEntry(address user, uint256 amount) internal {
        _withdrawals[user][_withdrawals[user].length].entranceAmount_ = amount;
        _withdrawals[user][_withdrawals[user].length].entranceTimestamp_ = block.timestamp;
        emit WithdrawalEntryAdded(user,amount,block.timestamp);
    }

    function _addRewardsDistributed(address user, uint256 amount) internal {
        _rewardsDistributed += amount;
        _rewardsClaimed[user] += amount;
    }
}