# Intro

Well, so you looked at the code and saw that the team has this nice kind of multi-transaction deposit() function. They get the serialized parameters from the user, chek if it is an ETH pool or a token pool, and then use the correct selector for the contract. However...what would happened if the wrong contract and selector where used? Sure, Solidity would check that the type of the parameters is correct, right? Or at least that the amount of serialized data is correct, right? Right??

This entry aims to show how Solidity serializes data and how low-level function call works. Also it hints to the characteristics of entropy. In particular:

-   Basic data types like uint128, bool or address are serialized as uint256 values
-   When using low-level call, even through OpenZeppelin Address.functionCall(), the type or size of parameters are NOT checked
-   It is not unthinkable for an attacker to generate a Create2 address for their exploits that have less that fit in 128 bits
-   Check carefully all the implications derived from the use of functions by unpriviledged users
-   Order of checks in if...else may be important when working with serialized data

# The Hack

-   The first thing for the hack to work is to fetch the VeryCoolPeryphery.defaultETHPool() and add it back as a token pool with VeryCoolPeryphery.addTokenPool()
-   The function VeryCoolPeryphery.\_getSelector() checks first if the given pool is an ETH pool and returns the correct selector for the deposit() function. However the VeryCoolPeryphery.\_getCallData() first checks if the pool is a token pool. Because the ETH pool is now registered as both types of pool, this causes the contract to call the ETHPool with the right selector but the wrong serialized data
-   This is particularly dangerous because the call data for VeryCoolETHPool.deposit() is shorter than the call data for VeryCoolTokenPool.deposit(). Even though VeryCoolPeryphery injects the correct msg.sender and the correct third-party staking pool, the attacker can actually change the third-party staking pool to one of their making
-   The attacker, however, can control only 128 bits of the third-party staker address, so she must find the right salt for a Create2 that generates an address which first 32 bits are set to zero
-   The attacker then creates an attacking contract that calls VeryCoolPeryphery.deposit() with the ETHPool, the serialized parameters of the timestamp and the address of the exploiting contract itself. This causes VeryCoolPeryphery to call into the VeryCoolETHPool.deposit() with the user-given timestamp and the address of the exploiting contract
-   The VeryCoolETHPool anotates the amount of ETH received to the exploiting contract amount and user-given timestamps that can be right the next second. Then it calls back into the exploiting contract giving back all the ETH. The exploiting contract could rinse and repeat before running out of gas for a reentrancy attack.
-   Finally, withdraw much more than given (actually, infinite more times than given ;) ) for profit

An example exploit contract can be found in VeryCoolAMMExploit.sol, which would need a salt=.... to generate the address 0x.....

Hope you liked it! I definitely had a lot of fun with it :)
