// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "hardhat/console.sol";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

describe("BlinkBat", function () {
  let BlinkBat;
  let blinkBat;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    BlinkBat = await ethers.getContractFactory("BlinkBat");
    blinkBat = await BlinkBat.deploy();
    await blinkBat.deployed();
  });

  it("Should have correct name and symbol", async function () {
    expect(await blinkBat.name()).to.equal("BlinkBat");
    expect(await blinkBat.symbol()).to.equal("BBT");
  });

  it("Should have correct total supply", async function () {
    const totalSupply = await blinkBat.TOTAL_SUPPLY();
    expect(await blinkBat.totalSupply()).to.equal(totalSupply);
  });

  it("Should transfer tokens correctly", async function () {
    const initialBalanceOwner = await blinkBat.balanceOf(owner.address);
    const transferAmount = ethers.utils.parseEther("100");

    await blinkBat.transfer(addr1.address, transferAmount);
    expect(await blinkBat.balanceOf(addr1.address)).to.equal(transferAmount);
    expect(await blinkBat.balanceOf(owner.address)).to.equal(initialBalanceOwner.sub(transferAmount));
  });

  it("Should not allow transfers of frozen tokens before freeze period ends", async function () {
    const freezeUntil = await blinkBat.freezeUntil();
    const transferAmount = ethers.utils.parseEther("100");

    await expect(blinkBat.connect(owner).transfer(addr1.address, transferAmount)).to.be.revertedWith("BlinkBat: transfer of frozen tokens is restricted");
  });

  it("Should allow transfers of frozen tokens after freeze period ends", async function () {
    const freezeUntil = await blinkBat.freezeUntil();
    const transferAmount = ethers.utils.parseEther("100");

    // Increase time to after freeze period
    await ethers.provider.send("evm_increaseTime", [freezeUntil.toNumber()]);

    await blinkBat.connect(owner).transfer(addr1.address, transferAmount);
    expect(await blinkBat.balanceOf(addr1.address)).to.equal(transferAmount);
  });

  // Add more tests as needed
});
