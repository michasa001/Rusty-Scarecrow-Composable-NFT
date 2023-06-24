pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

import "./Libraries/HatLibrary.sol";
import "hardhat/console.sol";

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract Hat is ERC721Enumerable {
  using Strings for uint256;
  using Strings for uint160;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;

  address payable public constant recipient = payable(0xCA2951165B67Bce993c86b97D1a96bb1C4e3C326);

  uint256 public constant limit = 3000;
  uint256 price = 0.002 ether;

  mapping(uint256 => uint256) public crow_hat;

  //! Properties types
  string[3] public colors;

  constructor() ERC721("CrowHat", "CHT") {
    colors = ["#79097E", "#55305B", "#813300"];
  }

  function mintItem() public payable returns (uint256) {
    require(msg.value >= price, "NOT ENOUGH");
    require(_tokenIds.current() <= limit);

    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _mint(msg.sender, id);

    bytes32 predictableRandom = keccak256(abi.encodePacked(id, (block.number - 1), msg.sender, address(this)));
    crow_hat[id] = uint256((uint8(predictableRandom[8])) % 3);

    (bool success, ) = recipient.call{value: msg.value}("");
    require(success, "could not send");

    return id;
  }

  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {
    uint256 color = getPropertiesById(id);

    string memory render = string(abi.encodePacked(HatLibrary.getHat(colors[color])));

    return render;
  }

  // function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    string memory svg = string(
      abi.encodePacked(
        ' <svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="1084px" height="1084px" version="1.1" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd" viewBox="0 0 1084 1084" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs>    <clipPath id="id0"><path d="M538 383l-3 4 -13 6 -11 4c-3,0 -2,0 -5,1 -2,0 -4,1 -6,1l-8 -1 -9 -2 -5 -2 -4 -6 -4 -5 -2 -7 1 -3 2 -7 3 -5 4 2c0,1 2,2 3,2l4 3 5 2 5 2 7 2 4 2 8 2 5 2 6 1 6 1 7 1z"/>    </clipPath> </defs>',
        renderTokenById(id),
        "</svg>"
      )
    );
    return svg;
  }

  function getDescription(uint256 id) public view returns (string memory) {
    require(_exists(id), "!exist");
    uint256 hat = getPropertiesById(id);
    string memory desc = string(abi.encodePacked("Color: ", colors[hat]));
    return desc;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
    require(_exists(id), "!exist");

    uint256 hat = getPropertiesById(id);

    string memory name = string(abi.encodePacked("Scarecrow Hat #", id.toString()));

    string memory description = string(abi.encodePacked("Color: ", colors[hat]));
    string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                name,
                '","description":"',
                description,
                '","external_url":"https://yourCollectible.com/token/',
                id.toString(),
                '","attributes":[{"trait_type":"HatColor","value":"',
                colors[hat],
                '"}], "owner":"',
                (uint160(ownerOf(id))).toHexString(20),
                '","image": "',
                "data:image/svg+xml;base64,",
                image,
                '"}'
              )
            )
          )
        )
      );
  }

  function getPropertiesById(uint256 id) public view returns (uint256 hat) {
    hat = crow_hat[id];
  }
}
