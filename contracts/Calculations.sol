// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Constants.sol";
import "./Storage.sol";

contract Calculations is Constants, Storage {

    function calculatePendingReward(address user) public view returns (uint256) {
        return _canRemoveStake(user) ? _calculateReward(_elapsedTime(user),_stakedAmount(user)) : 0;
    }

    function calculateReward(address user) public view returns (uint256) {
        return _calculateReward(_elapsedTime(user),_stakedAmount(user));
    }

    function _elapsedTime(address user) internal view returns (uint256) {
        return block.timestamp - _stakeTime(user);
    }

    function _canRemoveStake(address user) internal view returns (bool) {
        return _elapsedTime(user) > _minRewardDuration ? true : false;
    }

    function _calculateReward(uint256 elapsedTime, uint256 amount) internal view returns (uint) {
        uint amountUint = amount / 10**18;
        return amount + (amountUint * _rewardMultiplierPerSecond * elapsedTime);
    }

    function _calculatePenalty(uint256 amount) internal view returns (uint) {
        return amount * _penaltyConstant / 10**18;
    }

    function _elapsedWithdrawalTime(address user) internal view returns (uint256) {
        return block.timestamp - _withdrawals[user].entranceTimestamp_;
    }

    function _canWithdraw(address user) internal view returns (bool) {
        return _elapsedWithdrawalTime(user) >= _valorDuration ? true : false;
    }
   
}