pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT


// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

// Defining Library
library HatLibrary {
    function getHat(string memory color) public pure returns (string memory) {
        string memory hat = string(
            abi.encodePacked(
                ' <g id="_2482263835104"><path fill="',color,'" stroke="#2B2A29" stroke-width="2.36221" d="M404 338c3,2 3,3 10,3 10,2 21,2 31,5 15,5 16,14 38,13 18,-2 22,-3 38,6 54,30 69,-12 113,-14 28,-1 63,-5 85,-15 -5,-8 -64,-33 -72,-36 -6,7 -8,16 -32,25 -22,8 -77,8 -99,-1 -25,-10 -27,-14 -26,-29 -20,4 -71,31 -86,43z"/> <path fill="',color,'" stroke="#2B2A29" stroke-width="2.36221" d="M610 231c8,2 24,13 28,18 10,13 -3,36 18,35l31 -4c-4,-10 -27,-36 -34,-45 -11,-12 -29,-33 -49,-30 -17,4 -42,15 -58,21 -29,12 -34,8 -46,34 -11,24 -11,36 16,46 42,15 119,6 122,-25 4,-39 -14,-36 -28,-50z"/> <path fill="none" stroke="#2B2A29" stroke-width="2.36221" d="M523 273c4,0 20,-6 20,-14"/><path fill="#181817" stroke="#2B2A29" stroke-width="2.36221" d="M639 272c-5,8 -5,10 -12,16 -20,14 -39,19 -63,18 -14,-1 -30,-4 -43,-11 -2,-1 -7,-4 -8,-6l-7 -9c-1,0 -1,-1 -1,-1l-4 -9c0,0 -2,-2 -2,-3 0,-1 -1,0 -1,-1 -17,48 -5,46 9,56 26,17 86,17 108,7 8,-4 28,-13 30,-21 2,-9 -1,-28 -6,-36z"/> </g>'
            )
        );

        return hat;
    }
}
