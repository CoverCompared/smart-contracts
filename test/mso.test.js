const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getBigNumber } = require("../scripts/shared/utilities");

describe("MSOPolka", function () {
  before(async function() {
    this.MSOPolka = await ethers.getContractFactory("MSOPolka");
    this.signers = await ethers.getSigners();
  })

  beforeEach(async function () {
    this.claimAssessor = await this.ClaimAssessor.deploy();
  })

//   it("Should not allow others to request claim except owner", async function() {
//     await expect(
//       this.claimAssessor
//         .connect(this.signers[1])
//         .requestClaim(
//           this.signers[1].address,
//           this.cohort.address,
//           0,
//           getBigNumber(1000000000),
//           { from: this.signers[1].address }
//         )
//       ).to.be.revertedWith("Ownable: caller is not the owner");
//   })
});
