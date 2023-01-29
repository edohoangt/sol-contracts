pragma solidity ^0.6.2;

contract AirlineConsortium {

    struct Details {
        uint escrow; // consortium escrow
        uint status;
        uint hashOfDetails; // hash of the off-chain details of data
        bool transferred;
    }

    address chairpersonAddr;
    mapping (address => uint) membership;
    mapping (address => Details) public balanceDetails;

    constructor() public payable {
        chairpersonAddr = msg.sender;
        membership[msg.sender] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    function register() public payable {
        address airline = msg.sender;
        membership[airline] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    function unregister(address payable airline) public isMember isChairperson {
        if (membership[airline] != 1) {
            revert();
        }

        membership[airline] = 0;
        // return escrow to leaving airline: other conditions may be verified
        airline.transfer(balanceDetails[airline].escrow);
        balanceDetails[airline].escrow = 0;
    }

    function request(address dstAirline, uint hashOfDetails) public isMember {
        if (membership[dstAirline] != 1){
            revert();
        }

        balanceDetails[msg.sender].status = 0;
        balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
    }

    function response(address srcAirline, uint hashOfDetails, uint status) public isMember {
        if (membership[srcAirline] != 1){
            revert();
        }

        balanceDetails[msg.sender].status = status;
        balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
    }

    function settlePayment(address payable dstAirline) public payable isMember {
        address srcAirline = msg.sender;
        uint amt = msg.value;

        balanceDetails[dstAirline].escrow += amt;
        balanceDetails[srcAirline].escrow -= amt;
        dstAirline.transfer(amt);
    }


    modifier isChairperson {
        require(msg.sender == chairpersonAddr);
        _;
    }

    modifier isMember {
        require(membership[msg.sender] == 1);
        _;
    }

}