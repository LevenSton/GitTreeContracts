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
    bool private _initialized;
    uint256 internal _royaltyBasisPoints;

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
        string calldata name,
        string calldata symbol
    ) external override {
        if (_initialized) revert Errors.Initialized();
        _initialized = true;
        _royaltyBasisPoints = 1000; // 10% of royalties
        _profileId = profileId;
        _pubId = pubId;
        super._initialize(name, symbol);
        emit Events.CollectNFTInitialized(profileId, pubId, block.timestamp);
    }

    function mint(
        address to,
        string memory tokenURI
    ) external override returns (uint256) {
        if (msg.sender != GITTREEHUB) revert Errors.NotGitTreeHub();
        unchecked {
            uint256 newItemId = _tokenIds.current();
            _mint(to, newItemId);
            _setTokenURI(newItemId, tokenURI);

            _tokenIds.increment();
            return newItemId;
        }
    }

    // function getSourcePublicationPointer()
    //     external
    //     view
    //     override
    //     returns (uint256, uint256)
    // {
    //     return (_profileId, _pubId);
    // }
    // function tokenURI(
    //     uint256 tokenId
    // ) public view override returns (string memory) {
    //     if (!_exists(tokenId)) revert Errors.TokenDoesNotExist();
    //     return ILensHub(HUB).getContentURI(_profileId, _pubId);
    // }
    // /**
    //  * @notice Changes the royalty percentage for secondary sales. Can only be called publication's
    //  *         profile owner.
    //  *
    //  * @param royaltyBasisPoints The royalty percentage meassured in basis points. Each basis point
    //  *                           represents 0.01%.
    //  */
    // function setRoyalty(uint256 royaltyBasisPoints) external {
    //     if (IERC721(HUB).ownerOf(_profileId) == msg.sender) {
    //         if (royaltyBasisPoints > BASIS_POINTS) {
    //             revert Errors.InvalidParameter();
    //         } else {
    //             _royaltyBasisPoints = royaltyBasisPoints;
    //         }
    //     } else {
    //         revert Errors.NotProfileOwner();
    //     }
    // }
    // /**
    //  * @notice Called with the sale price to determine how much royalty
    //  *         is owed and to whom.
    //  *
    //  * @param tokenId The token ID of the NFT queried for royalty information.
    //  * @param salePrice The sale price of the NFT specified.
    //  * @return A tuple with the address who should receive the royalties and the royalty
    //  * payment amount for the given sale price.
    //  */
    // function royaltyInfo(
    //     uint256 tokenId,
    //     uint256 salePrice
    // ) external view returns (address, uint256) {
    //     return (
    //         IERC721(HUB).ownerOf(_profileId),
    //         (salePrice * _royaltyBasisPoints) / BASIS_POINTS
    //     );
    // }
    // /**
    //  * @dev See {IERC165-supportsInterface}.
    //  */
    // // function supportsInterface(
    // //     bytes4 interfaceId
    // // ) public view virtual override(ERC721Enumerable) returns (bool) {
    // //     return
    // //         interfaceId == INTERFACE_ID_ERC2981 ||
    // //         super.supportsInterface(interfaceId);
    // // }
    // /**
    //  * @dev Upon transfers, we emit the transfer event in the hub.
    //  */
    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) internal override {
    //     super._beforeTokenTransfer(from, to, tokenId);
    //     ILensHub(HUB).emitCollectNFTTransferEvent(
    //         _profileId,
    //         _pubId,
    //         tokenId,
    //         from,
    //         to
    //     );
    // }
}
