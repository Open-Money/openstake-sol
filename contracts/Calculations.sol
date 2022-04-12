// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Constants.sol";
import "./Storage.sol";

contract Calculations is Constants, Storage {

    function calculatePendingReward(address user, uint index) public view returns (uint256) {
        return _canRemoveStake(user, index) ? _calculateReward(_elapsedTime(user, index),_stakedAmount(user, index)) : 0;
    }

    function calculateReward(address user, uint index) public view returns (uint256) {
        return _calculateReward(_elapsedTime(user, index),_stakedAmount(user, index));
    }

    function _elapsedTime(address user, uint index) internal view returns (uint256) {
        return block.timestamp - _stakeTime(user, index);
    }

    function _canRemoveStake(address user, uint index) internal view returns (bool) {
        return _elapsedTime(user, index) > _minRewardDuration ? true : false;
    }

    function _calculateReward(uint256 elapsedTime, uint256 amount) internal view returns (uint) {
        uint amountUint = amount / 10**18;
        return amount + (amountUint * _rewardMultiplierPerSecond * elapsedTime);
    }

    function _calculatePenalty(uint256 amount) internal view returns (uint) {
        return amount * _penaltyConstant / 10**18;
    }

    function _elapsedWithdrawalTime(address user, uint index) internal view returns (uint256) {
        return block.timestamp - _withdrawalTime(user, index);
    }

    function _canWithdraw(address user, uint index) internal view returns (bool) {
        return _elapsedWithdrawalTime(user, index) >= _valorDuration ? true : false;
    }
   
}