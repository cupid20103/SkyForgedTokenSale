// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SkyForgedTokenSale is Ownable, ReentrancyGuard {
    // Address of the token being sold
    address public tokenAddress;

    // Address of the owner to collect USDC
    address public feeWalletAddress;

    // Address of the USDC token
    address public usdcTokenAddress =
        0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    // Price and availability for each stage
    struct Stage {
        uint256 price; // Price of each token in USDC
        uint256 available; // Total tokens available in this stage
    }

    // Array to store each stage's details
    Stage[] public stages;

    // Index of the current stage
    uint256 public currentStage = 0;

    // Flag to indicate if token sale is paused
    bool public salePaused;

    // Start date for the token sale
    uint256 public saleStartDate = 1719241200; // June 25, 2024 at 00:00:00 UTC

    // Mapping to track the purchased token amount for each user
    mapping(address => uint256) public purchasedTokens;

    // Modifier to check if the sale has started
    modifier saleStarted() {
        require(
            block.timestamp >= saleStartDate,
            "Token sale has not started yet"
        );
        _;
    }

    // Event triggered when a purchase is made
    event Purchase(address indexed buyer, uint256 amount, uint256 value);

    // Event triggered when a claim is made
    event TokensClaimed(address indexed purchaser, uint256 amount);

    // Constructor to initialize the token and stages
    constructor(address _tokenAddress, address _feeWalletAddress) {
        tokenAddress = _tokenAddress;
        feeWalletAddress = _feeWalletAddress;

        // Define each stage
        stages.push(Stage(0.004 * 10e6, 6250000 * 10 ** 18)); // Stage 1
        stages.push(Stage(0.005 * 10e6, 10000000 * 10 ** 18)); // Stage 2
        stages.push(Stage(0.00666 * 10e6, 15000000 * 10 ** 18)); // Stage 3
        stages.push(Stage(0.008 * 10e6, 25000000 * 10 ** 18)); // Stage 4
        stages.push(Stage(0.01 * 10e6, 40000000 * 10 ** 18)); // Stage 5
        stages.push(Stage(0.01142 * 10e6, 70000000 * 10 ** 18)); // Stage 6
        stages.push(Stage(0.01333 * 10e6, 120000000 * 10 ** 18)); // Stage 7
        stages.push(Stage(0.016 * 10e6, 200000000 * 10 ** 18)); // Stage 8
        stages.push(Stage(0.02 * 10e6, 181250000 * 10 ** 18)); // Stage 9
    }

    // Function to buy tokens using USDC
    function buyTokens(uint256 _tokenAmount) external saleStarted nonReentrant {
        require(!salePaused, "Token sale is paused");
        require(currentStage < stages.length, "Token sale is finished");
        require(_tokenAmount > 0, "Token amount must be greater than zero");

        Stage storage stage = stages[currentStage];

        require(
            stage.available >= _tokenAmount,
            "Token amount must be less than the available token amount at the current stage."
        );

        uint256 totalCost = _tokenAmount * stage.price;

        IERC20 usdcToken = IERC20(usdcTokenAddress);

        // Transfer USDC to the owner wallet
        require(
            usdcToken.transferFrom(
                msg.sender,
                address(feeWalletAddress),
                totalCost
            ),
            "USDC transfer failed"
        );

        stage.available -= _tokenAmount;
        purchasedTokens[msg.sender] += _tokenAmount;

        // Check if stage is completed
        if (stage.available == 0) {
            currentStage++;
        }

        // Emit purchase event
        emit Purchase(msg.sender, _tokenAmount, totalCost);
    }

    // Function to pause the token sale (only owner)
    function pauseSale() external onlyOwner {
        salePaused = true;
    }

    // Function to resume the token sale (only owner)
    function resumeSale() external onlyOwner {
        salePaused = false;
    }

    // Function to set the fee wallet address (only owner)
    function setFeeWalletAddress(address _feeWalletAddress) external onlyOwner {
        require(
            _feeWalletAddress != address(0),
            "FeeWalletAddress cannot be the zero address"
        );

        feeWalletAddress = _feeWalletAddress;
    }

    // Function to withdraw unsold tokens or USDC after sale completion (only owner)
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

    // Function to claim tokens after the sale is completed
    function claimTokens() external saleStarted nonReentrant {
        require(
            currentStage >= stages.length,
            "Token sale is not finished yet"
        );

        IERC20 token = IERC20(tokenAddress);

        uint256 balance = purchasedTokens[msg.sender];

        require(balance > 0, "No tokens to claim");

        // Reset the user's purchased token amount
        purchasedTokens[msg.sender] = 0;

        require(token.transfer(msg.sender, balance), "Token claim failed");

        // Emit claim event
        emit TokensClaimed(msg.sender, balance);
    }
}
