// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DecentralisedRaffle
 * @dev A raffle contract with a circuit breaker and a fair payout split
 * @notice PART 2 - Decentralised Raffle (MANDATORY)
 *
 * ---------------------------------------------------------------------------
 * IMPORTANT: THE AUTO-MARKER CALLS THESE EXACT FUNCTION AND EVENT SIGNATURES.
 * Do not rename them, reorder their parameters, or change their return types.
 * You may add anything you like alongside them.
 * ---------------------------------------------------------------------------
 */
contract DecentralisedRaffle {
    // --- Events (the marker checks these are emitted) ---

    event RaffleEntered(address indexed player, uint256 entryCount);
    event WinnerSelected(uint256 indexed raffleId, address indexed winner, uint256 prize);
    event RafflePaused();
    event RaffleUnpaused();

    /// @notice The minimum a player must send for one entry
    uint256 public constant MINIMUM_ENTRY = 0.01 ether;

    /// @notice How long the raffle must run before a winner can be drawn
    uint256 public constant RAFFLE_DURATION = 24 hours;

    address public owner;
    uint256 public raffleId;
    uint256 public raffleStartTime;
    bool public isPaused;

    // TODO: Define the rest of your state variables here.
    // Consider:
    // - One call to enterRaffle() buys ONE entry, and a player may enter many
    //   times. An array of addresses records every entry in order - the same
    //   address simply appears more than once, which gives them better odds.
    // - You also need the number of UNIQUE players, for the 3-player minimum.
    // - The pot is just this contract's balance.
    mapping(address => uint256) public entries;
    address[] public players;
    uint256 constant MIN_PLAYERS = 3;
    // pot
    uint256 constant potSize = 1000;
    uint256 totalEntries;

    // Event types\
    event Players(address player, uint256 raffleId);
    event WinnerSelected(address winner, uint256 prize);
    event State(bool state);

    constructor() {
        owner = msg.sender;
        raffleId = 1;
        raffleStartTime = block.timestamp;
        isPaused = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    // -----------------------------------------------------------------------
    // TODO 1: enterRaffle
    // -----------------------------------------------------------------------
    // Requirements:
    // - Revert if msg.value is below MINIMUM_ENTRY
    // - Revert while the raffle is paused
    // - Record ONE entry for msg.sender (they may enter repeatedly)
    // - If this is the caller's first ever entry this round, they are a new
    //   unique player
    // - Emit RaffleEntered(msg.sender, <this player's total entries so far>)

    // Error-type response if is paused
    error EnforcePaused();

    function enterRaffle() external payable {
        require(msg.value >= MINIMUM_ENTRY, "Insufficient funds join this draw");

        if (isPaused) {
            revert EnforcePaused();
        }

        // Extract a single count for single player
        uint256 entryCount = msg.value / MINIMUM_ENTRY;

        // Record a single entry 
        entries[msg.sender] += entryCount;

        // Theni update total entries
        totalEntries += entryCount;

        // Caller new round
        if (entries[msg.sender] == 0) {
            players.push(msg.sender);
        }

        emit RaffleEntered(msg.sender, entryCount);
    }

    // -----------------------------------------------------------------------
    // TODO 2: selectWinner
    // -----------------------------------------------------------------------
    // Requirements:
    // - Only the owner may call it
    // - Revert unless at least RAFFLE_DURATION has passed since raffleStartTime
    // - Revert unless there are at least 3 UNIQUE players
    // - Pick a winning index across ALL entries, so a player with 3 entries is
    //   three times as likely to win as a player with 1
    // - Pay 90% of the pot to the winner and 10% to the owner
    // - Emit WinnerSelected(raffleId, winner, prizeAmount)
    // - Reset for the next round: increment raffleId, clear the entries, and
    //   set raffleStartTime to now
    //
    // MATHS: calculate the prize as (pot * 90) / 100. Multiply before you
    // divide, or you will lose precision.
    //
    // RANDOMNESS - read this carefully, it is the point of the exercise:
    // You will probably reach for something like
    //     uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))
    // That is ACCEPTABLE for this assessment, because a genuinely secure
    // source (Chainlink VRF, commit-reveal) is beyond a 3-hour test. What is
    // NOT acceptable is pretending it is secure. In PartB_Design.md you must
    // explain who can manipulate your randomness, how, and what you would use
    // in production instead. That explanation carries the marks here, not the
    // code.
    function selectWinner() external onlyOwner {
        // Ensure the player is within duration
        require(
            block.timestamp >= raffleStartTime + RAFFLE_DURATION,
            "Lottery is still running"
        );
        require(players.length >= MIN_PLAYERS, "Not enough players");
        require(totalEntries > 0, "No entries");

        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.prevrandao,
                    block.timestamp,
                    totalEntries
                )
            )
        );

        uint256 winnerIndex = random % totalEntries;
        address winner = findPlayer(winnerIndex);

        uint256 pot = address(this).balance;
        uint256 winnerAmount = (pot * 90) / 100;
        uint256 ownerAmount = pot - winnerAmount;

        raffleId++;
        raffleStartTime = block.timestamp;
        totalEntries = 0;

        for (uint256 i = 0; i < players.length; i++) {
            entries[players[i]] = 0;
        }

        delete players;

        (bool success, ) = winner.call{value: winnerAmount}("");
        require(success, "Winner payment failed");

        (success, ) = owner.call{value: ownerAmount}("");
        require(success, "Owner payment failed");

        emit WinnerSelected(winner, winnerAmount);
    }

    // Helper fiunction to find my winner
    function findPlayer(uint256 index) private view returns (address) {
        uint256 count = 0;

        for (uint256 i = 0; i < players.length; i++) {
            count += entries[players[i]];

            if (index < count) {
                return players[i];
            }
        }

        revert("Player not found");
    }

    // -----------------------------------------------------------------------
    // TODO 3: Circuit breaker
    // -----------------------------------------------------------------------
    // Requirements:
    // - Owner only, both functions
    // - Set isPaused, and emit RafflePaused() / RaffleUnpaused()
    function pause() external onlyOwner {
        isPaused = !isPaused;
        emit State(isPaused);
        emit RafflePaused();
    }

    function unpause() external onlyOwner {
        isPaused = isPaused;
        emit State(isPaused);
    }

    // -----------------------------------------------------------------------
    // TODO 4: View functions (the marker calls all four)
    // -----------------------------------------------------------------------

    /// @notice The current pot, in wei
    function getPot() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice How many entries this player has bought this round
    function getEntryCount(address player) external view returns (uint256) {
        //
    }

    /// @notice Total number of entries this round, counting repeats
    function getPlayerCount() external view returns (uint256) {
        return players.length;
    }

    /// @notice Number of distinct addresses that have entered this round
    function getUniquePlayerCount() external view returns (uint256) {
       //
    }

    // BONUS (not auto-marked, describe it in PartB_Design.md instead):
    // - Refund everyone if the raffle closes with fewer than 3 players
    // - Multiple prize tiers (1st, 2nd, 3rd)
}
