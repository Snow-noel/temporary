CREATE TABLE Person (
    PersonalID INT PRIMARY KEY AUTO_INCREMENT,
    RegNumber VARCHAR(20) UNIQUE NOT NULL,
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
    UNIQUE (IssuedToVoterID, ElectionID)
);

CREATE TABLE ElectionAudit (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    ElectionID INT NOT NULL,
    AuditDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Description TEXT,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);

CREATE TABLE SecurityForce (
    ForceID INT PRIMARY KEY AUTO_INCREMENT,
    ForceName ENUM('Police','Army','Other') NOT NULL,
    ContactInfo VARCHAR(150)
);

INSERT INTO Person ( RegNumber, FirstName, LastName, Gender, RegistrationDate) VALUES
    ('BIS/23/SS/001', 'INNOCENT', 'CHAIMA', 'Male', '2025-03-07'),
    ('BIS/23/SS/002', 'CLIFFORD', 'CHIBALE', 'Male', '2025-03-26'),
    ('BIS/23/SS/003', 'BIZIWICK', 'CHIKUMBUTSO', 'Male', '2025-03-07'),
    ('BIS/23/SS/004', 'IDAH', 'CHILONGO', 'Female', '2025-03-12'),
    ('BIS/23/SS/005', 'MABLE', 'CHINGOTA', 'Female', '2025-03-05'),
    ('BIS/22/SS/003', 'ANNA', 'CHIVUNDULA', 'Female', '2025-03-05'),
    ('BIS/23/SS/007', 'ANNIE', 'CHIWONI', 'Female', '2025-02-25'),
    ('BIS/23/SS/010', 'CHAULA', 'JULIUS', 'Male', '2025-02-20'),
    ('BIS/22/SS/011', 'ANGELIQUE', 'KALANJE', 'Female', '2025-03-09'),
    ('BIS/22/SS/014', 'CHISOMO', 'KANTSITSI', 'Female', '2025-03-04'),
    ('BIS/23/SS/012', 'ENOCK', 'KAPHUKUSI', 'Male', '2025-03-06'),
    ('BIS/23/SS/013', 'SANDRA', 'KASIRA', 'Female', '2025-03-12'),
    ('BIS/22/SS/015', 'ALINAFE', 'KATANTHA', 'Female', '2025-03-12'),
    ('BIS/23/SS/015', 'ANGELLA', 'KHOMBA', 'Female', '2025-03-06'),
    ('BIS/23/SS/016', 'LUMBANI', 'LUHANGA', 'Male', '2025-03-05'),
    ('BIS/23/SS/017', 'YANKHO', 'MAJAMANDA', 'Female', '2025-03-12'),
    ('BIS/23/SS/018', 'Jonathan', 'MAKHULUDZO', 'Male', '2025-03-07'),
    ('BIS/22/SS/017', 'PAULINE', 'MALONDA', 'Female', '2025-03-14'),
    ('BIS/23/SS/020', 'DINGILE', 'MANDERE', 'Female', '2025-03-04'),
    ('BIS/22/SS/021', 'ACKIM', 'MHONE', 'Male', '2025-03-10'),
    ('BIS/23/SS/023', 'BLIX', 'MPUWE', 'Male', '2025-03-12'),
    ('BIS/23/SS/024', 'SNOWDEN', 'MSUMBA', 'Male', '2025-03-05'),
    ('BIS/22/ET/007', 'DOREEN', 'MTAMBO', 'Female', '2025-03-14'),
    ('BIS/23/SS/028', 'HUGGINS', 'Mukwindidza', 'Male', '2025-02-25'),
    ('BIS/22/SS/024', 'MIRIAM', 'MULERA', 'Female', '2025-03-18'),
    ('BIS/23/SS/026', 'LAULYN', 'MWASE', 'Female', '2025-03-06'),
    ('BIS/23/SS/027', 'ONGANI', 'MWASE', 'Male', '2025-03-12'),
    ('BIS/23/SS/025', 'JOYCE', 'MWASE', 'Female', '2025-03-12'),
    ('BIS/23/SS/030', 'SAMSON', 'PHANGULA', 'Male', '2025-03-12'),
    ('BIS/22/SS/034', 'HELLEN', 'PHIRI', 'Female', '2025-03-06'),
    ('BIS/23/SS/032', 'PATIENCE', 'PHIRI', 'Female', '2025-02-18'),
    ('BIS/23/SS/031', 'CHANJU', 'PHIRI', 'Female', '2025-03-21'),
    ('BIS/23/SS/033', 'ANNIE', 'RICHARD', 'Female', '2025-03-12'),
    ('BIS/23/SS/034', 'JOHN', 'SAMBANI', 'Male', '2025-03-05'),
    ('BIS/23/SS/036', 'AYANDA', 'SIMBEYE', 'Female', '2025-02-20'),
    ('BIS/23/SS/037', 'CAROLINE', 'SINJA', 'Female', '2025-04-11'),
    ('BIS/23/SS/038', 'LOYCE', 'SITOLO', 'Female', '2025-03-10'),
    ('BIS/22/SS/036', 'TREVOR', 'SOKO', 'Male', '2025-03-10'),
    ('BIS/23/SS/039', 'GEOFFREY', 'THINDWA', 'Male', '2025-03-29'),
    ('BIS/23/SS/040', 'BRIAN', 'YONA', 'Male', '2025-02-21'),
    ('BIT/23/SS/001', 'HOPE', 'ANDREW', 'Male', '2025-03-14'),
    ('BIT/23/SS/002', 'Charles', 'BANDA', 'Male', '2025-03-05'),
    ('BIT/22/SS/001', 'HANNAH', 'BOKO', 'Female', '2025-03-31'),
    ('BIT/23/SS/003', 'EUNICE', 'CHIPETA', 'Female', '2025-02-26'),
    ('BIT/21/SS/007', 'GLORY', 'CHIPUNGU', 'Female', '2025-03-14'),
    ('BIT/23/SS/005', 'WILSON', 'CHIRWA', 'Male', '2025-03-06'),
    ('BIT/23/SS/004', 'SHANIE', 'CHIRWA', 'Female', '2025-03-12'),
    ('BIT/23/SS/006', 'MWIZA', 'GONDWE', 'Female', '2025-02-19'),
    ('BIEP/23/SS/011', 'PATRICIA', 'HARRY', 'Female', '2025-03-14'),
    ('BIT/23/SS/010', 'MIRRIAM', 'KALANDA', 'Female', '2025-03-05'),
    ('BIT/23/SS/011', 'TIYANJANE', 'KAMDZEKA', 'Female', '2025-03-12'),
    ('BIT/23/SS/012', 'CEDRIC', 'KAMENI', 'Male', '2025-02-20'),
    ('BIT/23/SS/013', 'TENDAI', 'KAMWAMBA', 'Male', '2025-03-11'),
    ('BIT/23/SS/014', 'LISSA', 'KAPONDA', 'Female', '2025-03-12'),
    ('BIT/23/SS/015', 'LAWRENCE', 'KOLOKO', 'Male', '2025-03-05'),
    ('BIT/23/SS/016', 'WONGANI', 'KONDOWE', 'Male', '2025-03-11'),
    ('BIT/23/SS/017', 'LASTON', 'KUMWENDA', 'Male', '2025-03-14'),
    ('BIT/23/SS/018', 'ELLEN', 'LIRADALA', 'Female', '2025-03-14'),
    ('BIT/22/SS/018', 'CHISOMO', "M'BAWA", 'Female', '2025-03-12'),
    ('BIT/23/SS/020', 'MERCY', 'MAKIYI', 'Female', '2025-03-28'),
    ('BIT/23/SS/021', 'JOLEEN', 'MAKONDETSA', 'Female', '2025-03-06'),
    ('BIT/23/SS/022', 'PRINCE', 'MANDALA', 'Male', '2025-03-05'),
    ('BIT/23/SS/023', 'THOMAS', "MANONG'A", 'Male', '2025-02-28'),
    ('BIT/23/SS/025', 'TUPOCHELE', 'MDEZA', 'Male', '2025-03-18'),
    ('BIT/23/SS/026', 'VERA', 'MHANGO', 'Female', '2025-03-10'),
    ('BIT/23/SS/044', 'ENOCK', 'MHURA', 'Male', '2025-03-05'),
    ('BIT/23/SS/027', 'CHECK-US', 'MKANDAWIRE', 'Male', '2025-03-05'),
    ('BIT/23/SS/028', 'MSAYIWALE', 'MOYA', 'Male', '2025-03-07'),
    ('BIT/23/SS/030', 'LAURENCIA', 'MSEU', 'Female', '2025-04-01'),
    ('BIT/23/SS/032', 'GIFT', 'MTHUZI', 'Male', '2025-03-11'),
    ('BIT/22/SS/023', 'LUSAKO', 'MWAKALENGA', 'Male', '2025-03-12'),
    ('BIT/23/SS/033', 'TIMOTHY', 'MWAMONDWE', 'Male', '2025-03-09'),
    ('BIT/23/SS/036', 'WONGANI', 'PHIRI', 'Male', '2025-03-05'),
    ('BIT/23/SS/037', 'UWICYEZA', 'SAIDAT', 'Female', '2025-03-03'),
    ('BIT/23/SS/038', 'PEREZ', 'SAKA', 'Male', '2025-03-04'),
    ('BIT/23/SS/040', 'TILIKA', 'TATYANA', 'Female', '2025-03-05'),
    ('BIT/23/SS/041', 'MIKE', 'TILINGAMAWA', 'Male', '2025-03-12'),
    ('BIT/23/SS/042', 'DALITSO', 'YAKOBE', 'Male', '2025-03-05'),
    ('BIS/24/ME/144', 'TIONGE', 'BANDA', 'Female', '2025-03-22'),
    ('BIS/24/ME/145', 'MAYAMIKO', 'CHIGWEDE', 'Male', '2025-02-26'),
    ('BIS/24/ME/146', 'BERTHA', 'CHIKUMBU', 'Female', '2025-02-27'),
    ('BIS/24/ME/147', 'GOMEZGANI', 'CHIRWA', 'Male', '2025-02-19'),
    ('BIS/24/ME/148', 'EDDIE', 'GOCHO', 'Male', '2025-02-22'),
    ('BIS/24/ME/150', 'BLESSINGS', 'MKANDAWIRE', 'Male', '2025-02-25'),
    ('BIS/24/ME/151', 'MPHATSO', 'MLEME', 'Male', '2025-05-07'),
    ('BIS/24/ME/152', 'SAMUEL', 'MPANDO', 'Male', '2025-02-28'),
    ('BIS/24/ME/153', 'WANANGWA', 'MULENGA', 'Male', '2025-02-21'),
    ('BIS/24/ME/154', 'KATIE', 'MUNTHALI', 'Female', '2025-02-18'),
    ('BIS/24/ME/155', 'LUPAKISHO', 'MUSUKWA', 'Male', '2025-02-18'),
    ('BIS/24/ME/156', 'THULANI', 'MZEMBE', 'Male', '2025-02-19'),
    ('BIS/24/ME/159', 'NOEL', 'SAFARAWO', 'Male', '2025-03-21'),
    ('BIS/24/ME/160', 'SAM', 'THEU', 'Male', '2025-02-28'),
    ('BIT/24/ME/006', 'ISHAQ', 'ASSIMA', 'Male', '2025-02-23'),
    ('BIT/23/ME/050', 'CHAWANANGWA', 'CHIKUNI', 'Male', '2025-02-21'),
    ('BIT/24/ME/007', 'AUGUSTINE', 'KACHINGWE', 'Male', '2025-02-18'),
    ('BIT/24/ME/010', 'VICTOR', 'MANDAWALA', 'Male', '2025-03-12'),
    ('BIT/24/ME/011', 'RODNEY', 'MASEKO', 'Male', '2025-02-18'),
    ('BIT/24/ME/014', 'THANDIWE', 'PHIRI', 'Female', '2025-02-19'),
    ('BIT/24/ME/015', 'MICHEAL', 'SAMBAKUSI', 'Male', '2025-02-21'),
    ('MSE/21/SS/001', 'CHISOMO', 'AFFONSO', 'Male', '2025-03-05'),
    ('MSE/23/ME/002', 'ALEX', 'CHAKWANIRA', 'Male', '2025-02-18'),
    ('MSE/21/SS/004', 'MELVIN', 'CHIKANAMOYO', 'Male', '2025-03-05'),
    ('MSE/23/ME/004', 'Juwadu', 'Juma', 'Male', '2025-02-25'),
    ('MSE/21/SS/016', 'WATIPA', 'KALULU', 'Female', '2025-03-06'),
    ('MSE/21/SS/017', "ANGEL", "KAM'BWEMBA", 'Female', '2025-03-05'),
    ('MSE/19/SS/014', 'MCNAIR', 'KAMANGA', 'Male', '2025-03-05'),
    ('MSE/21/SS/020', 'ALINAFE', 'KUMILAMBE', 'Female', '2025-03-02'),
    ('MSE/21/SS/022', 'SHARON', 'KWAITANA', 'Female', '2025-02-19'),
    ('MSE/21/SS/023', 'JENIFER', 'MAGWAZA', 'Female', '2025-03-06'),
    ('MSE/21/SS/026', 'HAJRA', 'MASUNGU', 'Female', '2025-03-06'),
    ('MSE/21/SS/029', 'PYPHIAS', 'MHONE', 'Male', '2025-03-05'),
    ('MSE/21/SS/035', 'FRANK', 'MWAKASUNGULA', 'Male', '2025-03-05'),
    ('MSE/21/SS/040', 'VYSON', 'NSINI', 'Male', '2025-03-06'),
    ('MSE/21/SS/045', 'INNOCENT', 'PHIRI', 'Male', '2025-03-06'),
    ('MSE/21/SS/047', 'SINOYA', 'PHIRI', 'Male', '2025-03-06'),
    ('MSE/21/SS/046', 'RICHARD', 'PHIRI', 'Male', '2025-03-06'),
    ('MSE/20/SS/033', 'SAYNAT', 'SINJONJO', 'Female', '2025-03-05'),
    ('MSE/20/SS/035', 'RABECCA', 'TEMBO', 'Female', '2025-03-12'),
    ('BIT/24/ME/012', 'KENNEDY', 'MKANDAWIRE', 'Male', '2025-02-18'),
    ('BIT/23/ME/069', 'GRACIOUS', 'NGUWO', 'Male', '2025-05-07');
