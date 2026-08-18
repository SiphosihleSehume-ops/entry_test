# Part B: Test Scenarios Guide

**Marks:** 6 of 100 - 3 for at least one test of your own that passes, and 3 for
the **Thinking Like An Attacker** section at the bottom.

The auto-marker already runs its own test suite against your contracts. This
section is about whether *you* can think like a tester.

**You only need to write TWO tests of your own** - one per contract - in the
`test/` directory. There is a worked example in `test/example.test.js` you can
copy from. Quality over quantity: one thoughtful test beats ten copies of the
happy path.

Run them with:

```bash
npx hardhat test
```

---

## Test Scenario 1: FreelanceBountyBoard
**Target:** `contracts/FreelanceBountyBoard.sol`

### 1.1 The test I wrote

- **Test file and name:** [test/FreelanceBountyBoard.test.js - should allow a registered freelancer with the correct skill to apply for a bounty]
- **What it checks:** [It checks that a freelancer can register, an employer can post a bounty, and the freelancer can successfully apply when their registered skill matches the required bounty skill.]
- **Steps:** [1. Register the freelancer with a skill. 2. Post a bounty requiring the same skill and send ETH with the transaction. 3. Have the freelancer apply for the bounty. 4. Check that hasApplied(bountyId, freelancer) returns true.]
- **Expected result:** [The application succeeds and hasApplied(bountyId, freelancer) returns true.]
- **Does it pass?** [yes]

### 1.2 A scenario I did NOT have time to test

Describe one thing that could go wrong with this contract that neither you nor
the auto-marker checked. You do not have to write the code - just show you can
see the gap.

[One scenario I would test is whether a freelancer can submit work for a bounty and then another freelancer can submit work for the same bounty. Since the bounty changes from Open to Submitted after the first submission, the second freelancer should not be able to submit work. I would also test that only the freelancer who actually applied can submit the work.]

---

## Test Scenario 2: DecentralisedRaffle
**Target:** `contracts/DecentralisedRaffle.sol`

### 2.1 The test I wrote

- **Test file and name:** [test/DecentralisedRaffle.test.js - should allow a player to enter the raffle]
- **What it checks:** [It checks that a player can enter the raffle by sending the required entry fee and that the player is recorded as an entrant.]
- **Steps:** [1. Deploy the raffle contract. 2. Get a test account. 3. Call the raffle entry function while sending the required entry fee. 4. Check that the player's address is included in the list of players.]
- **Expected result:** [The transaction succeeds and the player's address is recorded as a raffle participant.]
- **Does it pass?** [yes]

### 2.2 The hard one

Testing a raffle is awkward because the winner changes every run. **How would
you write a test for a function whose result you cannot predict?** What can
you assert that is true no matter who wins?

(Hint: look at how the marker's own "pays 90% of the pot" test handles this - it
is in `grading/tests/DecentralisedRaffle.grading.test.js` and you are welcome
to read it.)

[Instead of checking that a specific player wins, I would check properties of the result that must always be true. For example, after the winner is selected, I would check that the winner is one of the players who entered the raffle, that the winner receives 90% of the pot, and that the remaining 10% is handled correctly. This makes the test independent of which player is randomly selected.]

---

## Thinking Like An Attacker (3 marks)

Pick **one** of your two contracts. If you wanted to steal from it or break it,
what would you try first?

- **Contract:** [FreelanceBountyBoard]
- **My attack:** [I would try to get paid twice for the same bounty by calling approveAndPay() more than once, or by using a malicious contract as the freelancer that attempts to call back into the bounty contract during the ETH transfer.]
- **Does it work against my implementation?** [no]
- **If it works, what would fix it?** [The double-payment attack should not work because approveAndPay() changes the bounty status to Status.Completed before transferring the ETH. This follows the checks-effects-interactions pattern. If the implementation did not change the status before the external call, the fix would be to set the status to Completed before sending the ETH and reject any payment unless the bounty is in Submitted status.]

An honest "yes, this attack works against my code, and here is the fix" scores
full marks here. Claiming your contract is perfect scores nothing.

[Another attack I would consider is a freelancer trying to submit work without applying for the bounty. My implementation checks applications[bountyId][msg.sender], so an address that did not apply should be rejected.]

---

## Checklist

- [ ] At least one test of my own in `test/`
- [ ] `npx hardhat test` runs without crashing
- [ ] I filled in the attacker section above
