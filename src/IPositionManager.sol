// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPositionManager {
  function PositionWorth() external view returns (uint256);
  function CostBasis() external view returns (uint256);
  function Pnl() external view returns (int256);

  function BuyPosition(uint256) external returns (uint256);
}