Part B: Design Document

Marks: 4 of 100 - the Randomness section below is read and marked. The
rest of this document is not scored, but it is read when we talk to you, so
answer it properly.

Section 1: FreelanceBountyBoard
Section 2: DecentralisedRaffle

Short, specific answers beat long vague ones. Three honest sentences score better
than a page of general security talk. If you ran out of time on something, say
so here - describing what you would have done still earns marks. Pretending it
is finished does not.

WHY I BUILT IT THIS WAY

1. Data Structure Choices

Where did you use a mapping, and where did you need an array instead?

How did you record raffle entries so that a player who enters three times has
three times the chance of winning?

How did you count unique players separately from total entries?

[I used mappings in my FreelanceBountyBoard and DecentralisedRaffle contracts where I needed to quickly look up information by an address or bounty ID. I used an array for the raffle players because every individual entry needs to be stored, meaning that if the same player enters three times, their address appears three times in the array and therefore has three chances of being selected. I kept a separate count of unique players by checking whether an address had entered before, while the total number of entries counted every entry.]

2. Security Measures

Reentrancy: show the order of operations in approveAndPay. Which line
updates the status, and which line sends the ETH? Why that order?

Access control: which functions are owner-only or employer-only, and what
would go wrong without those checks?

Input validation: what did you reject, and where?

[I used the checks-effects-interactions pattern in approveAndPay. First, I set bounties[bountyId].status = Status.Completed, and only after changing the state do I send the ETH using freelancer.call{value: amount}(""); this prevents a malicious recipient from calling back and being paid twice. The employer check makes sure only the employer who posted the bounty can approve payment, while input validation rejects things such as an already registered freelancer, an empty skill, a zero-value bounty, an invalid bounty ID, an unregistered freelancer, a duplicate application, a skill mismatch, and invalid bounty states.]

3. Randomness - Be Honest Here (4 marks)

You were allowed to use block data for the raffle draw. This section is where
you show you understand what that costs.

What exactly does your randomness depend on?

Who can manipulate it, and how? Name the actor and the action.

What would you use in production instead, and why is that better?

[My raffle randomness depends on blockchain data such as the block timestamp, block number, previous block hash, or another block-related value used by the winner-selection calculation. The main actor who could influence this is the block producer/validator, because they have some control over block-related values such as the timestamp and can potentially influence the result if the reward is valuable enough. In production I would use a verifiable randomness service such as Chainlink VRF because it provides randomness that is generated independently and can be cryptographically verified, making it much harder for the contract participants or block producer to manipulate the winner.]

4. Trade-offs & Future Improvements

What did you not finish, or knowingly do the quick way?

What would you add with another day? (dispute resolution, refunds, prize
tiers, gas optimisation)

[I kept the implementation focused on the mandatory functionality and used simple state structures rather than trying to build a complete production marketplace. With another day I would add a dispute-resolution or timeout mechanism for bounties, refund handling when work is not completed, stronger production-grade randomness for the raffle, and gas optimisations. I would also improve the handling of multiple submissions and add more comprehensive tests for malicious or unexpected behaviour.]

REAL-WORLD DEPLOYMENT CONCERNS

[!NOTE]
These are written questions only. You are not deploying anything, and
you do not need a wallet, a faucet or any test ETH to answer them. Reason it
through in prose.

1. Gas Costs

Which of your functions is the most expensive, and why?

Roughly what would it cost a user at 20 gwei, with ETH at $3,000? (Use the
same arithmetic as Part A Question 2.)

Is that affordable for the users you would actually be building this for? If
not, what would you change?

[The most expensive functions are likely to be the ones that write several pieces of data to storage, such as postBounty or entering the raffle, because storage writes consume significant gas. For example, if a transaction used approximately 100,000 gas, at 20 gwei the cost would be 0.002 ETH, which would be about $6 at an ETH price of $3,000. This could be expensive for users making small-value transactions, so I would consider using a Layer 2 network with lower fees and optimising storage usage.]

2. Scalability

What happens when the raffle has 10,000 entries?

Which part of selectWinner gets slower or more expensive as the array grows?

What breaks first?

[With 10,000 entries, the main issue is any part of selectWinner that loops through or processes the players array, because the amount of work increases as the array grows. If the contract has to iterate through all 10,000 entries in one transaction, the transaction could become very expensive and eventually run out of gas. The gas limit would therefore become the main scalability problem before the array itself necessarily becomes invalid.]

3. User Experience

How would you make this usable for someone who has never held a wallet?

What is the hardest step for a first-time user?

If you were deploying this for real, which testnet would you try it on
first, and how would a tester get test ETH? (Describe it - you are not doing
it.)

[The hardest step for a first-time user would probably be setting up a wallet, securing the seed phrase, obtaining test ETH, and understanding how transaction fees work. I would provide a simple web interface that connects to a wallet such as MetaMask and clearly explains each transaction before the user confirms it. If I were deploying this for testing, I would first use the Sepolia Ethereum testnet; testers could create a test wallet and request Sepolia ETH from a Sepolia faucet, which provides test ETH without using real money.]

MY LEARNING APPROACH

Resources I Used

Be specific. "The Cyfrin course" is not a resource; "Blockchain Basics, The
Oracle Problem" is. List 3-5.

[List your resources:

Solidity by Example - Solidity language examples and smart contract patterns.

Ethereum.org Developer Documentation - Ethereum, transactions, gas, and smart contract concepts.

OpenZeppelin Contracts Documentation - secure Solidity contract patterns and reusable components.

Hardhat Documentation - compiling, deploying, and testing Solidity smart contracts.

Chainlink Documentation - verifiable randomness and Chainlink VRF concepts.]

Challenges Faced

The biggest thing you got stuck on

How you got unstuck

What you know now that you did not this morning

[My biggest challenge was understanding how the different Solidity components work together, especially mappings, arrays, events, msg.sender, payable functions, and secure ETH transfers. I got unstuck by breaking the contract into smaller functions, reading the compiler/test errors carefully, and checking the Solidity documentation and examples. I now understand much better how smart contracts store state, how ETH is transferred, why checks-effects-interactions matters, and why blockchain block data is not ideal as secure randomness.]

What I'd Learn Next

[I would learn more about Chainlink VRF and other secure sources of randomness, Solidity security patterns such as reentrancy protection and access control, gas optimisation and Layer 2 networks, and how to write more comprehensive Hardhat tests. I would also like to learn how to connect a Solidity contract to a frontend so that a real user can interact with the contract through a wallet.]