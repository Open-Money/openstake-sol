// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Constants is Ownable {

    uint256 public _minRewardDuration;
    uint256 public _minStakingAmount;
    uint256 public _rewardMultiplierPerSecond;
    uint256 public _valorDuration;
    uint256 public _penaltyConstant;

    event MinRewardDurationAdjusted(uint256 minRewardDuration, uint256 newMinRewardDuration);
    event MinStakingAmountAdjusted(uint256 minStakingAmount, uint256 newMinStakingAmount);
    event RewardMultiplierAdjusted(uint256 rewardMultiplierPerSecond, uint256 newRewardMultiplierPerSecond);
    event ValorDurationAdjusted(uint256 valorDuration, uint256 newValorDuration);
    event PenaltyConstantAdjusted(uint256 penaltyConstant, uint256 newPenaltyConstant);

    // ONLY OWNER ADJUSTERS FOR CONSTANTS // 

    function adjustMinRewardDuration(uint256 newMinRewardDuration) public onlyOwner {
        emit MinRewardDurationAdjusted(_minRewardDuration, newMinRewardDuration);
        _minRewardDuration = newMinRewardDuration;
    }

    function adjustMinStakingAmount(uint256 newMinStakingAmount) public onlyOwner {
        emit MinStakingAmountAdjusted(_minStakingAmount, newMinStakingAmount);
        _minStakingAmount = newMinStakingAmount;
    }

    function adjustRewardMultiplier(uint256 newRewardMultiplierPerSecond) public onlyOwner {
        emit RewardMultiplierAdjusted(_rewardMultiplierPerSecond, newRewardMultiplierPerSecond);
        _rewardMultiplierPerSecond = newRewardMultiplierPerSecond;
    }

    function adjustValorDuration(uint256 newValorDuration) public onlyOwner {
        emit ValorDurationAdjusted(_valorDuration, newValorDuration);
        _valorDuration = newValorDuration;
    }

    function adjustPenaltyConstant(uint256 newPenaltyConstant) public onlyOwner {
        emit PenaltyConstantAdjusted(_penaltyConstant, newPenaltyConstant);
        _penaltyConstant = newPenaltyConstant;
    }

}