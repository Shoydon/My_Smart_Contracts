// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolahParchiThap {
    address owner;
    bool gameInProgress;
    mapping(address => uint) wins;
    address[4] players;
    uint8[4][4] parchis;
    mapping(address => uint8[4]) parchisMap;
    uint currPlayer = 0;
    uint deadline;

    constructor(){
        owner = msg.sender;
        deadline = block.timestamp + 60 minutes;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function getPlayerID(address addr) public view returns (uint){
        for(uint i = 0; i < 4; i++){
            if(players[i] == addr){
                return i;
            }
        }
        return 5;
    }

    function isPLayer(address _player) public view returns (bool){
        for(uint i = 0; i < 4; i++){
            if(_player == players[i]){
                return true;
            }
        }
        return false;
    }
    
    // To set and start the game
    function setState(address[4] memory _players, uint8[4][4] memory _parchis) public {
        require(!gameInProgress);
        for(uint i = 0; i < 4; i++){
            if (_players[i] == owner){
                revert();
            }
        }
        // for(uint i = 1; i < 4; i++){
        //     require((_parchis[i][0] + _parchis[i][1] + _parchis[i][2] + _parchis[i][3]) < 5);
        // }

        for(uint i = 0; i < 4; i++){
            require((_parchis[0][i] + _parchis[1][i] + _parchis[2][i] + _parchis[3][i]) < 5);
        }
        require((_parchis[0][0] + _parchis[0][1] + _parchis[0][2] + _parchis[0][3]) < 5);
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