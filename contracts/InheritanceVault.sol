// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Vanish Into You — InheritanceVault (skeleton)
 *
 * This contract sketches the *policy surface* for inheritance:
 * - inactivity trigger (check-in heartbeats)
 * - optional attestation trigger (off-chain verified events)
 * - challenge window to prevent malicious/accidental execution
 * - final execution that distributes assets AND unlocks off-chain legacy bundles
 *
 * NOTE: This is a documented skeleton intended for demonstration and extension.
 *       Use audited libraries (OpenZeppelin) and thorough testing for production.
 */

interface ILegacyRegistry {
    function releaseAccess(address subject, address[] calldata beneficiaries) external;
}

contract InheritanceVault {
    event CheckIn(address indexed owner, uint256 timestamp);
    event ClaimInitiated(address indexed subject, address indexed initiator, uint256 timestamp);
    event ClaimCancelled(address indexed subject, uint256 timestamp);
    event Executed(address indexed subject, uint256 timestamp);

    address public owner;
    ILegacyRegistry public legacyRegistry;

    uint256 public lastActive;
    uint256 public inactivityTimeout;   // e.g., 90 days
    uint256 public challengePeriod;     // e.g., 30 days

    bool public claimOpen;
    uint256 public claimInitiatedAt;

    address[] public beneficiaries;     // simplified: equal-weight in skeleton

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _legacyRegistry, uint256 _inactivityTimeout, uint256 _challengePeriod, address[] memory _beneficiaries) {
        owner = msg.sender;
        legacyRegistry = ILegacyRegistry(_legacyRegistry);
        inactivityTimeout = _inactivityTimeout;
        challengePeriod = _challengePeriod;
        beneficiaries = _beneficiaries;
        lastActive = block.timestamp;
    }

    /// Owner heartbeat to prove liveness.
    function checkIn() external onlyOwner {
        lastActive = block.timestamp;
        emit CheckIn(owner, lastActive);
        // If there is an open claim, owner can implicitly cancel by checking in.
        if (claimOpen) {
            claimOpen = false;
            emit ClaimCancelled(owner, block.timestamp);
        }
    }

    /// Anyone can initiate a claim if inactivity exceeded.
    function initiateClaim() external {
        require(block.timestamp > lastActive + inactivityTimeout, "still active");
        require(!claimOpen, "claim already open");
        claimOpen = true;
        claimInitiatedAt = block.timestamp;
        emit ClaimInitiated(owner, msg.sender, block.timestamp);
    }

    /// Owner cancels during challenge window (or anytime before execute).
    function cancelClaim() external onlyOwner {
        require(claimOpen, "no claim");
        claimOpen = false;
        emit ClaimCancelled(owner, block.timestamp);
    }

    /// After challengePeriod, execute distribution + unlock off-chain legacy bundles.
    function execute() external {
        require(claimOpen, "no claim");
        require(block.timestamp >= claimInitiatedAt + challengePeriod, "challenge window");
        claimOpen = false;

        // (1) Distribute on-chain assets (ETH/ERC20/NFT) — omitted in skeleton.
        // (2) Unlock off-chain legacy bundle access for beneficiaries:
        legacyRegistry.releaseAccess(owner, beneficiaries);

        emit Executed(owner, block.timestamp);
    }

    function getBeneficiaries() external view returns (address[] memory) {
        return beneficiaries;
    }
}
