// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported.
// This means we'll have access to the interited contract's methods
contract PeloNFT is ERC721URIStorage {
    // Macic given to us by OpenZeppelin to help us keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width='100%' height='100%' fill='black' />";

    string[] lengths = ["5 min", "10 min", "15 min", "20 min", "30 min", "45 min"];
    string[] classTypes = ["Warm Up", "Full Body Strength", "Chest & Back Strength", "Glutes & Legs Strength", "Arms & Light Weights", "Pilates", "Barre", "Core Strength", "Bodyweight Strength", "Yoga Flow", "Meditation", "HIIT Cardio", "Stretching", "Breathwork", "Tabata Ride", "Power Zone Ride", "FTP Test Ride"];
    string[] instructors = ["Aditi Shah", "Adrian Williams", "Ally Love", "Chase Tucker", "Cody Rigsby","Emma Lovewell", "Denis Morton", "Hannah Frankson", "Jess Sims", "Jess King", "Kristin McGee", "Matt Wilpers", "Sam Yo", "Tunde Oyeneyin"];
    

    // MAGICAL EVENTS.
    event NewPeloNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721 ("PeloNFT", "PELO") {
        console.log("This is my NFT contract. Woah!");
    }

    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        return _tokenIds.current() + 1;
    }

    // I create a function to randomly pick a word from each array
    function pickRandomLength(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("length", Strings.toString(tokenId))));
        rand = rand % lengths.length;
        return lengths[rand];
    }

    function pickRandomClassType(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("classType", Strings.toString(tokenId))));
        rand = rand % classTypes.length;
        return classTypes[rand];
    }

    function pickRandomInstructor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("instructor", Strings.toString(tokenId))));
        rand = rand % instructors.length;
        return instructors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // A function our user will hit to get their NFT
    function makeAPeloNFT() public {
        require(getTotalNFTsMintedSoFar() < 50, "Max NFTs minted!");
        // Get the current tokenId, this starts at 0
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays
        string memory length = pickRandomLength(newItemId);
        string memory classType = pickRandomClassType(newItemId);
        string memory instructor = pickRandomInstructor(newItemId);
        
        string memory finalSvg = string(abi.encodePacked(baseSvg, "<text x='10' y='20' class='base'>", length, "</text>", "<text x='10' y='40' class='base'>", classType, "</text>", "<text x='10' y='60' class='base'>", instructor, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        abi.encodePacked("PeloNFT #", uint2str(newItemId)),
                        '", "description": "A collection of Peloton workouts.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
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
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        _tokenIds.increment();

        emit NewPeloNFTMinted(msg.sender, newItemId);
    }
}