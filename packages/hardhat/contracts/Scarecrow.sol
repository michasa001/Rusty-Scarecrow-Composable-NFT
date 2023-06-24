pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Libraries/ScarecrowLibrary.sol";
import "./Libraries/NFTContract.sol";
import "./Libraries/ToUint256.sol";
import "./Libraries/TokenUriLibrary.sol";
import "./Libraries/RandomNumber.sol";

contract Scarecrow is ERC721Enumerable, IERC721Receiver {
  struct upgradeIds {
    uint256 hatId;
    uint256 scarfId;
  }

  struct NftContracts {
    address hatContract;
    address scarfContract;
  }

  uint256 _tokenIds;

  mapping(address => mapping(uint256 => uint256)) nftById;
  mapping(uint256 => mapping(uint8 => uint8)) crowColors;
  mapping(uint256 => uint256) mintTime;

  mapping(uint8 => NftContracts) nftContracts;

  address payable constant recipient = payable(0xCA2951165B67Bce993c86b97D1a96bb1C4e3C326);

  uint256 public constant limit = 2000;
  uint256 public price = 0.005 ether;

  mapping(uint256 => upgradeIds) public crowUpgrades;
  string[11] colors;

  constructor(address _hat, address _scarf) ERC721("Scarecrow", "SCW") {
    nftContracts[0].hatContract = _hat;
    nftContracts[0].scarfContract = _scarf;

    colors = [
      "#EB4545",
      "#FDA2F4",
      "#FF8A01",
      "#DABCA4",
      "#FD7C0A",
      "#70AE3F",
      "#98C1FF",
      "#3E3BD3",
      "#CF81FF",
      "#D9D9D9",
      "#FFFFFF"
    ];
  }

  function mintItem() public payable returns (uint256) {
    if (msg.value < price) revert();
    if (_tokenIds >= limit) revert();

    _tokenIds += 1;

    uint256 id = _tokenIds;
    _mint(msg.sender, id);

    crowColors[id][0] = RandomNumber.genertaeRandomNumber(id, 1);
    crowColors[id][1] = RandomNumber.genertaeRandomNumber(id, 2);
    crowColors[id][2] = RandomNumber.genertaeRandomNumber(id, 3);
    crowColors[id][3] = RandomNumber.genertaeRandomNumber(id, 4);
    mintTime[id] = block.timestamp;

    (bool success, ) = recipient.call{value: msg.value}("");
    require(success, "could not send");

    return id;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
    if (!_exists(id)) revert();
    return TokenUriLibrary._tokenUri(id, getDescription(id), ownerOf(id), generateSVGofTokenById(id));
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          ' <svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="1084px" height="1084px" version="1.1" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd" viewBox="0 0 1084 1084" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs>    <clipPath id="id0"><path d="M538 383l-3 4 -13 6 -11 4c-3,0 -2,0 -5,1 -2,0 -4,1 -6,1l-8 -1 -9 -2 -5 -2 -4 -6 -4 -5 -2 -7 1 -3 2 -7 3 -5 4 2c0,1 2,2 3,2l4 3 5 2 5 2 7 2 4 2 8 2 5 2 6 1 6 1 7 1z"/>    </clipPath> </defs>',
          renderTokenById(id),
          "</svg>"
        )
      );
  }

  function getDescription(uint256 id) public view returns (string memory) {
    string memory desc = "Scarecrow";

    uint256 hatId = crowUpgrades[id].hatId;
    uint256 scarfId = crowUpgrades[id].scarfId;

    if (hatId > 0 && scarfId > 0) {
      desc = "Scarecrow with a hat and scarf";
    } else if (hatId > 0 && scarfId == 0) {
      desc = "Scarecrow with  a hat";
    } else if (hatId == 0 && scarfId > 0) {
      desc = "Scarecrow with  a scarf";
    }

    return string(abi.encodePacked(desc));
  }

  function renderTokenById(uint256 id) public view returns (string memory) {
    string memory render = string(
      abi.encodePacked(
        ScarecrowLibrary.getScarecrow(colors[crowColors[id][0]], colors[crowColors[id][1]], mintTime[id])
      )
    );

    uint256 hatId = crowUpgrades[id].hatId;
    uint256 scarfId = crowUpgrades[id].scarfId;

    if (hatId > 0) {
      render = string(abi.encodePacked(render, NFTContract(nftContracts[0].hatContract).renderTokenById(hatId)));
    }

    if (scarfId > 0) {
      render = string(abi.encodePacked(render, NFTContract(nftContracts[0].scarfContract).renderTokenById(scarfId)));
    }

    return render;
  }

  function removeNftFromCrow(address nft, uint256 id) external {
    if (msg.sender != ownerOf(id)) revert();

    if ((nftById[nft][id] == 0)) revert();

    _removeNftFromCrow(nft, id);
  }

  function _removeNftFromCrow(address nftContract, uint256 id) internal {
    if (nftContract == nftContracts[0].hatContract) {
      crowUpgrades[id].hatId = 0;
    }
    if (nftContract == nftContracts[0].scarfContract) {
      crowUpgrades[id].scarfId = 0;
    }

    NFTContract(nftContract).transferFrom(address(this), ownerOf(id), nftById[address(nftContract)][id]);

    nftById[address(nftContract)][id] = 0;
  }

  function onERC721Received(
    address /*operator*/,
    address from,
    uint256 tokenId,
    bytes calldata fancyIdData
  ) external override returns (bytes4) {
    uint256 fancyId = ToUint256._toUint256(fancyIdData);

    if (ownerOf(fancyId) != from) revert();

    if (nftById[msg.sender][fancyId] != 0) revert();

    nftById[msg.sender][fancyId] = tokenId;

    if (msg.sender == nftContracts[0].hatContract) {
      crowUpgrades[fancyId].hatId = tokenId;
    }
    if (msg.sender == nftContracts[0].scarfContract) {
      crowUpgrades[fancyId].scarfId = tokenId;
    }

    return this.onERC721Received.selector;
  }
}
