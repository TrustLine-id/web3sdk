const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Trustlined integration paths", function () {
  async function deployMockValidationEngine() {
    const mockFactory = await ethers.getContractFactory("MockValidationEngine");
    const mock = await mockFactory.deploy();
    await mock.waitForDeployment();
    return mock;
  }

  describe("non-upgradeable Trustlined", function () {
    it("uses provided proxy directly", async function () {
      const [deployer, recipient] = await ethers.getSigners();
      const mock = await deployMockValidationEngine();
      await (await mock.initialize(deployer.address)).wait();

      const clientFactory = await ethers.getContractFactory("TestTrustlinedClient");
      const client = await clientFactory.deploy(ethers.ZeroAddress, await mock.getAddress());
      await client.waitForDeployment();

      expect(await client.validationEngine()).to.equal(await mock.getAddress());
      await expect(client.guardedNoArgs()).to.not.be.reverted;
      await expect(client.guardedWithAddress(recipient.address)).to.not.be.reverted;
    });

    it("deploys validation engine proxy when only logic is provided", async function () {
      const [deployer, recipient] = await ethers.getSigners();
      const logic = await deployMockValidationEngine();

      const clientFactory = await ethers.getContractFactory("TestTrustlinedClient");
      const client = await clientFactory.deploy(await logic.getAddress(), ethers.ZeroAddress);
      await client.waitForDeployment();

      const validationEngineProxy = await client.validationEngine();
      expect(validationEngineProxy).to.not.equal(ethers.ZeroAddress);
      expect(validationEngineProxy).to.not.equal(await logic.getAddress());

      const proxiedEngine = await ethers.getContractAt("MockValidationEngine", validationEngineProxy);
      expect(await proxiedEngine.owner()).to.equal(deployer.address);

      await expect(client.guardedNoArgs()).to.not.be.reverted;
      await expect(client.guardedWithAddress(recipient.address)).to.not.be.reverted;
    });
  });

  describe("upgradeable TrustlinedUpgradeable", function () {
    it("initializes through proxy storage and sets validation engine", async function () {
      const [deployer, recipient] = await ethers.getSigners();

      const engineLogic = await deployMockValidationEngine();

      const clientImplFactory = await ethers.getContractFactory("TestTrustlinedUpgradeableClient");
      const clientImpl = await clientImplFactory.deploy();
      await clientImpl.waitForDeployment();

      const proxyFactory = await ethers.getContractFactory("ERC1967Proxy");
      const initData = clientImplFactory.interface.encodeFunctionData("initialize", [
        await engineLogic.getAddress(),
        ethers.ZeroAddress,
      ]);
      const clientProxy = await proxyFactory.deploy(await clientImpl.getAddress(), initData);
      await clientProxy.waitForDeployment();

      const client = await ethers.getContractAt("TestTrustlinedUpgradeableClient", await clientProxy.getAddress());
      const validationEngineProxy = await client.validationEngine();
      expect(validationEngineProxy).to.not.equal(ethers.ZeroAddress);
      expect(validationEngineProxy).to.not.equal(await engineLogic.getAddress());

      const proxiedEngine = await ethers.getContractAt("MockValidationEngine", validationEngineProxy);
      expect(await proxiedEngine.owner()).to.equal(deployer.address);

      await expect(client.guardedNoArgs()).to.not.be.reverted;
      await expect(client.guardedWithAddress(recipient.address)).to.not.be.reverted;
      await expect(client.initialize(await engineLogic.getAddress(), ethers.ZeroAddress)).to.be.revertedWithCustomError(
        client,
        "InvalidInitialization"
      );
    });
  });
});
