pragma solidity ^0.6.2;

contract Ballot {

    struct VoterDetail {
        uint weight;
        bool voted;
        uint voteFor;
    }

    struct Proposal {
        uint voteCount;
        // might contain other data
    }

    enum Phase {
        Init, Regs, Vote, Done
    }

    Phase public curState = Phase.Done;
    address chairperson;
    mapping(address => VoterDetail) voterDetails;
    Proposal[] proposals;

    constructor(uint numProposals) public {
        chairperson = msg.sender;
        voterDetails[chairperson].weight = 2;

        for (uint i = 0; i < numProposals; i++)
            proposals.push(Proposal(0));
        
        curState = Phase.Regs;
    }

    function changeState(Phase newState) public isChairperson {
        require(newState > curState);
        curState = newState;
    }

    function register(address voterAddr) public isValidPhase(Phase.Regs) isChairperson {
        require(!voterDetails[voterAddr].voted);
        voterDetails[voterAddr].weight = 1;
    }

    function vote(uint toProposal) public isValidPhase(Phase.Vote) {
        VoterDetail memory senderDetail = voterDetails[msg.sender];
        
        require(!senderDetail.voted);
        require(toProposal < proposals.length);

        senderDetail.voted = true;
        senderDetail.voteFor = toProposal;
        proposals[toProposal].voteCount += senderDetail.weight;
    }

    function requestWinner() public isValidPhase(Phase.Done) view returns (uint winner) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winner = i;
            }
        }
        
        assert(winningVoteCount >= 3); // hypothetical
    }

    modifier isValidPhase(Phase reqPhase) {
        require(curState == reqPhase);
        _;
    }

    modifier isChairperson() {
        require(msg.sender == chairperson);
        _;
    }

}