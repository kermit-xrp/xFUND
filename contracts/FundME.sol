
contract FundME {

  // Events

  event ProjectCreated(uint256 projectId, address creator, string projectName, uint256 fundingGoal, uint256 deadline);
  event ContributionReceived(uint256 projectId, address contributor, uint256 amount);
  event ProjectFunded(uint256 projectId);
  event ProjectFailed(uint256 projectId);

  // Structures

  struct Project {
    string projectName;
    uint256 fundingGoal;
    uint256 deadline;
    uint256 amountRaised;
    address creator;
    mapping(address => bool) contributors;
  }

  // State variables

  uint256 public nextProjectId;
  mapping(uint256 => Project) public projects;

  // Functions

  function createProject(string memory projectName, uint256 fundingGoal, uint256 deadline) public {
    require(projectName.length > 0, "Project name must be non-empty");
    require(fundingGoal > 0, "Funding goal must be greater than 0");
    require(deadline > 0, "Deadline must be greater than 0");

    uint256 projectId = nextProjectId++;
    projects[projectId] = Project(projectName, fundingGoal, deadline, 0, msg.sender);

    emit ProjectCreated(projectId, msg.sender, projectName, fundingGoal, deadline);
  }

  function contribute(uint256 projectId, uint256 amount) public payable {
    require(projects[projectId].deadline > block.timestamp, "Project is no longer accepting contributions");
    require(amount > 0, "Amount must be greater than 0");

    projects[projectId].amountRaised += amount;
    projects[projectId].contributors[msg.sender] = true;

    emit ContributionReceived(projectId, msg.sender, amount);
  }

  function fundProject(uint256 projectId) public {
    require(projects[projectId].amountRaised >= projects[projectId].fundingGoal, "Project has not met funding goal");

    projects[projectId].creator.transfer(address(this).balance);

    emit ProjectFunded(projectId);
  }

  function failProject(uint256 projectId) public {
    require(projects[projectId].amountRaised < projects[projectId].fundingGoal, "Project has met funding goal");

    for (address contributor in projects[projectId].contributors) {
      contributor.transfer(msg.sender.balance);
    }

    emit ProjectFailed(projectId);
  }
}

