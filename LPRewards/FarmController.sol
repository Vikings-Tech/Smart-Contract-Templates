// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.4-solc-0.7/contracts/access/OwnableUpgradeable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/math/SafeMath.sol";

import "./LPFarm.sol";
import "./IRewardDistributionRecipientTokenOnly.sol";

contract FarmController is OwnableUpgradeable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IRewardDistributionRecipientTokenOnly[] public farms;

  mapping(address => address) public lpFarm;

  mapping(address => uint256) public rate;

  uint256 public weightSum;

  IERC20 public rewardToken;

  /**
   * @dev Init the contract
   * @param token Initial reward token
   */
  function initialize(address token)
  external
  {
    __Ownable_init();
    rewardToken = IERC20(token);
  }

  /**
   * @dev Add new farm under management of this controller
   * @param _lptoken Deposit token
   * @returns farm Address of new farm
   */
  function addFarm(address _lptoken)
  external
  onlyOwner
  returns (address farm)
  {
    require(lpFarm[_lptoken] == address(0), "farm exist");
    bytes memory bytecode = type(LPFarm).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_lptoken));
    assembly {
      farm := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }
    LPFarm(farm).initialize(_lptoken, address(this));
    farms.push(IRewardDistributionRecipientTokenOnly(farm));
    rewardToken.approve(farm, uint256(- 1));
    lpFarm[_lptoken] = farm;
    // it will just set the rates to zero before it get's it's own rate
  }

  /**
   * @dev Set farm reward rates
   * @param _rates Proportions of reward allocation for each farm
   */
  function setRates(uint256[] memory _rates)
  external
  onlyOwner
  {
    require(_rates.length == farms.length);
    uint256 sum = 0;
    for (uint256 i = 0; i < _rates.length; i++) {
      sum += _rates[i];
      rate[address(farms[i])] = _rates[i];
    }
    weightSum = sum;
  }

  /**
   * @dev Set reward rate of specific farm
   * @param _farm Address of farm
   * @param _rate Proportion of reward allocation for this farm
   */
  function setRateOf(address _farm, uint256 _rate)
  external
  onlyOwner
  {
    weightSum -= rate[_farm];
    weightSum += _rate;
    rate[_farm] = _rate;
  }

  /**
   * @dev Notify farms about new reward available
   * @param amount Amount to distribute among farms
   */
  function notifyRewards(uint256 amount)
  external
  onlyOwner
  {
    rewardToken.transferFrom(msg.sender, address(this), amount);
    for (uint256 i = 0; i < farms.length; i++) {
      IRewardDistributionRecipientTokenOnly farm = farms[i];
      farm.notifyRewardAmount(amount.mul(rate[address(farm)]).div(weightSum));
    }
  }

  /**
   * @dev Partially notify farms about new reward available
   * should transfer rewardToken prior to calling this contract
   * this is implemented to take care of the out-of-gas situation
   * @param amount Amount to distribute
   * @param from Start index of farms
   * @param to End index of farms
   */
  function notifyRewardsPartial(uint256 amount, uint256 from, uint256 to)
  external
  onlyOwner
  {
    require(from < to, "from should be smaller than to");
    require(to <= farms.length, "to should be smaller or equal to farms.length");
    for (uint256 i = from; i < to; i++) {
      IRewardDistributionRecipientTokenOnly farm = farms[i];
      farm.notifyRewardAmount(amount.mul(rate[address(farm)]).div(weightSum));
    }
  }

  /**
   * @dev Check how many farms are added
   * @returns Number of farms
   */
  function getFarmsCount()
  external
  view
  returns (uint256)
  {
    return farms.length;
  }

  /**
   * @dev Query the specific farm
   * @param _index Index of farm
   * @returns Farm
   */
  function getFarm(uint _index)
  external
  view
  returns (IRewardDistributionRecipientTokenOnly)
  {
    return farms[_index];
  }
}
