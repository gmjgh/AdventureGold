// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library UtilsCollection {

    function random(string memory input) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pluck(uint256 tokenId, uint256 timestamp, uint256 maxValue, string memory prefix) public pure returns (uint256) {
        uint256 rand = random(string(abi.encodePacked(prefix, toString(tokenId), toString(timestamp))));
        return rand % maxValue;
    }

    function uint24ToHexStr(uint24 i, uint bytesCount) public pure returns (string memory) {
        bytes memory o = new bytes(bytesCount);
        uint24 mask = 0x0f;
        // hex 15
        uint k = bytesCount;
        do {
            k--;
            o[k] = bytes1(uint8ToHexCharCode(uint8(i & mask)));
            i >>= 4;
        }
        while (k > 0);
        return string(o);
    }

    function generateColor(uint256 tokenId, uint256 timestamp) public pure returns (string memory) {
        uint24 red = uint24(pluck(tokenId, timestamp, 255, "red"));

        uint24 green = uint24(pluck(tokenId, timestamp, 255, "green"));

        uint24 blue = uint24(pluck(tokenId, timestamp, 255, "blue"));

        return string(abi.encodePacked(uint24ToHexStr(red, 2), uint24ToHexStr(green, 2), uint24ToHexStr(blue, 2)));
    }

    function uint8ToHexCharCode(uint8 i) public pure returns (uint8) {
        return (i > 9) ?
        (i + 87) : // ascii a-f
        (i + 48);
        // ascii 0-9
    }

    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}