var NetworkLogic = artifacts.require("./NetworkLogic.sol");

const authorities = [
  "0x71D437EDB75dEA9CAFdDC0151819388A2897306f",
  "0x1009D5bd89Bf33fb126a4D3886f94f6De18Cfe2f",
  "0x5366f3CA250A481CF65fbda710C4dE2E08602Cf4",
  "0x1c506F777f960E24561B91ddF470AeA660505C02"
];

module.exports = function(deployer) {
  deployer.deploy(NetworkLogic, authorities);
};
