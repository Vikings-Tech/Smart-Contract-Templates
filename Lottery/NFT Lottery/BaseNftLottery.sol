//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

/// @author Team Vikings Tech
/// @title NFT Lottery Contract using Chainlink VRF
contract Lottery is Ownable,VRFConsumerBase{
  
 /**  
 * @dev PURPOSE
 *
 * @dev A smart contract creator would like to organize a Lottery
 * @dev for this lottery the creator wants to randomly transfer an
 * @dev NFT to one of the users from the list 
 * 
 * @dev ASSUMPTIONS
 * 
 * @dev We assume that the length of the list is < 10^70
 */
 
  bytes32 internal keyHash;
  uint256 internal fee;
  
  /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
  */
 
  constructor() 
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18; // 0.1 LINK (Varies by network)
  }

  /**
    * @notice setLinkHash function allows owner to sent Key hash 
    * 
    * @dev Use this function to change key hash at any point after deployment
    * 
    * @param newHash to be the New Key hash value in bytes32
    * 
  */
  function setLinkHash(bytes32 newHash) external onlyOwner{
     keyHash = newHash;
  }
 
  /**
    * @notice setLinkFee function allows owner to sent Key hash 
    * 
    * @dev Use this function to change link fee at any point after deployment
    * 
    * @param newFee to be the New Fee value in uint256
    * 
  */
  function setLinkFee(uint256 newFee) external onlyOwner{
     fee = newFee;
  }
 
  struct requestMetaData{
     address contractAddress;
     address sender;
     address[] userList;
     uint256 tokenId;
  }
 
  mapping(bytes32=>requestMetaData) requestData;
 
  /**
    * @notice initiateLottery initiates lottery for users from given list 
    * 
    * @dev Use this function call lottery on any owned NFT from any contract
    * 
    * @dev make sure to approve this contract address for the token ID before
    * @dev calling this function
    * 
    * @param contractAddress Contract Address of the NFT contract
    * @param usersList Array of valid user addresses to choose from
    * @param tokenId ID of token to be transferred
    * 
  */
  function initiateLottery(address contractAddress,address[] memory usersList,uint256 tokenId) external{
     require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
     require(IERC721(contractAddress).getApproved(tokenId) == address(this),"Approve this address to make transfers");
     requestData[requestRandomness(keyHash, fee)] = requestMetaData(
         contractAddress,
         msg.sender,
         usersList,
         tokenId
     );
  }
 
  /**
    * @notice fulfillRandomness performs the task based on Random number
    * 
    * @dev this is an internal function callback from VRFConsumerBase
    * 
    * @param requestId Unique ID for VRF request
    * @param randomness Random value produced by VRF
    * 
  */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
     requestMetaData memory data = requestData[requestId];
     address toAddress = data.userList[randomness%data.userList.length];
     IERC721(data.contractAddress).safeTransferFrom(data.sender,toAddress,data.tokenId);
  }
 
}