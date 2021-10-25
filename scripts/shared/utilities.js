const { ethers } = require('hardhat');
const { BigNumber } = ethers;

function getCreate2CohortAddress(actuaryAddress, { cohortName, sender, nonce }, bytecode) {
  const create2Inputs = [
    '0xff',
    actuaryAddress,
    ethers.utils.keccak256(ethers.utils.solidityPack(['address', 'string', 'uint'], [sender, cohortName, nonce])),
    ethers.utils.keccak256(bytecode),
  ];
  const sanitizedInputs = `0x${create2Inputs.map((i) => i.slice(2)).join('')}`;

  return ethers.utils.getAddress(`0x${ethers.utils.keccak256(sanitizedInputs).slice(-40)}`);
}

// Defaults to e18 using amount * 10^18
function getBigNumber(amount, decimals = 18) {
  return BigNumber.from(amount).mul(BigNumber.from(10).pow(decimals));
}

function getPaddedHexStrFromBN(bn) {
  const hexStr = ethers.utils.hexlify(bn);
  return ethers.utils.hexZeroPad(hexStr, 32);
}

function getHexStrFromStr(str) {
  const strBytes = ethers.utils.toUtf8Bytes(str);
  return ethers.utils.hexlify(strBytes);
}

module.exports = {
  getCreate2CohortAddress,
  getBigNumber,
  getPaddedHexStrFromBN,
  getHexStrFromStr,
};
