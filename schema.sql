CREATE TABLE Person (
    PersonalID INT PRIMARY KEY AUTO_INCREMENT,
    NationalID VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male','Female') NOT NULL
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
    ConstituencyID INT NOT NULL,
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
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

-- View for election results
CREATE VIEW ElectionResults AS
SELECT 
    e.ElectionID,
    e.ElectionType,
    c.CandidateID,
    p.FirstName,
    p.LastName,
    pp.PartyName,
    COUNT(v.VoteID) AS TotalVotes
FROM Vote v
JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
JOIN Candidate c ON ce.CandidateID = c.CandidateID
JOIN Person p ON c.PersonalID = p.PersonalID
LEFT JOIN PoliticalParty pp ON c.PartyID = pp.PartyID
JOIN Election e ON ce.ElectionID = e.ElectionID
GROUP BY e.ElectionID, c.CandidateID;
