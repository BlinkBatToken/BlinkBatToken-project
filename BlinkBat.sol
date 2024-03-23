// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlinkBat is ERC20, ERC20Burnable, ReentrancyGuard, Ownable {
    uint256 public constant TOTAL_SUPPLY = 66e9 * 1e18; // 66 billion tokens, assuming 18 decimal places
    address public liquidityWallet;
    address public cexWallet;
    address public teamWallet;
    address public marketingWallet;
    address public frozenWallet;

    uint256 public freezeUntil;
    uint256 public frozenAmount;

    bool public mintingFinished = false; 

    constructor() ERC20("BlinkBat", "BBT") Ownable(msg.sender) {
    _mint(msg.sender, TOTAL_SUPPLY);
    freezeUntil = block.timestamp + 365 days;
    frozenAmount = (TOTAL_SUPPLY * 7) / 100;
}


    function distributeInitialTokens(
        address _liquidityWallet,
        address _cexWallet,
        address _teamWallet,
        address _marketingWallet,
        address _frozenWallet 
    ) public onlyOwner {
        require(liquidityWallet == address(0), "Already distributed");
        liquidityWallet = _liquidityWallet;
        cexWallet = _cexWallet;
        teamWallet = _teamWallet;
        marketingWallet = _marketingWallet;
        frozenWallet = _frozenWallet;

        uint256 liquiditySupply = (TOTAL_SUPPLY * 30) / 100;
        uint256 cexSupply = (TOTAL_SUPPLY * 50) / 100;
        uint256 teamSupply = (TOTAL_SUPPLY * 3) / 100;
        uint256 marketingSupply = (TOTAL_SUPPLY * 10) / 100;

        _transfer(msg.sender, frozenWallet, frozenAmount);
        _transfer(msg.sender, liquidityWallet, liquiditySupply);
        _transfer(msg.sender, cexWallet, cexSupply);
        _transfer(msg.sender, teamWallet, teamSupply);
        _transfer(msg.sender, marketingWallet, marketingSupply);
    }

    function _beforeTokenTransfer(address , address, uint256 amount) internal view {
        if (msg.sender == frozenWallet && block.timestamp < freezeUntil) {
            require(balanceOf(frozenWallet) - amount >= frozenAmount, "BlinkBat: transfer of frozen tokens is restricted");
        }
    }   

    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
        require(!mintingFinished, "Minting is finished");
        _mint(to, amount);
        return true;
    }

    function finishMinting() public onlyOwner {
        mintingFinished = true;
    }

    function renounceOwnership() public override onlyOwner {
        mintingFinished = true;
        super.renounceOwnership();
    }
    function safeTransfer(address to, uint256 amount) public nonReentrant {
        _transfer(msg.sender, to, amount);
    }
    function burn(uint256 amount) public override {
    super.burn(amount);
}
    function burnFrom(address account, uint256 amount) public override {
    super.burnFrom(account, amount);
}
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
}

