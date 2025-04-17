// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    address public chairperson;

    struct Candidate {
        string description;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
    }

    //State
    Candidate[] public candidates; 
    uint public candidateCount; // Easiest way I could think of to address candidate ID

    mapping (address => Voter) private voters;

    bool votingIsOpen = true;

    uint private winnerCount = 0;
    uint public winnerId;

    //Modifiers - functions can be called only if they are modifiers and return value is bool
    modifier onlyChair() {
        require(msg.sender == chairperson, "Only Chair");
        _;
    }

    modifier onlyWhenVotingIsOpen() {
        require(votingIsOpen == true, "Voting is closed.");
        _;
    }

    modifier onlyWhenVotingHasEnded() {
        require(votingIsOpen == false, "Voting is not closed.");
        _;
    }

    event VoteCast(uint indexed _candidateIndex, address _from);
    event AddedCandidate(uint ID, string description_);
    event VotingEnded();

    constructor () {
        chairperson = msg.sender;
    }

    function addCandidate(string memory description_) public onlyChair { 
        candidates.push(Candidate(description_, 0));
        candidateCount++;

        emit AddedCandidate(candidateCount, description_);
    }

    function vote(uint _candidateIndex) public onlyWhenVotingIsOpen {
        //Makes sure they can only vote once
        require(!voters[msg.sender].hasVoted, "Voter has already Voted"); 

        candidates[_candidateIndex].voteCount++;
        voters[msg.sender].hasVoted = true;

        emit VoteCast(_candidateIndex, msg.sender);
    }

    function endVotingSession() public onlyWhenVotingIsOpen {
        for (uint i = 0; i < candidateCount; i++) 
        {
            if(winnerCount < candidates[i].voteCount) {
                winnerId = i;
            }
        }
        votingIsOpen = false;

        emit VotingEnded();
    }

    function getWinner() public view onlyChair onlyWhenVotingHasEnded returns (Candidate memory winner, uint winnerID_){
        require(winnerCount > 0, "There are no winners");

        return (candidates[winnerId], winnerId);
    }
}