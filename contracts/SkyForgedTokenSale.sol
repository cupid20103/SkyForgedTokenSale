// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SkyForgedTokenSale is Ownable, ReentrancyGuard {
    // The token being sold to buyers.
    address public tokenAddress;

    // Wallet that receives the USDC paid by buyers.
    address public feeWalletAddress;

    // USDC token used for payment (Base mainnet).
    address public usdcTokenAddress =
        0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    struct Stage {
        uint256 price; // Price per token, in USDC base units (6 decimals).
        uint256 available; // Tokens still available in this stage (18 decimals).
    }

    Stage[] public stages;

    uint256 public currentStage = 0;

    bool public salePaused;

    uint256 public saleStartDate = 1719241200; // June 25, 2024 at 00:00:00 UTC.

    // Tokens each buyer has purchased and can claim once the sale ends.
    mapping(address => uint256) public purchasedTokens;

    modifier saleStarted() {
        require(
            block.timestamp >= saleStartDate,
            "Token sale has not started yet"
        );
        _;
    }

    event Purchase(address indexed buyer, uint256 amount, uint256 value);

    event TokensClaimed(address indexed purchaser, uint256 amount);

    constructor(address _tokenAddress, address _feeWalletAddress) {
        tokenAddress = _tokenAddress;
        feeWalletAddress = _feeWalletAddress;

        stages.push(Stage(0.004 * 1e6, 6250000 * 10 ** 18)); // Stage 1
        stages.push(Stage(0.005 * 1e6, 10000000 * 10 ** 18)); // Stage 2
        stages.push(Stage(0.00666 * 1e6, 15000000 * 10 ** 18)); // Stage 3
        stages.push(Stage(0.008 * 1e6, 25000000 * 10 ** 18)); // Stage 4
        stages.push(Stage(0.01 * 1e6, 40000000 * 10 ** 18)); // Stage 5
        stages.push(Stage(0.01142 * 1e6, 70000000 * 10 ** 18)); // Stage 6
        stages.push(Stage(0.01333 * 1e6, 120000000 * 10 ** 18)); // Stage 7
        stages.push(Stage(0.016 * 1e6, 200000000 * 10 ** 18)); // Stage 8
        stages.push(Stage(0.02 * 1e6, 181250000 * 10 ** 18)); // Stage 9
    }

    function buyTokens(uint256 _tokenAmount) external saleStarted nonReentrant {
        require(!salePaused, "Token sale is paused");
        require(currentStage < stages.length, "Token sale is finished");
        require(_tokenAmount > 0, "Token amount must be greater than zero");

        Stage storage stage = stages[currentStage];

        require(
            stage.available >= _tokenAmount,
            "Token amount must be less than the available token amount at the current stage."
        );

        // Token amounts are denominated in 18 decimals while the price is in
        // USDC's 6 decimals, so divide by the token's 10 ** 18 to get the USDC cost.
        uint256 totalCost = (_tokenAmount * stage.price) / 10 ** 18;
        require(totalCost > 0, "Token amount too small");

        IERC20 usdcToken = IERC20(usdcTokenAddress);

        require(
            usdcToken.transferFrom(msg.sender, feeWalletAddress, totalCost),
            "USDC transfer failed"
        );

        stage.available -= _tokenAmount;
        purchasedTokens[msg.sender] += _tokenAmount;

        // Advance to the next stage once the current one sells out.
        if (stage.available == 0) {
            currentStage++;
        }

        emit Purchase(msg.sender, _tokenAmount, totalCost);
    }

    function pauseSale() external onlyOwner {
        salePaused = true;
    }

    function resumeSale() external onlyOwner {
        salePaused = false;
    }

    function setFeeWalletAddress(address _feeWalletAddress) external onlyOwner {
        require(
            _feeWalletAddress != address(0),
            "FeeWalletAddress cannot be the zero address"
        );

        feeWalletAddress = _feeWalletAddress;
    }

    // Withdraws any tokens left in the contract once the sale has finished.
    function withdrawUnsoldTokens(
        address _to,
        address _tokenAddress
    ) external onlyOwner saleStarted {
        require(
            currentStage == stages.length,
            "Token sale is not finished yet"
        );

        IERC20 token = IERC20(_tokenAddress);
        uint256 remainingTokens = token.balanceOf(address(this));

        require(remainingTokens > 0, "No tokens to withdraw");
        require(token.transfer(_to, remainingTokens), "Token transfer failed");
    }

    function claimTokens() external saleStarted nonReentrant {
        require(
            currentStage >= stages.length,
            "Token sale is not finished yet"
        );

        IERC20 token = IERC20(tokenAddress);

        uint256 balance = purchasedTokens[msg.sender];

        require(balance > 0, "No tokens to claim");

        // Zero the balance before transferring (checks-effects-interactions).
        purchasedTokens[msg.sender] = 0;

        require(token.transfer(msg.sender, balance), "Token claim failed");

        emit TokensClaimed(msg.sender, balance);
    }
}
