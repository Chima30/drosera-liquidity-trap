// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function name() external pure returns (string memory);
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

