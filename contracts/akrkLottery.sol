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
        OPEN,
        CALCULATING
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
        bytes memory /* checkData */
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

        s_lastTimeStamp = block.timestamp;

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

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getNumberofParticicpant() public view returns (uint256) {
        return s_participants.length;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }
}
