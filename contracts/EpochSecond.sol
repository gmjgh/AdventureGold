// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @title Seconds for Loot holders!
/// @author Will Papper <https://twitter.com/WillPapper>
/// @notice This contract mints Seconds for Loot holders and provides
/// administrative functions to the Loot DAO. It allows:
/// * Loot holders to claim Seconds
/// * A DAO to set seasons for new opportunities to claim Seconds
/// * A DAO to mint Seconds for use within the Loot ecosystem
/// @custom:unaudited This contract has not been audited. Use at your own risk.
contract EpochSecond is Context, Ownable, ERC20 {
    // Loot contract is available at https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7
    address public epochDayContractAddress =
        0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;
    IERC721Enumerable public epochDayContract;

    // Give out 86,400 Epoch Seconds for every Epoch Day that a user holds
    uint256 public epochSecondsPerDay = 86400 * (10**decimals());

    // tokenIdStart of 0 is based on the following lines in the EpochDay contract(OWNER_FAVOURITE_NUMBER = 16):
    /** 
    function claim(uint256 tokenId) public nonReentrant {
        int trailingNumber = int(tokenId & chunksCount);
        require(tokenId >= 0 && trailingNumber != OWNER_FAVOURITE_NUMBER && tokenId < claimableLimit, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }
    */
    uint256 public tokenIdStart = 0;

    // tokenIdEnd of 8000 is based on the following lines in the Loot contract:
    /**
        function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 7777 && tokenId < 8001, "Token ID invalid");
        _safeMint(owner(), tokenId);
    }
    */
    uint256 public tokenIdEnd = 36525;

    // Epochs are used to allow users to claim tokens regularly. Possibility be other epochs is
    // decided by the DAO.
    uint256 public epoch = 1;

    // Track claimed tokens within a season
    // IMPORTANT: The format of the mapping is:
    // claimedForEpoch[epoch][tokenId][claimed]
    mapping(uint256 => mapping(uint256 => bool)) public epochClaimedByTokenId;

    constructor() Ownable() ERC20("EpochSecond", "SEC") {
        // Transfer ownership to the Epoch DAO
        // Ownable by OpenZeppelin automatically sets owner to msg.sender, but
        // we're going to be using a separate wallet for deployment
        transferOwnership(0xcD814C83198C15A542F9A13FAf84D518d1744ED1);
        epochDayContract = IERC721Enumerable(lootContractAddress);
    }

    /// @notice Claim Seconds for a given Loot ID
    /// @param tokenId The tokenId of the Loot NFT
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

    /// @notice Claim Seconds for all tokens owned by the sender
    /// @notice This function will run out of gas if you have too much loot! If
    /// this is a concern, you should use claimRangeForOwner and claim Adventure
    /// Gold in batches.
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

    /// @notice Claim Epoch Seconds for all tokens owned by the sender within a
    /// given range
    /// @notice This function is useful if you own too much Epoch Days to claim all at
    /// once or if you want to leave some Epoch Seconds unclaimed. If you leave Epoch Seconds
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

    /// @dev Internal function to mint Epoch Seconds upon claiming
    function _claim(uint256 tokenId, address tokenOwner) internal {
        // Checks
        // Check that the token ID is in range
        // We use >= and <= to here because all of the token IDs are 0-indexed
        require(
            tokenId >= tokenIdStart && tokenId <= tokenIdEnd,
            "TOKEN_ID_OUT_OF_RANGE"
        );

        // Check that Seconds have not already been claimed this season
        // for a given tokenId
        require(
            !seasonClaimedByTokenId[season][tokenId],
            "GOLD_CLAIMED_FOR_TOKEN_ID"
        );

        // Effects

        // Mark that Seconds has been claimed for this season for the
        // given tokenId
        seasonClaimedByTokenId[season][tokenId] = true;

        // Interactions

        // Send Seconds to the owner of the token ID
        _mint(tokenOwner, epochSecondsPerDay);
    }

    /// @notice Allows the DAO to mint new tokens for use within the Epoch
    /// Ecosystem
    /// @param amountDisplayValue The amount of Seconds to mint. This should be
    /// input as the display value, not in raw decimals. If you want to mint
    /// 100 Loot, you should enter "100" rather than the value of 100 * 10^18.
    function daoMint(uint256 amountDisplayValue) external onlyOwner {
        _mint(owner(), amountDisplayValue * (10**decimals()));
    }

    /// @notice Allows the DAO to set a new contract address for Loot. This is
    /// relevant in the event that Loot migrates to a new contract.
    /// @param lootContractAddress_ The new contract address for Loot
    function daoSetLootContractAddress(address epochDayContractAddress_)
        external
        onlyOwner
    {
        epochDayContractAddress = epochDayContractAddress_;
        epochDayContract = IERC721Enumerable(epochDayContractAddress);
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

    /// @notice Allows the DAO to set a season for new Seconds claims
    /// @param season_ The season to use for claiming Loot
    function daoSetEpoch(uint256 epoch_) public onlyOwner {
        epoch = epoch_;
    }
}
