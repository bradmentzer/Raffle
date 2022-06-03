// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//custom errors go outside of contract
error Raffle_SendMoreToEnterRaffle();
error Raffle_RaffleNotOpen();
error Raffle_UpkeepNotNeeded();
error Raffle_TrasferFailed();


//contract is decentralized escrow and winner picker
contract Raffle is VRFConsumerBaseV2{
    enum RaffleState {
        Open,
        Calculating
    }

//s_ indicates to developers that this is a storage value and expensive
RaffleState public s_raffleState;

//immutable variables can only be initalized one time
// in the constructor and never be changed. Significantly cheaper
//i_ indicates to developers that this is a cheap value
uint public immutable i_entranceFee;
uint public immutable i_interval;
address payable[] public s_players;
uint public s_lastTimeStap;
VRFCoordinatorV2Interface public immutable i_VRFCoordinator;
bytes32 public i_gasLane;
uint64 public i_subscriptionId;
uint32 public i_callbackGasLimit;
address public s_recentWinner;

uint16 public constant REQUEST_CONFIRMATIONS = 3;
uint32 public constant NUM_WORDS = 1;

//indexing is expensive
event RaffleEnter(address indexed player);
event RequestedRaffleWinner(uint indexed requestId);
event WinnerPicked(address indexed winner);


    constructor(
        uint entranceFee,
        uint interval,
        address vfrCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ) VRFConsumerBaseV2(vfrCoordinatorV2){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStap = block.timestamp;
        i_VRFCoordinator = VRFCoordinatorV2Interface(vfrCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

    }

    function enterRaffle() external payable {
    //require(msg.value > i_entranceFee, "Not enough money sent");
    //require function is expensive so we revert with custom error
        if(msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }

        //Open, Calculate winner
        if (s_raffleState != RaffleState.Open) {
            revert Raffle_RaffleNotOpen();
        }
        //You can enter. Push msg.sender to array of players
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);

    }

    // 1. we want this done automatically
    // 2. we want a real random winner
    //https://docs.chain.link/docs/chainlink-keepers/introduction/
   
   
   
    //need checkUpkeep function
    // 1. to be true after some time interval
    // 2. The lottery to be open
    // 3. The contract has ETH
    // 4. Keepers has LINK

    function checkUpkeep(bytes memory /* checkData*/ ) 
    public
     view 
     returns(
         bool upkeepNeeded,
          bytes memory /*performData*/
        )
   

    {
        bool isOpen = RaffleState.Open == s_raffleState;
        bool timePassed = (block.timestamp - s_lastTimeStap) > i_interval;
        bool hasBalance = address(this).balance >0;
        bool hasPlayers = s_players.length >0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");

    }

    // need performUpkeep function
    //once its time to trigger a new winner

    function performUpkeep(
        bytes calldata /* performData */
        ) external {
            (bool upKeepNeeded, ) = checkUpkeep("");
            if (!upKeepNeeded) {
                revert Raffle_UpkeepNotNeeded();
            }
            s_raffleState = RaffleState.Calculating;
            uint requestId = i_VRFCoordinator.requestRandomWords(
                i_gasLane,
                i_subscriptionId,
                REQUEST_CONFIRMATIONS,
                i_callbackGasLimit,
                NUM_WORDS
            );
            emit RequestedRaffleWinner(requestId);
        }
        //https://docs.chain.link/docs/get-a-random-number/
        //need to request to get random winner
    function fulfillRandomWords(
        uint, /*requestId*/
        uint[] memory randomWords
    ) internal override {
        uint indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.Open;
        s_lastTimeStap = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success){
            revert Raffle_TrasferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

}