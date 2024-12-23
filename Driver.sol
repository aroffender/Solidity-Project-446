pragma solidity ^0.8.2 < 0.9.0;

import "./IssueTracker.sol";  

contract Driver {
    IssueTracker private issueTracker;

    function setIssueTrackerAddress(address issueTrackerAddress) external {
        issueTracker = IssueTracker(issueTrackerAddress);
    }

    function refAddIssue(uint issueId, string memory description, uint statusIndex) external {
        issueTracker.addIssue(issueId, description, statusIndex);
    }

    function refUpdateIssueStatus(uint issueId, uint newStatusIndex) external {
        issueTracker.updateIssueStatus(issueId, newStatusIndex);
    }

    function getIssue(uint issueId) external view returns (uint, string memory, IssueTracker.Status) {
        IssueTracker.Issue memory issue = issueTracker.getIssue(issueId);
        return (issue.issueId, issue.description, issue.status);
    }
}
