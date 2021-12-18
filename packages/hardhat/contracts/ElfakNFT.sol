// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { Base64 } from "./libraries/Base64.sol";
import "hardhat/console.sol";


contract ElfakNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' style='fill:";
  string afterColorSvg =  "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] words = ["StrukturePodataka", unicode"RačunarskeMreže", "NaprednoSoftversko", "Fizika", "Elektrotehnika", unicode"RačunarskaGrafika", "ParalelniSistemi", "DistribuiraniSistemi", "BazePodataka", unicode"SoftverskoInženjerstvo"];
  string[] emojis = [unicode"😁", unicode"😂", unicode"😍", unicode"😭", unicode"😴", unicode"😎", unicode"🤑", unicode"🤬", unicode"😱", unicode"🙄"];

  constructor() ERC721 ("ElfakNFT", "ELFAK") {
  }

  function pickRandomWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(block.timestamp, Strings.toString(tokenId))));
    rand = rand % words.length;
    return words[rand];
  }

  function pickRandomEmoji(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(block.timestamp, Strings.toString(tokenId))));
    rand = rand % emojis.length;
    return emojis[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function pickRandomColor() public view returns (string memory) {
      uint i = 0;
      uint randNum1 = uint(keccak256(abi.encodePacked(block.timestamp, Strings.toString(i++)))) % 256;
      uint randNum2 = uint(keccak256(abi.encodePacked(block.timestamp, Strings.toString(i++)))) % 256;
      uint randNum3 = uint(keccak256(abi.encodePacked(block.timestamp, Strings.toString(i)))) % 256;

      return string(abi.encodePacked("rgb(", Strings.toString(randNum1), ", ", Strings.toString(randNum2), ", ", Strings.toString(randNum3), ");"));
  }

  function makeAnNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory word = pickRandomWord(newItemId);
    string memory emoji = pickRandomEmoji(newItemId);
    string memory combinedWord = string(abi.encodePacked(word, emoji));
    string memory color = pickRandomColor();
    console.log("\n--------------------");
    console.log(color);
    console.log("--------------------\n");

    string memory finalSvg = string(abi.encodePacked(baseSvg, color, afterColorSvg, combinedWord, "</text></svg>"));
    
    console.log("\n--------------------");
    console.log(finalSvg);
    console.log("--------------------\n");

    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    combinedWord,
                    '", "description": "Specijalno generisani NFT-ovi za Elfak!", "image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
}