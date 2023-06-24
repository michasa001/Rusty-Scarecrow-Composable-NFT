pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT


// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

// Defining Library
library ScarfLibrary {
    function getScarf(string memory color) public pure returns (string memory) {
        string memory scarf = string(
            abi.encodePacked(
             ' <g id="_2482263842112">   <path fill="',color,'" d="M465 450c1,11 6,17 1,41 -7,31 -23,59 -33,101 -7,31 -8,47 13,64 14,12 40,24 61,28 -5,-85 -1,-91 5,-181 1,-12 4,-28 4,-39 -39,-9 -33,-18 -51,-14z"/>   <path fill="',color,'" d="M597 462c4,17 9,35 13,52 8,33 13,75 18,110 2,19 1,40 3,60 14,-3 40,-27 49,-36 26,-28 -4,-104 -18,-133 -19,-38 -15,-25 -20,-61l-1 -4c0,-1 0,-1 0,-2 -9,-2 -21,10 -44,14z"/>  </g> '

            )
        );

        return scarf;
    }
}
