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

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function stake(uint256 amount) public virtual {
    _totalSupply = _totalSupply.add(amount);
    _balances[msg.sender] = _balances[msg.sender].add(amount);
    stakeToken.safeTransferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint256 amount) public virtual {
    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    stakeToken.safeTransfer(msg.sender, amount);
  }
}
