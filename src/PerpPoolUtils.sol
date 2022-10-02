// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPoolCommitter,UserCommitment} from "perp-pool/IPoolCommitter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {PriceUtils} from "src/PriceUtils.sol";
import {PositionType} from "src/PositionType.sol";

contract PerpPoolUtils {
  IPoolCommitter private poolCommitter;
  PriceUtils private priceUtils;
  ERC20 private poolToken;

  constructor(address _poolCommitterAddress, address _poolTokenAddress, address _priceUtilsAddress) {
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
    poolToken = ERC20(_poolTokenAddress);
    priceUtils = PriceUtils(_priceUtilsAddress);
  }

  function getCommittedUsdcWorth(address poolPositionPurchaserAddress) external view returns (uint256) {
    uint256 totalCommitments = 0;
    uint256 currentIndex = 0;

    while (true) {
      try poolCommitter.unAggregatedCommitments(poolPositionPurchaserAddress,currentIndex) returns (uint256 intervalId) {
        UserCommitment memory userCommitment = poolCommitter.userCommitments(poolPositionPurchaserAddress, intervalId);
        totalCommitments += userCommitment.shortMintSettlement;
        currentIndex += 1;
      } catch {
        break;
      }
    }

    return totalCommitments;
  }

  function getClaimedUsdcWorth(address poolPositionPurchaserAddress, address leveragedPoolAddress) external view returns (uint256) {
    uint256 balance = poolToken.balanceOf(poolPositionPurchaserAddress);
    uint256 claimedAmount = balance * priceUtils.perpPoolTokenPrice(leveragedPoolAddress, PositionType.Short);
    return balance * claimedAmount;
  }
}