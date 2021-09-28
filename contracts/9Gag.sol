// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @custom:unaudited This contract has not been audited. Use at your own risk.
contract NeinGag is Context, Ownable, ERC20 {
    // Give out 999,999,999 GAGs for every account
    uint256 public claimableAmount = 999999999 * (10**decimals());
    // claimedForSeason[season][address][claimed]
    mapping(address => bool) public claimedByAddress;

    constructor() Ownable() ERC20("9GAG", "GAG") {
    }

    /// @notice Claim Adventure Gold for a given Loot ID
    /// @param tokenId The tokenId of the Loot NFT
    function claimById(uint256 tokenId) external {
        // Follow the Checks-Effects-Interactions pattern to prevent reentrancy
        // attacks

        // Checks

        // Check that the msgSender owns the token that is being claimed
        require(
            _msgSender() == lootContract.ownerOf(tokenId),
            "MUST_OWN_TOKEN_ID"
        );

        // Further Checks, Effects, and Interactions are contained within the
        // _claim() function
        _claim(tokenId, _msgSender());
    }

    /// @notice Claim Adventure Gold for all tokens owned by the sender
    /// @notice This function will run out of gas if you have too much loot! If
    /// this is a concern, you should use claimRangeForOwner and claim Adventure
    /// Gold in batches.
    function claimAllForOwner() external {
        uint256 tokenBalanceOwner = lootContract.balanceOf(_msgSender());

        // Checks
        require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");

        // i < tokenBalanceOwner because tokenBalanceOwner is 1-indexed
        for (uint256 i = 0; i < tokenBalanceOwner; i++) {
            // Further Checks, Effects, and Interactions are contained within
            // the _claim() function
            _claim(
                lootContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @notice Claim Adventure Gold for all tokens owned by the sender within a
    /// given range
    /// @notice This function is useful if you own too much Loot to claim all at
    /// once or if you want to leave some Loot unclaimed. If you leave Loot
    /// unclaimed, however, you cannot claim it once the next season starts.
    function claimRangeForOwner(uint256 ownerIndexStart, uint256 ownerIndexEnd)
    external
    {
        uint256 tokenBalanceOwner = lootContract.balanceOf(_msgSender());

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
                lootContract.tokenOfOwnerByIndex(_msgSender(), i),
                _msgSender()
            );
        }
    }

    /// @dev Internal function to mint Loot upon claiming
    function _claim(uint256 tokenId, address tokenOwner) internal {
        // Checks
        // Check that the token ID is in range
        // We use >= and <= to here because all of the token IDs are 0-indexed
        require(
            tokenId >= tokenIdStart && tokenId <= tokenIdEnd,
            "TOKEN_ID_OUT_OF_RANGE"
        );

        // Check that Adventure Gold have not already been claimed this season
        // for a given tokenId
        require(
            !seasonClaimedByTokenId[season][tokenId],
            "GOLD_CLAIMED_FOR_TOKEN_ID"
        );

        // Effects

        // Mark that Adventure Gold has been claimed for this season for the
        // given tokenId
        seasonClaimedByTokenId[season][tokenId] = true;

        // Interactions

        // Send Adventure Gold to the owner of the token ID
        _mint(tokenOwner, adventureGoldPerTokenId);
    }

    /// @notice Allows the DAO to mint new tokens for use within the Loot
    /// Ecosystem
    /// @param amountDisplayValue The amount of Loot to mint. This should be
    /// input as the display value, not in raw decimals. If you want to mint
    /// 100 Loot, you should enter "100" rather than the value of 100 * 10^18.
    function daoMint(uint256 amountDisplayValue) external onlyOwner {
        _mint(owner(), amountDisplayValue * (10**decimals()));
    }

    /// @notice Allows the DAO to set a new contract address for Loot. This is
    /// relevant in the event that Loot migrates to a new contract.
    /// @param lootContractAddress_ The new contract address for Loot
    function daoSetLootContractAddress(address lootContractAddress_)
    external
    onlyOwner
    {
        lootContractAddress = lootContractAddress_;
        lootContract = IERC721Enumerable(lootContractAddress);
    }

    /// @notice Allows the DAO to set the token IDs that are eligible to claim
    /// Loot
    /// @param tokenIdStart_ The start of the eligible token range
    /// @param tokenIdEnd_ The end of the eligible token range
    /// @dev This is relevant in case a future Loot contract has a different
    /// total supply of Loot
    function daoSetTokenIdRange(uint256 tokenIdStart_, uint256 tokenIdEnd_)
    external
    onlyOwner
    {
        tokenIdStart = tokenIdStart_;
        tokenIdEnd = tokenIdEnd_;
    }

    /// @notice Allows the DAO to set a season for new Adventure Gold claims
    /// @param season_ The season to use for claiming Loot
    function daoSetSeason(uint256 season_) public onlyOwner {
        season = season_;
    }

    /// @notice Allows the DAO to set the amount of Adventure Gold that is
    /// claimed per token ID
    /// @param adventureGoldDisplayValue The amount of Loot a user can claim.
    /// This should be input as the display value, not in raw decimals. If you
    /// want to mint 100 Loot, you should enter "100" rather than the value of
    /// 100 * 10^18.
    function daoSetNeinGagPerTokenId(uint256 adventureGoldDisplayValue)
    public
    onlyOwner
    {
        adventureGoldPerTokenId = adventureGoldDisplayValue * (10**decimals());
    }

    /// @notice Allows the DAO to set the season and Adventure Gold per token ID
    /// in one transaction. This ensures that there is not a gap where a user
    /// can claim more Adventure Gold than others
    /// @param season_ The season to use for claiming loot
    /// @param adventureGoldDisplayValue The amount of Loot a user can claim.
    /// This should be input as the display value, not in raw decimals. If you
    /// want to mint 100 Loot, you should enter "100" rather than the value of
    /// 100 * 10^18.
    /// @dev We would save a tiny amount of gas by modifying the season and
    /// adventureGold variables directly. It is better practice for security,
    /// however, to avoid repeating code. This function is so rarely used that
    /// it's not worth moving these values into their own internal function to
    /// skip the gas used on the modifier check.
    function daoSetSeasonAndNeinGagPerTokenID(
        uint256 season_,
        uint256 adventureGoldDisplayValue
    ) external onlyOwner {
        daoSetSeason(season_);
        daoSetNeinGagPerTokenId(adventureGoldDisplayValue);
    }
}