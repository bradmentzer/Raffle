const ENTRANCE_FEE = ethers.utils.parseEther("0.1");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  const args = [
    ENTRANCE_FEE,
    "300",
    "0x6168499c0cffcacd319c818142124b7a15e857ab",
    "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    "5716",
    "500000",
  ];

  const raffle = await deploy("Raffle", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: 6,
  });
};
