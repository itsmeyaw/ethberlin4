// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./IProveChecker.sol";
import {HCaptchaProveChecker} from "./HCaptchaProveChecker.sol";

contract Report is ERC721 {
    uint256 private _nextTokenId = 0;
    IProveChecker private _proofChecker;

    // Storage for report data
    struct ReportData {
        string title;
        string description;
        string proofOfHumanWork;
        uint16 upVote;
        uint16 downVote;
    }

    mapping(uint256 => ReportData) private _reportData;

    constructor(address proofChecker) ERC721("Report", "RPT") {
        _proofChecker = IProveChecker(proofChecker);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        // Soulbound logic: Only allow minting (to address != address(0) and auth == address(0))
        require(
            to != address(0) && auth == address(0),
            "This token is soulbound and cannot be transferred."
        );

        // Call the base _update function after our custom logic
        return super._update(to, tokenId, auth); // Return the value from the base function
    }

    function createReport(
        string memory title,
        string memory description,
        string memory proof
    ) public returns (uint256) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(
            bytes(description).length > 20,
            "Description must be at least 20 characters long"
        );
        bool checkProof = _proofChecker.checkProof(msg.sender, proof);
        require(checkProof, "Proof does not exists on chain yet");

        uint256 tokenId = _nextTokenId++;

        // Use _safeMint for better safety
        _safeMint(msg.sender, tokenId);

        // Store the title and description
        _reportData[tokenId] = ReportData(title, description, proof, 0, 0);

        return tokenId;
    }

    function test() public returns (string memory) {
        return "This is a string";
    }

    function getTitle(
        uint256 reportId
    ) public view returns (string memory) {
        require(
            _ownerOf(reportId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        ); // Check if token exists
        return _reportData[reportId].title;
    }

    // Additional helper function to get description
    function getDescription(
        uint256 reportId
    ) public view returns (string memory) {
        require(
            _ownerOf(reportId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _reportData[reportId].description;
    }

    function getReports(
        uint8 amount,
        uint8 skip
    ) public view returns (ReportData[] memory, uint256[] memory) {
        uint256 totalSupply = _nextTokenId;

        // Search for start and end index and ensure both are not negative
        uint256 startIndex = totalSupply > skip ? totalSupply - 1 - skip : 0;
        uint256 endIndex = startIndex >= amount ? startIndex - amount : 0;

        ReportData[] memory reports = new ReportData[](
            startIndex - endIndex + 1
        ); // +1 to include startIndex
        uint256[] memory tokenIds = new uint256[](startIndex - endIndex + 1);
        uint256 counter = 0;

        for (uint256 i = startIndex; i >= endIndex;) {
            if (_ownerOf(i) != address(0)) {
                // Ensure the token exists before adding to the result
                reports[counter] = _reportData[i];
                tokenIds[counter] = i;
                counter++;
            }
            if (i > 0) {
                i--;
            } else {
                break;
            }
        }

        return (reports, tokenIds);
    }

    function upVote(uint256 reportId) public {
        _reportData[reportId].upVote = _reportData[reportId].upVote + 1;
    }

    function downVote(uint256 reportId) public {
        _reportData[reportId].downVote = _reportData[reportId].downVote + 1;
    }
}
