![k61](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/5bdd4377-30bc-4c72-9d65-3ca8c58c0abd)# Ali_Khatami_Lottery7(Learning from the video of Patrick Collins)

### Implementing Chainlink Keepers(performUpkeep)

In the code of this repo https://github.com/C191068/Ali_Khatami_Lottery6.git

we actually learn how to do trigger now we will write the function <br>
that will get executed after upkeepNeeded returns true <br>

This gonna be our performUpkeep function <br>


![k53](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/950c4697-eea1-4ac9-acd0-5ad4f07a8d84)


Now when it is time to pick a rando winner actually what we gonna do <br>
is just call this function <br>

So instead of having these extra function we will transform the above function shown in figure <br>

to performUpkeep function <br>


Since once checkUpkeep returns true the chainlink node will automatically call the <br>
performUpkeep function <br>

![k54](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/66433f60-3fa1-4622-9ea4-bf648dbbb2c5)

requsetRandomwinner replace to performUpkeep <br>


![k55](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/a2f2f599-700f-4d2c-a89d-a04d040926fb)


And we will have it to take input parameter as the above <br>


![k56](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/53eebf07-8782-4be8-a74d-d8ad8c98f7c8)

In our checkupkeep we ahve performData we will automatically pass it to performUpkeep <br>


We aree not gonna pass anything to performUpkeep we will leave it comment like the above <br>

![k57](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/02c006e3-55aa-4fb5-9ac8-04ebd3ea3462)


Since performUpkkep is identified in the AutomationCompatible interface it is now gonna <br>
be override <br>

We gonna do a lit bit valaidation because right now anybody can call our performUpkeep function <br>

We have to make sure it only gets called when checkupkeep is true <br>


An easy way to do that is to call our own checkupkeep function <br>

As checkupkeep is external we can't call our own checkup function <br>

![k58](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/04410442-7aa6-4642-a5d3-2928f4dfaeed)

So we made it public so that our own smart contarct can call these chcekupkeep function  <br>



![k59](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/7a7c90ff-20fc-457f-aad9-230f9705a1d9)

In performUpkeep we can call checkUpkeep passing nothing and return upkeepneeded and performdata,<br> 
performdata is not needed and for that we giv ethe above line of code  <br>

Now we want to make sure that boolean of upkeepneeded is true <br>
in order to keep going with the function <br>

![k60](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/0a054af5-fbe6-440a-ab86-ca3f229e4d9a)

here we create a new revert error for upKeep if not needed <br>
We gonna pass some variables to this error so that whoever is running into this bug <br>

can hopefully see why they are getting this error <br>


![k61](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/b9b0ca02-f0cd-475a-999e-24e57b915772)

so we will pass the balance of this contract just in case there is no ether is here <br>
players dot length just in case there is no players and third one to make sure <br>
lotter is actually open <br>

![k62](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/ff495bbc-00ac-4f18-a144-c16edb00d197)

So here we create the new error function <br>


![k63](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/10baff53-1354-4410-9b13-fbde57da9af3)


We need to reset timestamp, evrytime the winner is picked we want to resest the timestamp as well <br>

So that we can wait another interval and let people particicpate in lottery for that interval <br>

```solidity

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

error akrkLottery_NotEnoughEthEntered();
error akrkLottery_TransferFailed();
error akrkLottery_NotOpen();
error akrkLottery_UpkeepNotNeeded(
    uint256 currentBalance,
    uint256 numParticipants,
    uint256 lotteryState
);

contract akrkLottery is VRFConsumerBaseV2, AutomationCompatible {
    //below we gonna pick minimum price and it gonna be storage variable
    //visibiliy will be private but it will be configurable
    //We will cover our both storage and non storage variables under state variables section

    /*New data type*/

    enum LotteryState {

    }

    /* State variables */

    uint256 private immutable i_welcomeFee;
    //We probably also nedd to track of all the users who entered the lottery
    //participants is a storage variable because we gonna modify this a lot
    address payable[] private s_participants;

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    bytes32 private immutable i_gasLane;

    uint64 private immutable i_subscriptionId;

    uint32 private immutable i_callbackGaslimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint32 private constant NUM_WORDS = 1;

    //Lottery variables

    address private s_recentChampion;
    LotteryState private s_lotteryState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;

    /* Events */

    event LotteryEnter(address indexed participants);

    event RequestedLotteryChampion(uint256 indexed requestId);

    event ChampionPicked(address indexed champion);

    // to configure it we st constructor below

    constructor(
        address vrfCoordinatorV2,
        uint256 welcomeFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGaslimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_welcomeFee = welcomeFee;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);

        i_gasLane = gasLane;

        i_subscriptionId = subscriptionId;

        i_callbackGaslimit = callbackGaslimit;

        s_lotteryState = LotteryState.OPEN;

        s_lastTimeStamp = block.timestamp;

        i_interval = interval;
    }

    //to enter the lottery we created a function below

    function enterLottery() public payable {
        if (msg.value < i_welcomeFee) {
            revert akrkLottery_NotEnoughEthEntered();
        }

        if (s_lotteryState != LotteryState.OPEN) {
            revert akrkLottery_NotOpen();
        }

        s_participants.push(payable(msg.sender));

        emit LotteryEnter(msg.sender);
    }

    //this is the function that the Chainlink keeper nodes call
    //they look for 'upkeepNeeded' to return true

    function checkUpkeep(
        bytes calldata /* checkData */
    ) public override returns (bool upkeepNeeded, bytes memory /*performData*/) {
        bool isOpen = (LotteryState.OPEN == s_lotteryState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasParticipants = (s_participants.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasParticipants && hasBalance);
    }

    //to pick a random champion we created the function below
    //The below function is gonna be called by chainlink keepers network

    function performUpkeep(bytes calldata /*performData*/) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");

        if (!upkeepNeeded) {
            revert akrkLottery_UpkeepNotNeeded(
                address(this).balance,
                s_participants.length,
                uint256(s_lotteryState)
            );
        }
        s_lotteryState = LotteryState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGaslimit,
            NUM_WORDS
        );

        emit RequestedLotteryChampion(requestId);
    }

    function fulfillRandomWords(
        uint256,
        /* requestId */ uint256[] memory randomWords
    ) internal override {
        uint256 indexofChampion = randomWords[0] % s_participants.length;

        address payable recentChampion = s_participants[indexofChampion];

        s_recentChampion = recentChampion;

        s_lotteryState = LotteryState.OPEN;

        s_participants = new address payable[](0);

        s_lastTimeStamp = block.timeStamp;

        (bool success, ) = recentChampion.call{value: address(this).balance}("");

        if (!success) {
            revert akrkLottery_TransferFailed();
        }

        emit ChampionPicked(recentChampion);
    }

    //we want other users to see entrance fee so we created the function below
    /*View/Pure Function*/
    function getEntranceFee() public view returns (uint256) {
        return i_welcomeFee;
    }

    //to know who are in the participants array the function is created below
    function getParticipant(uint256 index) public view returns (address) {
        return s_participants[index];
    }

    function getRecentChampion() public view returns (address) {
        return s_recentChampion;
    }
}

```


### Code cleanup


now we gonna make our code more professional and give people who are reading this contract  <br>

even more  information <br>

![k64](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/e4090887-feb9-42b9-8bbc-54d86f0e4232)

this is what called NatSpec contract documentation <br>


![k65](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/02ae9488-a128-438c-94ee-91df7a8e8d4b)


thus we ahve added it here <br>


```solidity

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

error akrkLottery_NotEnoughEthEntered();
error akrkLottery_TransferFailed();
error akrkLottery_NotOpen();
error akrkLottery_UpkeepNotNeeded(
    uint256 currentBalance,
    uint256 numParticipants,
    uint256 lotteryState
);

/**@title Lottery Contract
 * @author Ali Khatami
 * @notice This contract is for creating an untemparable decentralized smart contract
 * @dev This implements Chainlink VRF v2 nad Chainlink keepers
 */

contract akrkLottery is VRFConsumerBaseV2, AutomationCompatible {
    //below we gonna pick minimum price and it gonna be storage variable
    //visibiliy will be private but it will be configurable
    //We will cover our both storage and non storage variables under state variables section

    /*New data type*/

    enum LotteryState {

    }

    /* State variables */

    uint256 private immutable i_welcomeFee;
    //We probably also nedd to track of all the users who entered the lottery
    //participants is a storage variable because we gonna modify this a lot
    address payable[] private s_participants;

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    bytes32 private immutable i_gasLane;

    uint64 private immutable i_subscriptionId;

    uint32 private immutable i_callbackGaslimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint32 private constant NUM_WORDS = 1;

    //Lottery variables

    address private s_recentChampion;
    LotteryState private s_lotteryState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;

    /* Events */

    event LotteryEnter(address indexed participants);

    event RequestedLotteryChampion(uint256 indexed requestId);

    event ChampionPicked(address indexed champion);

    // to configure it we st constructor below

    constructor(
        address vrfCoordinatorV2,
        uint256 welcomeFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGaslimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_welcomeFee = welcomeFee;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);

        i_gasLane = gasLane;

        i_subscriptionId = subscriptionId;

        i_callbackGaslimit = callbackGaslimit;

        s_lotteryState = LotteryState.OPEN;

        s_lastTimeStamp = block.timestamp;

        i_interval = interval;
    }

    //to enter the lottery we created a function below

    function enterLottery() public payable {
        if (msg.value < i_welcomeFee) {
            revert akrkLottery_NotEnoughEthEntered();
        }

        if (s_lotteryState != LotteryState.OPEN) {
            revert akrkLottery_NotOpen();
        }

        s_participants.push(payable(msg.sender));

        emit LotteryEnter(msg.sender);
    }

    //this is the function that the Chainlink keeper nodes call
    //they look for 'upkeepNeeded' to return true

    function checkUpkeep(
        bytes calldata /* checkData */
    ) public override returns (bool upkeepNeeded, bytes memory /*performData*/) {
        bool isOpen = (LotteryState.OPEN == s_lotteryState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasParticipants = (s_participants.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasParticipants && hasBalance);
    }

    //to pick a random champion we created the function below
    //The below function is gonna be called by chainlink keepers network

    function performUpkeep(bytes calldata /*performData*/) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");

        if (!upkeepNeeded) {
            revert akrkLottery_UpkeepNotNeeded(
                address(this).balance,
                s_participants.length,
                uint256(s_lotteryState)
            );
        }
        s_lotteryState = LotteryState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGaslimit,
            NUM_WORDS
        );

        emit RequestedLotteryChampion(requestId);
    }

    function fulfillRandomWords(
        uint256,
        /* requestId */ uint256[] memory randomWords
    ) internal override {
        uint256 indexofChampion = randomWords[0] % s_participants.length;

        address payable recentChampion = s_participants[indexofChampion];

        s_recentChampion = recentChampion;

        s_lotteryState = LotteryState.OPEN;

        s_participants = new address payable[](0);

        s_lastTimeStamp = block.timeStamp;

        (bool success, ) = recentChampion.call{value: address(this).balance}("");

        if (!success) {
            revert akrkLottery_TransferFailed();
        }

        emit ChampionPicked(recentChampion);
    }

    //we want other users to see entrance fee so we created the function below
    /*View/Pure Function*/
    function getEntranceFee() public view returns (uint256) {
        return i_welcomeFee;
    }

    //to know who are in the participants array the function is created below
    function getParticipant(uint256 index) public view returns (address) {
        return s_participants[index];
    }

    function getRecentChampion() public view returns (address) {
        return s_recentChampion;
    }

    function getLotteryState() public view returns (LotteryState) {
        return s_lotteryState;
    }
}


```


































































