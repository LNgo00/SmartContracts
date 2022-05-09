const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Multi = await ethers.getContractFactory("MultiSend");
    const contract = await Multi.deploy();

    const prueba = await contract.sendTokens("0x01BE23585060835E02B77ef475b0Cc51aA1e0709",1000,"0xbd07739Fe4e7BAb53Ec9640FcBcFcbED7362FED8");
    expect(send).to.equal(1000);

  });
});
