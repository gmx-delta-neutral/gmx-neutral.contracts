// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TokenExposure} from "src/TokenExposure.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";

interface IGlpUtils {
    function getGlpTokenAllocations(address[] memory tokens)
        external
        view
        returns (GlpTokenAllocation[] memory);

    function getGlpTokenExposure(
        uint256 glpPositionWorth,
        address[] memory tokens
    ) external view returns (TokenExposure[] memory);
}
