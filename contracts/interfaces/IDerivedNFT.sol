// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

/**
 * @title IDerivedNFT
 *
 * @notice This is the interface for the DerivedNFT contract. Which is cloned upon the first collect for any given
 * publication.
 */
interface IDerivedNFT {
    /**
     * @notice Initializes the collect NFT, setting the feed as the privileged minter, storing the collected publication pointer
     * and initializing the name and symbol in the LensNFTBase contract.
     *
     * @param profileId The token ID of the profile in the hub that this collectNFT points to.
     * @param pubId The profile publication ID in the hub that this collectNFT points to.
     * @param name The name to set for this NFT.
     * @param symbol The symbol to set for this NFT.
     */
    function initialize(
        uint256 profileId,
        uint256 pubId,
        uint256 baseRoyalty,
        string calldata name,
        string calldata symbol
    ) external;

    /**
     * @notice Mints a collect NFT to the specified address. This can only be called by the hub, and is called
     * upon collection.
     *
     * @param to The address to mint the NFT to.
     * @param royalty royalty of this token
     * @param tokenURI The Url of this token
     *
     * @return uint256 An interger representing the minted token ID.
     */
    function mint(
        address to,
        uint256 royalty,
        string memory tokenURI
    ) external returns (uint256);
}
