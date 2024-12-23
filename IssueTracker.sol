pragma solidity ^0.8.2 <0.9.0;

contract IssueTracker {
    enum Status { ACTIVE, IN_PROGRESS, COMPLETE, CLOSED }

    struct Issue {
        uint issueId;
        string description;
        Status status;
    }

    mapping(uint => Issue) private issueList;

    function addIssue(uint issueId, string memory description, uint statusIndex) external {
        require(statusIndex < 4, "Invalid status index"); 
        issueList[issueId] = Issue(issueId, description, Status(statusIndex));
    }

    function updateIssueStatus(uint issueId, uint newStatusIndex) external {
        require(issueList[issueId].issueId != 0, "Issue does not exist");

        Status currentStatus = issueList[issueId].status;
        require(newStatusIndex < 4, "Invalid new status");

        if (currentStatus == Status.ACTIVE && newStatusIndex != uint(Status.IN_PROGRESS)) {
            revert("ACTIVE can only be updated to IN_PROGRESS");
        } else if (currentStatus == Status.IN_PROGRESS && newStatusIndex != uint(Status.COMPLETE)) {
            revert("IN_PROGRESS can only be updated to COMPLETE");
        } else if (currentStatus == Status.COMPLETE && newStatusIndex != uint(Status.CLOSED)) {
            revert("COMPLETE can only be updated to CLOSED");
        } else if (currentStatus == Status.CLOSED) {
            revert("CLOSED status cannot be updated further");
        }

        issueList[issueId].status = Status(newStatusIndex);
    }

    function getIssue(uint issueId) external view returns (Issue memory) {
        require(issueList[issueId].issueId != 0, "Issue does not exist");
        return issueList[issueId];
    }
}
