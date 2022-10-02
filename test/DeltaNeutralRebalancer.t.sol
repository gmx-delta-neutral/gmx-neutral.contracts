// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {DeltaNeutralRebalancer} from "src/DeltaNeutralRebalancer.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";

contract DeltaNeutralRebalancerTest is Test {
    DeltaNeutralRebalancer private deltaNeutralRebalancer;    

    function setUp() public {
        address glpPositionManagerAddress = address(1); 
        address btcPoolPositionManagerAddress = address(2); 
        address ethPoolPositionManagerAddress = address(3); 
        address btcAddress = address(4);
        address ethAddress = address(5);
        
        vm.mockCall(
            address(1),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(878726)
        );

        vm.mockCall(
            address(2),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(1020000)
        );

        vm.mockCall(
            address(3),
            abi.encodeCall(IPositionManager.price, ()),
            abi.encode(1040000)
        );

        vm.mockCall(
            address(address(1)),
            abi.encodeCall(IPositionManager.allocationByToken, (btcAddress)),
            abi.encode(TokenAllocation({
                percentage: 150,
                tokenAddress: btcAddress,
                leverage: 1
            }))
        );

        vm.mockCall(
            address(address(1)),
            abi.encodeCall(IPositionManager.allocationByToken, (ethAddress)),
            abi.encode(TokenAllocation({
                percentage: 200,
                tokenAddress: ethAddress,
                leverage: 1
            }))
        );

        vm.mockCall(
            address(address(2)),
            abi.encodeCall(IPositionManager.allocationByToken, (btcAddress)),
            abi.encode(TokenAllocation({
                percentage: 1000,
                tokenAddress: btcAddress,
                leverage: 3
            }))
        );

        vm.mockCall(
            address(address(3)),
            abi.encodeCall(IPositionManager.allocationByToken, (ethAddress)),
            abi.encode(TokenAllocation({
                percentage: 1000,
                tokenAddress: ethAddress,
                leverage: 3
            }))
        );

        deltaNeutralRebalancer = new DeltaNeutralRebalancer(glpPositionManagerAddress, btcPoolPositionManagerAddress, ethPoolPositionManagerAddress, btcAddress, ethAddress);
    }

    function testGetRebalancedAllocation() public {
        (uint256 glpToHave, uint256 btcPerpToHave, uint256 ethPerpToHave) = deltaNeutralRebalancer.getRebalancedAllocation();
        assertEq(glpToHave, 1019115631); 
        assertEq(btcPerpToHave, 43898206);
        assertEq(ethPerpToHave, 57405345);
   }
}


