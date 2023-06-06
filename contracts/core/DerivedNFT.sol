// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {IDerivedNFT} from "../interfaces/IDerivedNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IGitTree} from "../interfaces/IGitTree.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {DerivedNFTBase} from "./nftmodule/DerivedNFTBase.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title DerivedNFT
 *
 * @notice This is the NFT contract that is minted upon collecting a given publication. It is cloned upon
 * the first collect for a given publication, and the token URI points to the original publication's contentURI.
 */
contract DerivedNFT is DerivedNFTBase, IDerivedNFT {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public immutable GITTREEHUB;
    uint256 internal _profileId;
    uint256 internal _pubId;
    uint256 internal _tokenIdCounter;
    uint256 internal _baseRoyaltyForCollectionOwner;
    bool private _initialized;
    bool public _bLinkLens;

    // bytes4(keccak256('royaltyInfo(uint256,uint256)')) == 0x2a55205a
    bytes4 internal constant INTERFACE_ID_ERC2981 = 0x2a55205a;
    uint16 internal constant BASIS_POINTS = 10000;

    // // We create the CollectNFT with the pre-computed HUB address before deploying the hub proxy in order
    // // to initialize the hub proxy at construction.
    constructor(address gitTreeHub) {
        if (gitTreeHub == address(0)) revert Errors.InitParamsInvalid();
        GITTREEHUB = gitTreeHub;
        _initialized = true;
    }

    function initialize(
        uint256 profileId,
        uint256 pubId,
        uint256 baseRoyalty,
        string calldata name,
        string calldata symbol
    ) external override {
        if (_initialized) revert Errors.Initialized();
        _initialized = true;
        if (profileId > 0) _bLinkLens = true;
        _baseRoyaltyForCollectionOwner = baseRoyalty;
        _profileId = profileId;
        _pubId = pubId;
        super._initialize(name, symbol);
        emit Events.CollectNFTInitialized(profileId, pubId, block.timestamp);
    }

    function mint(
        address to,
        uint256 royalty,
        string memory tokenURI
    ) external override returns (uint256) {
        if (msg.sender != GITTREEHUB) revert Errors.NotGitTreeHub();
        unchecked {
            uint256 newItemId = _tokenIds.current();
            _mint(to, newItemId);
            _setTokenInfo(newItemId, tokenURI, royalty, to);

            _tokenIds.increment();
            return newItemId;
        }
    }

    /**
     * @notice Called with the sale price to determine how much royalty
     *         is owed and to whom.
     *
     * @param tokenId The token ID of the NFT queried for royalty information.
     * @param salePrice The sale price of the NFT specified.
     * @return A tuple with the address who should receive the royalties and the royalty
     * payment amount for the given sale price.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address, uint256, address, uint256) {
        return (
            IERC721(GITTREEHUB).ownerOf(_profileId),
            (salePrice * _baseRoyaltyForCollectionOwner) / BASIS_POINTS,
            _getTokenCreator(tokenId),
            (salePrice * _getTokenRoyalty(tokenId)) / BASIS_POINTS
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == INTERFACE_ID_ERC2981 ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Upon transfers, we emit the transfer event in the hub.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
