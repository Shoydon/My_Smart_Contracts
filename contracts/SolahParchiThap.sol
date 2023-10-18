// This is a Problem I solved in a contest on https://dapp-world.com/
// There are 2 versions of the PS. This is the Easy version of it (https://dapp-world.com/problem/solah-parchi-thap-easy/problem?contest=7)
// Game & functions' description written after code 

//FUNCTIONS:
// 1. getPlayerID(address addr) : takes address as input then checks if that address is a player in the game or not and returns his playerID
// 2. isPLayer(address _player) : takes address as input then checks if that address is a player in the game or not (returns bool)
// 3. setState(address[4] _players, uint8[4][4] _state) : Using this function, owner can start a game by assigning parchis to the players, given that there is currently no game in progress.
// 4. passParchi(uint8 _type) : This function is only accessible to a valid player during the game in his/her own turn. The player must have at least one parchi of type ‘_type’.
// 5. endGame() : Any player can access this during the game after at least 1 hour has passed since the start of the game. This will end the game abruptly without concluding any winner. This is to prevent cases where player either delay their turn, or try to keep 1 parchi of all 4 types with them to prevent anyone from winning the game.
// 6. claimWin() : Any player can access this during the game given that the player has 4 parchis of same type. This will end the game and record a win corresponding to the player who has called this function.
// 7. getState() returns (address[4] players, address turn, uint8[4][4] game): This function can only be accessed by the owner when a game is in progress. players corresponds to the array of addresses of players in the game in order of their turns. turn corresponds to the address of the player who has the ongoing turn. game corresponds to the current state of the parchis in the game as mentioned above.
// 8. getWins(address player) returns (uint):This function can be accessed by anyone by providing an address of a valid player to get the number of wins corresponding to that address.
// 9. myParchis returns (uint8[4] parchis):This function can be accessed by any player in an ongoing game to view his/her parchis. The format of the returned array is same as mentioned earlier.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolahParchiThap {
    address owner;
    bool gameInProgress;
    mapping(address => uint) wins;
    address[4] players;
    uint8[4][4] parchis;
    uint currPlayer = 0;
    uint deadline;

    constructor(){
        owner = msg.sender;
        deadline = block.timestamp + 60 minutes;    //set a minimum deadline for the endGame() 
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function getPlayerID(address addr) public view returns (uint){
        for(uint i = 0; i < 4; i++){        // check if the given address exists in the players array
            if(players[i] == addr){
                return i;       // return the index at which the address is present
            }
        }
        return 5;   //5 means that addr is not present   
    }

    function isPLayer(address _player) public view returns (bool){
        for(uint i = 0; i < 4; i++){        // check if the given address exists in the players array
            if(_player == players[i]){
                return true;        // return true if present
            }
        }
        return false;
    }
    
    // To set and start the game
    function setState(address[4] memory _players, uint8[4][4] memory _parchis) public {
        require(!gameInProgress);       //check if a game is already in progress
        for(uint i = 0; i < 4; i++){
            if (_players[i] == owner){  //check if any one of the players is the owner
                revert();
            }
        }
        for(uint i = 0; i < 4; i++){
            require((_parchis[0][i] + _parchis[1][i] + _parchis[2][i] + _parchis[3][i]) < 5);   // types of cards must be 4
        }
        require((_parchis[0][0] + _parchis[0][1] + _parchis[0][2] + _parchis[0][3]) < 5);       // player 1 can have less than 4 cards
        players = _players;
        parchis = _parchis;
        gameInProgress = true;
    }

    // To pass the parchi to next player
    function passParchi(uint8 parchi) public {
        parchi -= 1;
        require(gameInProgress);
        require(isPLayer(msg.sender));
        require(getPlayerID(msg.sender) != 5);
        require(getPlayerID(msg.sender) == currPlayer);
        require(parchis[currPlayer][parchi] > 0);

        parchis[currPlayer][parchi]--;
        uint nextPlayer = (currPlayer + 1) % 4;
        parchis[nextPlayer][parchi]++;
        currPlayer = nextPlayer;
    }

    // To claim win
    function claimWin() public {
        require(gameInProgress);
        require(getPlayerID(msg.sender) != 5);
        uint claimer = getPlayerID(msg.sender);
        for(uint j = 0; j < 4; j++){
            if(parchis[claimer][j] == 4){
                wins[msg.sender]++;
                gameInProgress = false;
                return;
            }
        }
        revert();
    }

    // To end the game
    function endGame() public {
        require(gameInProgress);
        require(isPLayer(msg.sender));
        require(block.timestamp >= deadline);
        gameInProgress = false;
    }

    // To see the number of wins
    function getWins(address add) public view returns (uint256) {
        if(isPLayer(add)){
            return wins[add];
        }
        revert();
    }

    // To see the parchis held by the caller of this function
    function myParchis() public view returns (uint8[4] memory) {
        require(gameInProgress);
        if(getPlayerID(msg.sender) < 5){
            uint caller = getPlayerID(msg.sender);
            return parchis[caller];
        }
        revert();
    }

    // To get the state of the game
    function getState() public view onlyOwner returns (address[4] memory, address, uint8[4][4] memory) {
        require(gameInProgress);
        return (players, players[currPlayer], parchis);
    }
}

//GAME DESCRIPTION
// "16 Parchi Thap" is an enjoyable card game where four friends aim to collect four chits, called parchis, of the same type without revealing their hand to one another. They take turns passing chits, and the first to gather four of a kind wins the game!

// Rules of 16 Parchi Thap:

// There are total 16 parchis(chits), with each parchi being categorized as type 1, 2, 3, or 4. Four parchis of each type are available.
// Before the game commences, the four participating players start with no parchis.
// In the following examples, the convention for representing chits is as follows:
// Parchis held by a player are represented by an array of length 4, where the nth element in the array indicates the number of parchis of type n.
// For example, the representation [1,2,0,1] means that the player has
// 1 parchi of type 1,
// 2 parchis of type 2,
// 0 parchis of type 3, and
// 1 parchi of type 4.
// Representation of all the distributed parchis in the game will be an array of representation of array of ‘arrays of parchis of players
// For example, the representation [1,2,0,1] means that the player has
// the array [0,1,1,1] corresponds to the parchis held by 1st player (who started the game),
// the array [3,0,1,1] corresponds to the parchis held by 2nd player,
// the array [0,2,1,1] corresponds to the parchis held by 3rd player, and
// the array [1,1,1,1] corresponds to the parchis held by 4th player.
// The game then begins with random distribution of 4 parchis to each participant.
// Example - [[0,2,1,1],[1,0,2,1],[3,0,0,1],[0,2,1,1]]
// Players do not reveal the types of their parchis to others. To win the game, a player must collect 4 parchis of any single type.
// The game runs in cyclic manner, with the first player passing one chit to the next player. For example, consider the state of the game after the initial distribution: [[0,2,1,1],[1,0,2,1],[3,0,0,1],[0,2,1,1]]. In this state, player 1 passes a parchi of type 3 to player 2.
// The next player then sees the type of parchi he/she has and then keeping in mind that he wants to gather 4 parchis of any one type, strategically passes one of the parchis he/she has to the next player.
// Example - now the state of game is [[0,2,0,1],[1,0,3,1],[3,0,0,1],[0,2,1,1]] and its turn of player 2 who passes parchi of type 1 to player 3. The new state of the game will be [[0,2,0,1],[0,0,3,1],[4,0,0,1],[0,2,1,1]]
// As soon as a player gathers 4 parchis of a type, the player can claim the win buy showing his/her parchis to the other players.
// Example - Player 3 can claim win now since the player has 4 parchis of type 1.
// In the event that multiple players collect 4 parchis of a single type, the player who first claims victory is declared the winner.
// Please note that at any point during the game, a player can not have more than 5 parchis and less than 3 parchis.

// Implement a smart contract of the above game with the following public function such that :

// The deployer of the smart contract (let’s call him/her owner) can start the game whose purpose is to manage the game.
// Any player can end the game either by claiming a valid win, or , by directly choosing to end the game given that at least 1 hour has passed since the start of the game.
// Players can see how many time any player corresponding to some address has won the game.
// After the end of the game, new game can be started again by the owner.