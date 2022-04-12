// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

contract Storage {

    uint256 public _rewardsDistributed;
    mapping(address => uint256) public _rewardsClaimed;

    mapping(address => uint[]) public _stakes;
    mapping(address => uint[]) public _stakeTimes;

    mapping(address => uint[]) public _withdrawals;
    mapping(address => uint[]) public _withdrawalTimes;

    event StakeEntryAdded(address indexed user, uint256 amount, uint256 time);
    event StakeEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryRemoved(address indexed user, uint256 amount, uint256 time);
    event WithdrawalEntryAdded(address indexed, uint256 amount, uint256 time);

    modifier onlyStaker() {
        require(_stakes[msg.sender].length != 0,"Storage: not a staker");
        _;
    }

    function stakes(address user) public view returns (uint[] memory, uint[] memory) {
        return (_stakes[user],_stakeTimes[user]);
    }

    function withdrawals(address user) public view returns (uint[] memory, uint[] memory) {
        return (_withdrawals[user],_withdrawalTimes[user]);
    }

    function _hasStake(address user) internal view returns(bool) {
        return _stakes[user].length != 0 ? true : false;
    }

    function _hasIndexedStake(address user, uint index) internal view returns(bool) {
        return _stakes[user][index] != 0 ? true : false;
    }

    function _hasIndexedWithdrawal(address user, uint index) internal view returns(bool) {
        return _withdrawals[user][index] != 0 ? true : false;
    }

    function _hasWithdrawal(address user) internal view returns(bool) {
        return _withdrawals[user].length != 0 ? true : false;
    }

    function _stakedAmount(address user, uint index) internal view returns(uint256) {
        return _stakes[user][index];
    }

    function _stakeTime(address user, uint index) internal view returns(uint256) {
        return _stakeTimes[user][index];
    }

    function _withdrawalAmount(address user, uint index) internal view returns(uint256) {
        return _withdrawals[user][index];
    }

    function _withdrawalTime(address user, uint index) internal view returns(uint256) {
        return _withdrawalTimes[user][index];
    }

    function _deleteStakeEntry(address user, uint index) internal {
        emit StakeEntryRemoved(user,_stakes[user][index],block.timestamp);
        if(_stakes[user].length == index + 1) {
            delete _stakes[user][index];
            delete _stakeTimes[user][index];
        } else {
            for (uint i = index; i < _stakes[user].length - 1; i++) {
                _stakes[user][i] = _stakes[user][i+1];
                _stakeTimes[user][i] = _stakeTimes[user][i+1];
            }
            delete _stakes[user][_stakes[user].length];
            delete _stakeTimes[user][_stakeTimes[user].length];
        }
    }

    function _addStakeEntry(address user, uint256 amount) internal {
        _stakes[user].push(amount);
        _stakeTimes[user].push(block.timestamp);
        emit StakeEntryAdded(user, amount, block.timestamp);
    }

    function _deleteWithdrawalEntry(address user, uint index) internal {
        emit WithdrawalEntryRemoved(user,_withdrawals[user][index],block.timestamp);
        if(_withdrawals[user].length == index + 1) {
            delete _withdrawals[user][index];
            delete _withdrawalTimes[user][index];
        } else {
            for (uint i = index; i < _withdrawals[user].length - 1; i++) {
                _withdrawals[user][i] = _withdrawals[user][i+1];
                _withdrawalTimes[user][i] = _withdrawalTimes[user][i+1];
            }
            delete _withdrawals[user][_withdrawals[user].length];
            delete _withdrawalTimes[user][_withdrawalTimes[user].length];
        }
    }

    function _addWithdrawalEntry(address user, uint256 amount) internal {
        _withdrawals[user].push(amount);
        _withdrawalTimes[user].push(block.timestamp);
        emit WithdrawalEntryAdded(user,amount,block.timestamp);
    }

    function _addRewardsDistributed(address user, uint256 amount) internal {
        _rewardsDistributed += amount;
        _rewardsClaimed[user] += amount;
    }
}