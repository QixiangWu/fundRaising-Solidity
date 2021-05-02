pragma solidity ^0.4.17;

contract cfCampaignFactory {
    
    address[] public deployedCampaigns;
    
    function createCampaign(uint minDonation) public {
        address newCampaign = new cfCampaign(minDonation, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaigns() public view returns(address[]) {
        return deployedCampaigns;
    }
}


contract cfCampaign {
    
    struct SpendingReq {
        string brief;
        uint value;
        address recipient;
        bool completeStatus;
        mapping(address=>bool) approvals;
        uint approvalCount;
    }
    
    address public fundRaiser;
    uint public minDonation;
    mapping(address=>bool) public contributors;
    SpendingReq[] public requests;
    uint public contributorsCount;
    
    function cfCampaign(uint minAmount, address myAccount) public payable {
        fundRaiser = myAccount;
        minDonation = minAmount;
    }
    
        modifier restricted() {
        require(msg.sender == fundRaiser);
        _;
    }
    
    function donate() public payable {
        require(msg.value>minDonation);
        contributors[msg.sender]=true;
        contributorsCount++;
    }
    
    function newRequest(string brief, uint value, address recipient) public restricted {
        SpendingReq memory myRequest = SpendingReq({
            brief : brief,
            value : value,
            recipient : recipient,
            completeStatus : false,
            approvalCount : 0
        });
        
        requests.push(myRequest);
    }
    
    function approvalRequest(uint index) public {
        SpendingReq storage request = requests[index];
        
        require(contributors[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    
    function finalizeRequest(uint index) public restricted {
        
        SpendingReq storage request = requests[index];
        
        require(request.approvalCount > (contributorsCount / 2));
        require(!request.completeStatus);
        
        request.recipient.transfer(request.value);
        request.completeStatus = true;
    }
}
