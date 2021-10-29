// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
    _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
    _balances[sender] = senderBalance - amount;
    }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
    _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
    _approve(account, _msgSender(), currentAllowance - amount);
    }
        _burn(account, amount);
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/// @custom:unaudited This contract has not been audited. Use at your own risk.
contract ImperialThroneGelt is Ownable, ERC20Burnable {
    // Give out 40,000,000,000 Thrones for the expanded exchange
    uint256 constant DEFAULT_EXPANSION_LIMIT = 40000000000;
    uint256 constant DEFAULT_MAX_AMOUNT = 4000000000;
    // Give out 4,000,000,000 Thrones for the complete airdrop
    uint256 public airdropAmount = _withDecimals(DEFAULT_MAX_AMOUNT);

    // Give out 10 Thrones for mine event
    uint256 private _ratlingClaimableAmount = _withDecimals(10);
    uint256 public ratlingsToClaim = 1000;

    // Give out 40,000 Thrones for mine event
    uint256 private _commonerClaimableAmount = _withDecimals(40000);
    uint256 public commonersToClaim = 40000;

    // Give out 66,666 Thrones for mine event
    uint256 private _guardClaimableAmount = _withDecimals(66666);
    uint256 public guardsToClaim = 15000;

    // Give out 400,000 Thrones for mine event
    uint256 private _astartesClaimableAmount = airdropAmount / 10000;
    uint256 public astartesToClaim = 1000;

    // Give out 40,000,000 Thrones for mine event
    uint256 private _primarchsClaimableAmount = airdropAmount / 100;
    uint256 private _primarchsToClaim = 20;
    uint256 private _primarchsToDiscover = 20;

    // Give out 160,000,000 Thrones for mine event
    uint256 private _emperorClaimableAmount = airdropAmount / 25;

    bool public hasExpansionStarted = false;
    uint256 public expansionRate = 3;
    uint256 public expansionLimit = _withDecimals(DEFAULT_EXPANSION_LIMIT);

    address public emperorAddress;
    mapping(address => uint256) public primarchsDiscovered;
    address[20] public primarchsClaimed;

    mapping(address => uint256) public airdropClaimed;
    address[] public airdropClaimedAddresses;

    mapping(address => uint256) public xenosAssimilated;
    address[] public xenosAssimilatedAddresses;

    constructor() Ownable() ERC20("Imperium Throne Gelt", "THRN") {
        emperorAddress = _msgSender();
        airdropClaimed[_msgSender()] = _emperorClaimableAmount;
        airdropClaimedAddresses.push(_msgSender());
        _mint(_msgSender(), airdropClaimed[_msgSender()]);
    }

    /// @notice Claim Imperium Throne Gelts
    /// first 1,000 accounts will receive 400,000
    /// next 15,000 accounts will receive 66,666
    /// next 40,000 accounts will receive 40,000
    /// last 1,000 accounts will receive 10
    function claim() external {
        require(airdropClaimed[_msgSender()] == 0, "You have already claimed");
        require(ratlingsToClaim > 0, "Airdrop has ended");
        uint256 amount = 0;
        if (primarchsDiscovered[_msgSender()] != 0 && _primarchsToClaim > 0) {
            _primarchsToClaim -= 1;
            primarchsClaimed[primarchsDiscovered[_msgSender()] - 1] = _msgSender();
            amount = primarchsDiscovered[_msgSender()] == 20 ? _primarchsClaimableAmount * 2 : _primarchsClaimableAmount;
        } else if (astartesToClaim > 0) {
            astartesToClaim -= 1;
            amount = _astartesClaimableAmount;
        } else if (guardsToClaim > 0) {
            guardsToClaim -= 1;
            amount = _guardClaimableAmount;
        } else if (commonersToClaim > 0) {
            commonersToClaim -= 1;
            amount = _commonerClaimableAmount;
        } else if (ratlingsToClaim > 0) {
            ratlingsToClaim -= 1;
            amount = _ratlingClaimableAmount;
        }
        airdropClaimed[_msgSender()] = amount;
        airdropClaimedAddresses.push(_msgSender());
        _mint(_msgSender(), airdropClaimed[_msgSender()]);
    }

    /// @notice Claim from 40,000 to 400,000 of Imperium Throne Gelts.
    /// To do that you need to burn amount of custom BEP20Burnable token based on expansionRate
    /// BEP20Burnable token should be with 18 decimals
    /// up to 25 percent of claimed amount will be granted to the Emperor and primarchs(if they all are discovered)
    /// @param assimilationAmountAbsolute Assimilation amount without decimals, if 0 - defaults to 40,000
    function conquerXenosToken(address xenosTokenAddress, uint256 assimilationAmountAbsolute) external {
        require(xenosTokenAddress != address(0), "Cannot conquer 0 address");
        require(hasExpansionStarted && ratlingsToClaim == 0, "Expansion is not active");

        uint256 assimilationAmount = _withDecimals(assimilationAmountAbsolute);
        ERC20Burnable xenosToken = ERC20Burnable(xenosTokenAddress);
        (uint256 min, uint256 max) = _calcAssimilationBounds(xenosToken);

        require(assimilationAmount >= min && assimilationAmount <= max, "Incorrect assimilation amount");

        uint256 anticipatedAmount = airdropAmount * assimilationAmount / _calcXenosTokenSupply(xenosToken) / expansionRate;

        require((totalSupply() + anticipatedAmount) <= (airdropAmount + expansionLimit), "Assimilation amount is too hight");

        uint256 emperorShare = anticipatedAmount / 25;
        uint256 primarchShare = anticipatedAmount / 100;

        uint256 balanceOfToken = ERC20(xenosTokenAddress).balanceOf(_msgSender());
        require(balanceOfToken >= assimilationAmount, "Insufficient funds");

        xenosToken.burnFrom(_msgSender(), assimilationAmount);
        if (xenosAssimilated[xenosTokenAddress] == 0){
            xenosAssimilatedAddresses.push(xenosTokenAddress);
        }
        xenosAssimilated[xenosTokenAddress] = xenosAssimilated[xenosTokenAddress] + assimilationAmount;

        _mint(emperorAddress, emperorShare);

        uint256 sharedPortion = 4;
        for (uint256 i = 0; i < primarchsClaimed.length; i++) {
            if (primarchsClaimed[i] != address(0)) {
                sharedPortion += i == 19 ? 2 : 1;
                _mint(
                    primarchsClaimed[i],
                    i == 19 ? primarchShare * 2 : primarchShare
                );
            }
        }

        uint256 amountToMint = anticipatedAmount - sharedPortion * primarchShare;
        _mint(_msgSender(), amountToMint);
    }

    /// @notice Calculates assimilationAmountAbsolute bounds without decimals to be used in conquerXenosToken method
    /// @param xenosTokenAddress BEP20Burnable token address. BEP20Burnable should be with 18 decimals
    function calculateXenosTokenAssimilationBounds(address xenosTokenAddress) external view returns (uint256 min, uint256 max) {
        require(xenosTokenAddress != address(0), "Cannot assimilate from 0 address");
        ERC20 xenosToken = ERC20(xenosTokenAddress);
        (uint256 minimum, uint256 maximum) = _calcAssimilationBounds(xenosToken);
        min = _withoutDecimals(minimum);
        max = _withoutDecimals(maximum);
    }

    /// @notice Emperor rediscovers primarchs via this function and assigns him to the legion
    function discoverPrimarch(address primarchAddress, uint256 legionNumber) external onlyOwner {
        require(primarchAddress != address(0), "Zero address cannot be primarch");
        require(legionNumber > 0 && legionNumber <= 20, "There are exactly 20 legions");
        require(_primarchsToDiscover > 0, "There are only 20 primarchs");
        require(primarchsDiscovered[primarchAddress] == 0, "This primarch is already discovered");

        _primarchsToDiscover -= 1;
        primarchsDiscovered[primarchAddress] = legionNumber;
    }

    /// @notice Emperor starts the expansion
    function startExpansion() external onlyOwner {
        hasExpansionStarted = true;
    }

    /// @notice Emperor stops the expansion
    function stopExpansion() external onlyOwner {
        hasExpansionStarted = false;
    }

    /// @notice Emperor starts the expansion
    function changeExpansionRate(uint256 newExpansionRate) external onlyOwner {
        require(newExpansionRate > 0 && newExpansionRate <= 1000, "Incorrect expansion rate");
        expansionRate = newExpansionRate;
    }

    /// @notice Emperor limits the expansion
    /// @param newLimit New expansion limit without decimals, if 0 - defaults to 40,000,000,000
    function limitExpansion(uint256 newLimit) external onlyOwner {
        require(newLimit >= DEFAULT_MAX_AMOUNT && newLimit <= DEFAULT_EXPANSION_LIMIT, "Incorrect expansion limit");
        expansionLimit = _withDecimals((newLimit == 0 ? DEFAULT_EXPANSION_LIMIT : newLimit));
    }

    /// @dev Internal function to calculate Xenos Token Assimilation Bounds
    function _calcAssimilationBounds(ERC20 xenosToken) private view returns (uint256 min, uint256 max) {
        require(xenosToken.decimals() == decimals(), "Incorrect token total supply");
        uint256 xenosTokenSupply = _calcXenosTokenSupply(xenosToken);
        min = _commonerClaimableAmount * xenosTokenSupply / airdropAmount * expansionRate;
        max = _astartesClaimableAmount * xenosTokenSupply / airdropAmount * expansionRate;
    }

    /// @dev Internal function that provides decimals for value
    function _withDecimals(uint256 value) private view returns (uint256) {
        return value * (10**decimals());
    }

    /// @dev Internal function that provides value without decomals
    function _withoutDecimals(uint256 value) private view returns (uint256) {
        return value / (10**decimals());
    }

    /// @dev Internal function that provides value without decomals
    function _calcXenosTokenSupply(ERC20 xenosToken) private view returns (uint256) {
        return xenosToken.totalSupply() < airdropAmount ? airdropAmount : xenosToken.totalSupply();
    }

}

