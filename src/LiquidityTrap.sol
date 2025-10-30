// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32);
}

contract LiquidityTrap is ITrap {
    address public constant PAIR = 0xf80489C1439b6aCcA9FC25B95954ae59Ad69f942;

    function name() external pure override returns (string memory) {
        return "LiquidityTrap";
    }

    function collect() external view override returns (bytes memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(PAIR);
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        return abi.encode(r0, r1);
    }

    // ✅ Adjusted: produces one metric matching respondCallback(uint256)
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length == 0) {
            return (false, "");
        }

        (uint112 r0, uint112 r1) = abi.decode(data[0], (uint112, uint112));
        bool low = (r0 < 100 ether || r1 < 100_000 * 10**6);

        if (low) {
            uint256 metric = uint256(r0) < uint256(r1) ? r0 : r1;
            return (true, abi.encode(metric)); // ✅ single value for responder
        }

        return (false, "");
    }
}
