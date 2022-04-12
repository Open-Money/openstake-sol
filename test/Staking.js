const { expect } = require("chai");
const { ethers, network } = require("hardhat");

describe("Staking contract", function () {

    let Staking;
    let StakingContract;
    let addresses;

    it("Should be deploying contract", async function () {
        addresses = await ethers.getSigners();
        Staking = await ethers.getContractFactory("OpenStake");
        StakingContract = await Staking.deploy();

        await StakingContract.depositToTreasury({value: ethers.utils.parseEther("70")});
    });

    it("Should be adjusting owner", async function() {
        await expect(
            StakingContract.connect(addresses[1]).changeOwner(addresses[2].address)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await StakingContract.changeOwner(addresses[1].address);

        await expect(
            StakingContract.changeOwner(addresses[2].address)
        ).to.be.revertedWith("Ownable: you are not the owner");

        await StakingContract.connect(addresses[1]).changeOwner(addresses[0].address)
    })

    it("Should be setting constants", async function() {
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

    it("Should be checking storage functions", async function() {
        let _rewardsDistributed = await StakingContract._rewardsDistributed();
        expect(_rewardsDistributed).to.equal(0);
        let _rewardsClaimedAddr1 = await StakingContract._rewardsClaimed(addresses[1].address);
        expect(_rewardsClaimedAddr1).to.equal(0);
    });

    it("Should be staking & unstaking & compounding & withdrawing", async function() {
        await StakingContract.connect(addresses[3]).stake({value: ethers.utils.parseEther("30")});
        let myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);
        await StakingContract.connect(addresses[3]).stake({value: ethers.utils.parseEther("30")});
        myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);
        await network.provider.send("evm_increaseTime",[3600000]);
        await StakingContract.connect(addresses[3]).compound(1);
        await network.provider.send("evm_increaseTime",[3600000]);
        await StakingContract.connect(addresses[3]).compound(1);
        await network.provider.send("evm_increaseTime",[3600000]);
        await StakingContract.connect(addresses[3]).compound(1);
        await network.provider.send("evm_increaseTime",[3600000]);
        await StakingContract.connect(addresses[3]).compound(1);
        await network.provider.send("evm_increaseTime",[3600000]);
        myStakes = await StakingContract.stakes(addresses[3].address);
        console.log(myStakes);
        //console.log("OK");
        await StakingContract.connect(addresses[3]).unstake(0);
        //console.log("OK");
        myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);
        await StakingContract.connect(addresses[3]).unstake(0);
        myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);
        await StakingContract.connect(addresses[3]).stake({value: ethers.utils.parseEther("30")});
        myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);
        await network.provider.send("evm_increaseTime",[3600]);
        await StakingContract.connect(addresses[3]).unstake(0);
        myStakes = await StakingContract.stakes(addresses[3].address);
        //console.log(myStakes);

        let myWithdrawals = await StakingContract.withdrawals(addresses[3].address);
        console.log(myWithdrawals);

        await network.provider.send("evm_increaseTime",[3600]);
        await StakingContract.connect(addresses[3]).withdraw(0);
        await StakingContract.connect(addresses[3]).withdraw(0);
        await StakingContract.connect(addresses[3]).withdraw(0);

        myWithdrawals = await StakingContract.withdrawals(addresses[3].address);
        //console.log(myWithdrawals);
    });
})