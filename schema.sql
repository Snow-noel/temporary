CREATE TABLE Person (
    PersonalID INT PRIMARY KEY AUTO_INCREMENT,
    NationalID VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(20) NOT NULL
);

CREATE TABLE District (
    DistrictID INT PRIMARY KEY AUTO_INCREMENT,
    DistrictName VARCHAR(100) NOT NULL
);

CREATE TABLE Ward (
    WardID INT PRIMARY KEY AUTO_INCREMENT,
    WardName VARCHAR(100) NOT NULL,
    DistrictID INT NOT NULL,
    FOREIGN KEY (DistrictID) REFERENCES District(DistrictID)
);

CREATE TABLE Constituency (
    ConstituencyID INT PRIMARY KEY AUTO_INCREMENT,
    ConstituencyName VARCHAR(100) NOT NULL,
    DistrictID INT NOT NULL,
    FOREIGN KEY (DistrictID) REFERENCES District(DistrictID)
);

CREATE TABLE WardConstituency (
    WardID INT NOT NULL,
    ConstituencyID INT NOT NULL,
    PRIMARY KEY (WardID, ConstituencyID),
    FOREIGN KEY (WardID) REFERENCES Ward(WardID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
);

-- polling station table
CREATE TABLE PollingStation (
    PollingStationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100) NOT NULL,
    Location VARCHAR(255),
    WardID INT NOT NULL,
    FOREIGN KEY (WardID) REFERENCES Ward(WardID)
);

-- voter table
CREATE TABLE Voter (
    VoterID INT PRIMARY KEY AUTO_INCREMENT,
    PersonalID INT UNIQUE NOT NULL,
    VoterRegistrationNumber VARCHAR(30) UNIQUE NOT NULL,
    Status ENUM('Registered','Not Registered') NOT NULL,
    RegistrationDate DATE NOT NULL,
    Category VARCHAR(50),
    ConstituencyID INT NOT NULL,
    WardID INT,
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID),
    FOREIGN KEY (WardID) REFERENCES Ward(WardID)
);

-- political party table
CREATE TABLE PoliticalParty (
    PartyID INT PRIMARY KEY AUTO_INCREMENT,
    PartyName VARCHAR(100) NOT NULL,
    PartySymbol VARCHAR(50)
);

-- candidate table
CREATE TABLE Candidate (
    CandidateID INT PRIMARY KEY AUTO_INCREMENT,
    PersonalID INT UNIQUE NOT NULL,
    PartyID INT,
    Position ENUM('President','MP','Councillor') NOT NULL,
    ConstituencyID INT NULL,  -- Only needed for MPs/Councillors
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID),
    FOREIGN KEY (PartyID) REFERENCES PoliticalParty(PartyID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
);

-- elections
CREATE TABLE Election (
    ElectionID INT PRIMARY KEY AUTO_INCREMENT,
    ElectionType ENUM('Presidential','Parliamentary','Local') NOT NULL,
    ElectionYear INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

CREATE TABLE CandidateElection (
    CandidateElectionID INT PRIMARY KEY AUTO_INCREMENT,
    CandidateID INT NOT NULL,
    ElectionID INT NOT NULL,
    BallotSymbol VARCHAR(50),
    FOREIGN KEY (CandidateID) REFERENCES Candidate(CandidateID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);

-- votes table
CREATE TABLE Vote (
    VoteID INT PRIMARY KEY AUTO_INCREMENT,
    VoterID INT NOT NULL,
    CandidateElectionID INT NOT NULL,
    ElectionID INT NOT NULL,
    Timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PollingStationID INT NOT NULL,
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID),
    FOREIGN KEY (CandidateElectionID) REFERENCES CandidateElection(CandidateElectionID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    FOREIGN KEY (PollingStationID) REFERENCES PollingStation(PollingStationID),
    UNIQUE(VoterID, ElectionID) 
);
CREATE TABLE ElectionOfficial (
    OfficialID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Role ENUM('Presiding Officer','Clerk','Security') NOT NULL,
    PollingStationID INT NOT NULL,
    FOREIGN KEY (PollingStationID) REFERENCES PollingStation(PollingStationID)
);
CREATE TABLE Ballot (
    BallotID INT PRIMARY KEY AUTO_INCREMENT,
    ElectionID INT NOT NULL,
    PollingStationID INT NOT NULL,
    IssuedToVoterID INT NOT NULL,
    IssuedTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    FOREIGN KEY (PollingStationID) REFERENCES PollingStation(PollingStationID),
    FOREIGN KEY (IssuedToVoterID) REFERENCES Voter(VoterID),
    UNIQUE (IssuedToVoterID, ElectionID) -- prevent duplicate ballot issuance
);
CREATE TABLE ElectionComplaint (
    ComplaintID INT PRIMARY KEY AUTO_INCREMENT,
    ElectionID INT NOT NULL,
    FiledBy VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('Pending','Reviewed','Resolved') DEFAULT 'Pending',
    FiledDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);
CREATE TABLE ElectionAudit (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    ElectionID INT NOT NULL,
    AuditDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Description TEXT,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);
CREATE TABLE PartyOffice (
    OfficeID INT PRIMARY KEY AUTO_INCREMENT,
    PartyID INT NOT NULL,
    Location VARCHAR(255) NOT NULL, 
    DistrictID INT NOT NULL,
    FOREIGN KEY (PartyID) REFERENCES PoliticalParty(PartyID),
    FOREIGN KEY (DistrictID) REFERENCES District(DistrictID)
);
CREATE TABLE Campaign (
    CampaignID INT PRIMARY KEY AUTO_INCREMENT,
    CandidateID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Budget DECIMAL(12,2),
    FOREIGN KEY (CandidateID) REFERENCES Candidate(CandidateID)
);
CREATE TABLE SecurityForce (
    ForceID INT PRIMARY KEY AUTO_INCREMENT,
    ForceName ENUM('Police','Army','Other') NOT NULL,
    ContactInfo VARCHAR(150)
);
