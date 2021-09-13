// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @title Epoch Minutes for Epoch Day holders!
/// @author Will Papper <https://twitter.com/WillPapper>
/// @notice This contract mints Epoch Minutes for Epoch Day holders
/// @custom:unaudited This contract has not been audited. Use at your own risk.
contract EpochMinute is Context, Ownable, ERC20 {
    int constant EPOCH_DAYS_COUNT = 36525;
    // Loot contract is available at https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7
    address public epochDayContractAddress =
        0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;
    IERC721Enumerable public epochDayContract;

    // Give out 86,400 Epoch Minutes for every Epoch Day that a user holds
    uint256 public epochMinutesPerDay = 1440 * (10**decimals());

    // Track claimed tokens within a season
    // IMPORTANT: The format of the mapping is:
    // claimedForEpoch[epoch][tokenId][claimed]
    mapping(uint256 => mapping(uint256 => bool)) public epochClaimedByTokenId;

    constructor() Ownable() ERC20("Epoch Minute", "MIN") {
        // Transfer ownership to the Epoch DAO
        // Ownable by OpenZeppelin automatically sets owner to msg.sender, but
        // we're going to be using a separate wallet for deployment
        transferOwnership(0xcD814C83198C15A542F9A13FAf84D518d1744ED1);
        epochDayContract = IERC721Enumerable(lootContractAddress);
    }

    /// @notice Claim Epoch Minutes for a given Epoch Day ID
    /// @param tokenId The tokenId of the Epoch Day NFT
    function claimById(uint256 tokenId) external {
        // Follow the Checks-Effects-Interactions pattern to prevent reentrancy
        // attacks

        // Checks

        // Check that the msgSender owns the token that is being claimed
        require(
            _msgSender() == epochDayContract.ownerOf(tokenId),
            "MUST_OWN_TOKEN_ID"
        );

        // Further Checks, Effects, and Interactions are contained within the
        // _claim() function
        _claim(tokenId, _msgSender());
    }

    /// @notice Claim Epoch Minutes for all tokens owned by the sender
    /// @notice This function will run out of gas if you have too much Epoch Days! If
    /// this is a concern, you should use claimRangeForOwner and claim Epoch Minutes
    /// in batches.
    function claimAllForOwner() external {
        uint256 tokenBalanceOwner = epochDayContract.balanceOf(_msgSender());

        // Checks
        require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");

        // i < tokenBalanceOwner because tokenBalanceOwner is 1-indexed
        for (uint256 i = 0; i < tokenBalanceOwner; i++) {
            // Further Checks, Effects, and Interactions are contained within
            // the _claim() function
            _claim(
                epochDayContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @notice Claim Epoch Minutes for all tokens owned by the sender within a
    /// given range
    /// @notice This function is useful if you own too much Epoch Days to claim all at
    /// once or if you want to leave some Epoch Minutes unclaimed. If you leave Epoch Minutes
    /// unclaimed, however, you cannot claim it once the next epoch starts.
    function claimRangeForOwner(uint256 ownerIndexStart, uint256 ownerIndexEnd)
        external
    {
        uint256 tokenBalanceOwner = epochDayContract.balanceOf(_msgSender());

        // Checks
        require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");

        // We use < for ownerIndexEnd and tokenBalanceOwner because
        // tokenOfOwnerByIndex is 0-indexed while the token balance is 1-indexed
        require(
            ownerIndexStart >= 0 && ownerIndexEnd < tokenBalanceOwner,
            "INDEX_OUT_OF_RANGE"
        );

        // i <= ownerIndexEnd because ownerIndexEnd is 0-indexed
        for (uint256 i = ownerIndexStart; i <= ownerIndexEnd; i++) {
            // Further Checks, Effects, and Interactions are contained within
            // the _claim() function
            _claim(
                epochDayContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @dev Internal function to mint Epoch Minutes upon claiming
    function _claim(uint256 tokenId, address tokenOwner) internal {
        // Checks
        // Check that the token ID is in range
        // We use >= and <= to here because all of the token IDs are 0-indexed
        uint256 startingDayIndex = uint256(EPOCH_DAYS_COUNT) * uint256((epochDayContract.epochIndex - 1));
        uint256 endingDayIndex = uint256(EPOCH_DAYS_COUNT) * uint256(epochDayContract.epochIndex);
        require(
            tokenId >= startingDayIndex && tokenId <= endingDayIndex,
            "TOKEN_ID_OUT_OF_RANGE"
        );

        // Check that Epoch Minutes have not already been claimed this epoch
        // for a given tokenId
        require(
            !epochClaimedByTokenId[epochDayContract.epochIndex][tokenId],
            "SECONDS_CLAIMED_FOR_TOKEN_ID"
        );

        // Effects

        // Mark that Epoch Minutes has been claimed for this epoch for the
        // given tokenId
        epochClaimedByTokenId[epochDayContract.epochIndex][tokenId] = true;

        // Interactions

        // Send Epoch Minutes to the owner of the token ID
        _mint(tokenOwner, epochMinutesPerDay);
    }

    /// @notice Allows the DAO to set a new contract address for Epoch Day. This is
    /// relevant in the event that Epoch Day migrates to a new contract.
    /// @param lootContractAddress_ The new contract address for Epoch Day
    function daoSetLootContractAddress(address epochDayContractAddress_)
        external
        onlyOwner
    {
        epochDayContractAddress = epochDayContractAddress_;
        epochDayContract = IERC721Enumerable(epochDayContractAddress);
    }
}
