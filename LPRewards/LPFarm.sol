// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/math/Math.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/math/SafeMath.sol";

import "./FarmController.sol";
import "./TokenWrapper.sol";
import "./IRewardDistributionRecipientTokenOnly.sol";

/**
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

contract LPFarm is TokenWrapper, IRewardDistributionRecipientTokenOnly {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  FarmController public controller;

  IERC20 public override rewardToken;

  uint256 public constant DURATION = 7 days;

  uint256 public periodFinish;

  uint256 public rewardRate;

  uint256 public lastUpdateTime;

  uint256 public rewardPerTokenStored;

  mapping(address => uint256) public userRewardPerTokenPaid;

  mapping(address => uint256) public rewards;

  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);

  modifier onlyController() {
    require(msg.sender == address(controller), "Caller is not controller");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == Ownable(address(controller)).owner(), "Caller is not owner");
    _;
  }

  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = lastTimeRewardApplicable();
    if (account != address(0)) {
      rewards[account] = earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored;
    }
    _;
  }

  function initialize(address _stakeToken, address _controller)
  external
  {
    require(address(stakeToken) == address(0), "already initialized");
    stakeToken = IERC20(_stakeToken);
    controller = FarmController(_controller);
    rewardToken = controller.rewardToken();

    periodFinish = 0;
    rewardRate = 0;
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return Math.min(block.timestamp, periodFinish);
  }

  function rewardPerToken()
  public
  view
  returns (uint256)
  {
    if (totalSupply() == 0) {
      return rewardPerTokenStored;
    }
    return
    rewardPerTokenStored.add(
      lastTimeRewardApplicable()
      .sub(lastUpdateTime)
      .mul(rewardRate)
      .mul(1e18)
      .div(totalSupply())
    );
  }

  function earned(address account)
  public
  view
  returns (uint256)
  {
    return
    balanceOf(account)
    .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
    .div(1e18)
    .add(rewards[account]);
  }

  function stake(uint256 amount)
  public
  override
  updateReward(msg.sender)
  {
    require(amount > 0, "Cannot stake 0");
    super.stake(amount);
    emit Staked(msg.sender, amount);
  }

  function withdraw(uint256 amount)
  public
  override
  updateReward(msg.sender)
  {
    require(amount > 0, "Cannot withdraw 0");
    super.withdraw(amount);
    emit Withdrawn(msg.sender, amount);
  }

  function exit()
  external
  {
    withdraw(balanceOf(msg.sender));
    getReward();
  }

  function getReward()
  public
  updateReward(msg.sender)
  {
    uint256 reward = earned(msg.sender);
    if (reward > 0) {
      rewards[msg.sender] = 0;
      rewardToken.safeTransfer(msg.sender, reward);
      emit RewardPaid(msg.sender, reward);
    }
  }

  function notifyRewardAmount(uint256 reward)
  external
  override
  onlyController
  updateReward(address(0))
  {
    rewardToken.safeTransferFrom(msg.sender, address(this), reward);
    if (block.timestamp >= periodFinish) {
      rewardRate = reward.div(DURATION);
    } else {
      uint256 remaining = periodFinish.sub(block.timestamp);
      uint256 leftover = remaining.mul(rewardRate);
      rewardRate = reward.add(leftover).div(DURATION);
    }
    lastUpdateTime = block.timestamp;
    periodFinish = block.timestamp.add(DURATION);
    emit RewardAdded(reward);
  }
}
