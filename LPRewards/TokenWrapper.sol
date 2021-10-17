// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4-solc-0.7/contracts/math/SafeMath.sol";

contract TokenWrapper {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public stakeToken;

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;

  /**
   * @dev Check the total supply of tokens
   * @returns Total number of tokens in existence
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev Check the balance of user
   * @param account User address to check
   * @returns User balance
   */
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev Deposit tokens
   * @param amount Amount of tokens to deposit
   */
  function stake(uint256 amount) public virtual {
    _totalSupply = _totalSupply.add(amount);
    _balances[msg.sender] = _balances[msg.sender].add(amount);
    stakeToken.safeTransferFrom(msg.sender, address(this), amount);
  }

  /**
   * @dev Withdraw tokens
   * @param amount Amount of tokens to withdraw
   */
  function withdraw(uint256 amount) public virtual {
    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    stakeToken.safeTransfer(msg.sender, amount);
  }
}
