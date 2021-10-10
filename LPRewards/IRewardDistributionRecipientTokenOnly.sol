// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/token/ERC20/IERC20.sol";

interface IRewardDistributionRecipientTokenOnly {

  function rewardToken() external view returns(IERC20);

  function notifyRewardAmount(uint256 reward) external;
}
