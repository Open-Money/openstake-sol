const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking contract", function () {

    let Staking;
    let StakingContract;
    let addresses;

    it("Deployment should be fine", async function () {
        addresses = await ethers.getSigners();
        Staking = await ethers.getContractFactory("OpenStake");
        StakingContract = await Staking.deploy();
    });

    it("Trying to adjust owner", async function() {
        await expect(
            StakingContract.connect(addresses[1]).changeOwner(addresses[2].address)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await StakingContract.changeOwner(addresses[1].address);

        await expect(
            StakingContract.changeOwner(addresses[2].address)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await StakingContract.connect(addresses[1]).changeOwner(addresses[0].address)
    })

    it("Testing constants", async function() {
        await expect(
            StakingContract.connect(addresses[1]).adjustMinRewardDuration(30)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await expect(
            StakingContract.connect(addresses[1]).adjustMinStakingAmount(30)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await expect(
            StakingContract.connect(addresses[1]).adjustRewardMultiplier(30)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await expect(
            StakingContract.connect(addresses[1]).adjustValorDuration(30)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await expect(
            StakingContract.connect(addresses[1]).adjustPenaltyConstant(30)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await StakingContract.adjustMinRewardDuration(15);
        await StakingContract.adjustMinStakingAmount(10000);
        await StakingContract.adjustRewardMultiplier(8561643836);
        await StakingContract.adjustValorDuration(30);
        await StakingContract.adjustPenaltyConstant('800000000000000000');

        const _minRewardDuration = await StakingContract._minRewardDuration();
        const _minStakingAmount = await StakingContract._minStakingAmount();
        const _rewardMultiplierPerSecond = await StakingContract._rewardMultiplierPerSecond();
        const _valorDuration = await StakingContract._valorDuration();
        const _penaltyConstant = await StakingContract._penaltyConstant();
        
        expect(_minRewardDuration).to.equal(15);
        expect(_minStakingAmount).to.equal(10000);
        expect(_rewardMultiplierPerSecond).to.equal(8561643836);
        expect(_valorDuration).to.equal(30);
        expect(_penaltyConstant).to.equal("800000000000000000");
    });

    
})