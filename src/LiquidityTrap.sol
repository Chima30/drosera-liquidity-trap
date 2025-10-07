// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "contracts/interfaces/ITrap.sol";

contract LiquidityTrap is ITrap {
    address public constant TOKEN = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;

    // The collect function: returns encoded data (required by ITrap)
    function collect() external view override returns (bytes memory) {
        // For now, just return placeholder data
        return abi.encode(TOKEN);
    }

    // The shouldRespond function: processes data and decides whether to act
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Placeholder logic: always false for now
        return (false, bytes(""));
    }
}

