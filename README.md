# employee_hardhat
Solidity, Hardhat, Ethers.js

# Rinkeby deployment
deploying "Actuary": deployed at 0x2A13Cdf1A0bD7d149591D5396da86cA36369A21a with 753690 gas
deploying "ClaimAssessor": deployed at 0xD459cb68E3d6c4dEB932C706Fa74D98a5d3578A3 with 323324 gas
deploying "CohortFactory": deployed at 0x4CB303eA4D688b6e53c8bb7AD0c60F1bB2750aCA with 2667760 gas
reusing "MockUSDT" at 0x67FB9bd8C694B76CeFD95Fdc0A75f2a1b6dA58Fb
deploying "RiskPoolFactory": deployed at 0x727832DD0D7F537bC2dE9319b8033b8A8bAfe081 with 1328515 gas

# Bsc Testnet deployment
- "Actuary" (tx: 0x0ef19b93781e2ae6debaf71ef6979f1a1b21bb43fd120b2a0b8c78ea57502ecc): 0xcCBF1868c7182020E518E6847b6C839623754E9a

- "ClaimAssessor": 0x08c93862ffc7d34b3a416e6e98936268ab6e37c4 

- "CohortFactory" (tx: 0xdf2d21721f78b5c329703d263766bc3cdc910787d7d29828d6a1837ede3c2439)...: deployed at 0x3da51028e20BC45D0bdd50729E52E7405133c3E7

- "MockUSDT" at 0x3853D735ABEb59E1289EEb1F9E9c49B189103E3F

- "PremiumPoolFactory" (tx: 0xf566588dfeff1d6bcb9e8aea0310d3e02c285117ccfe8145d234e2b8576d84ab): 0x74c77F20B2c8C5E4f0E8a7491b8d49c8aa43c644

- "RiskPoolFactory" (tx: 0x89d0de3885cb3f1d42d78bcdeb04d5f5d0383505012c6e17c1e9b84b97b6cca1): 0xdddA286E1D758241D408ae1bA2018Dc7Fd18116C

=== Front end integration on BSC test ===
====== Cohort =====
Address: 0x876dc13ed485828213e1a2500352651bd14b917f - New Cohort

=== PremiumPool ====
0x6505bee81413ec80af2090d80dc8aa1b5cb49277

===== verify ====
npx hardhat verify --network network DEPLOYED_CONTRACT_ADDRESS "constructor argument1"
npx hardhat verify --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS


===== Deploy Again BSC testnet=====
reusing "Actuary" at 0x1F111b0E72954E32f79aE6c258FABa21FFf93B86
reusing "ClaimAssessor" at 0xbB4f1309F3ed7dEC28Ade42BA66c208211D5C56B
deploying "CohortFactory" (tx: 0x8b58c4192c0baa9b8099b17d25381297d7567149d8abf151cff7f2d2a9334efd)...: deployed at 0xEE6524f5134b479899f5bDb604AF8B5DbeE86B88 with 2842472 gas
deploying "MockUSDT" (tx: 0x290099f9f2f9bfcb60c1b754629e9adc0a9a49fa61570569fcf2cd21b78a1569)...: deployed at 0x769545212841822CF1fd628ac47d95fc838ea02F with 985991 gas
reusing "PremiumPoolFactory" at 0x74c77F20B2c8C5E4f0E8a7491b8d49c8aa43c644
reusing "RiskPoolFactory" at 0xdddA286E1D758241D408ae1bA2018Dc7Fd18116C


Run scripts/sample-script.js
Creating Cohort...
Cohort Address ==> 0xF00E99511Bbd860E948103f054A068E2a66bcbE2
PremiumPool Address => 0xf38abA051b311BEC56A5677400CEd721F607B831
Adding protocols...
Creating Risk pools...
Risk Pool Zeus was created, delaying...
Risk Pool Athena was created, delaying...
Risk Pool Artemis was created, delaying...
Writing deploy result..
==END==

Cohort verify
https://testnet.bscscan.com/address/0xF00E99511Bbd860E948103f054A068E2a66bcbE2#code

MockUSDT verify
https://testnet.bscscan.com/address/0x769545212841822CF1fd628ac47d95fc838ea02F#code


=== BSC Testnet deploy3 ===
Nothing to compile
reusing "Actuary" at 0x1F111b0E72954E32f79aE6c258FABa21FFf93B86
reusing "ClaimAssessor" at 0xbB4f1309F3ed7dEC28Ade42BA66c208211D5C56B
deploying "CohortFactory" deployed at 0x1Ee92dD0FF595bCF03e9be780A0d47aa57f2C4E4 with 2867450 gas
reusing "MockUSDT" at 0x769545212841822CF1fd628ac47d95fc838ea02F
deploying "PremiumPoolFactory" deployed at 0xe040a15368654Ee8e7c0CE2dCB1C7bDa341Aff85 with 590502 gas
reusing "RiskPoolFactory" at 0xdddA286E1D758241D408ae1bA2018Dc7Fd18116C

Cohort Address ==> 0xA77997Be31Fc479743fb71ae8f143670ECe5546C
PremiumPool Address => 0x6ab6eEb57C3069c22F7319ad0d12a2A565D4977A
Adding protocols...
Creating Risk pools...
Risk Pool Zeus was created, delaying...
Risk Pool Athena was created, delaying...
Risk Pool Artemis was created, delaying...
Writing deploy result..
==END==

========= BSC main net deploy ===============
Compiling 24 files with 0.8.0
Compilation finished successfully
"ClaimAssessor" deployed at 0xDE491b262fD91992c74343C7F8EE0FF76fF1bCa0 with 349420 gas
"Actuary" deployed at 0xf116D1db8Cf8AbdaEE68835b765B0318e081689c with 780779 gas
"CohortFactory" deployed at 0x50928245CE743dA4b5297e2E4Af32CD480E279A6 with 2867450 gas
"PremiumPoolFactory" deployed at 0x26f51b1EA2eAB0B9e81Ec473Fb65320a86cF15A1 with 590502 gas
"RiskPoolFactory" deployed at 0x1eA9b20Ac66B5FFe244fAc7b8AE389430dE81Aa4 with 1333262 gas

Creating Cohort...
Cohort Address ==> 0xa7c8Dd26eB99534Dd848278e53CB7e260Ea83CE1
PremiumPool Address => 0xd85D5144718982bdD442E67d9810151a6AdF31c2
Adding protocols...
Creating Risk pools...
Risk Pool Zeus was created at 0xEcE9f1A3e8bb72b94c4eE072D227b9c9ba4cd750, delaying...
Risk Pool Athena was created at 0x0b5C802ecA88161B5daed08e488C83d819a0cD02, delaying...
Risk Pool Artemis was created at 0x2cd32dF1C436f8dE6e09d1A9851945c56bcEd32a, delaying...
Writing deploy result..
==END==
