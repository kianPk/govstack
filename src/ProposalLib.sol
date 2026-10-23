// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Treasury} from "./Treasury.sol";

/// @title ProposalLib
/// @notice Helpers to encode common governance actions for GovStack demos.
library ProposalLib {
    function ethGrant(address treasury, address payable to, uint256 amount)
        public
        pure
        returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas)
    {
        targets = new address[](1);
        values = new uint256[](1);
        calldatas = new bytes[](1);
        targets[0] = treasury;
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(Treasury.spendETH.selector, to, amount);
    }

    function tokenGrant(address treasury, address token, address to, uint256 amount)
        public
        pure
        returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas)
    {
        targets = new address[](1);
        values = new uint256[](1);
        calldatas = new bytes[](1);
        targets[0] = treasury;
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(Treasury.spendToken.selector, token, to, amount);
    }
}
