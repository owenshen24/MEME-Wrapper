// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

// TODO: make this a factory so all the memes can be wrapped

contract MemeWrapper is ERC721Burnable, Ownable {

  using SafeMath for uint256;

  IERC1155 meme;
  mapping (uint256 => bool) public isAllowed;
  mapping(uint256 => uint256) public originalId;
  uint256 public tokenId;

  constructor(address a) ERC721("Wrapped MEME Common Cards", "WMEME-CC") public {
    meme = IERC1155(a);
  }

  function redeem(uint256 id) external {
    require(ownerOf(id) == msg.sender, "Not owner of token");
    uint256 oldId = originalId[id];
    bytes memory b = new bytes(0);
    burn(id);
    meme.safeTransferFrom(address(this), msg.sender, oldId, 1, b);
    delete originalId[id];
  }

  function mint(uint256 id) external {
    require(isAllowed[id], "Now allowed");
    bytes memory b = new bytes(0);
    meme.safeTransferFrom(msg.sender, address(this),id, 1, b);
    tokenId = tokenId.add(1);
    originalId[tokenId] = id;
    _safeMint(msg.sender, tokenId);
  }

  function modifyAllowed(uint256 id, bool b) external onlyOwner {
    isAllowed[id] = b;
  }
}