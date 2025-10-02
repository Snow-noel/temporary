const pool = require('../lib/db')

// percentage of unregistered females
export async function getUnregisteredFemalePercentage() {
  try {
    const [rows] = await pool.query(`
        SELECT 
        `
    );

    if (rows.length > 0) {
      const unregisteredFemales = rows[0].UnregisteredFemales;
      const totalFemales = rows[0].TotalFemales;

      const percentage = (unregisteredFemales / totalFemales) * 100;
      return percentage.toFixed(2); // Return percentage with two decimal places
    } else {
      return null; // if no data is found
    }
  } catch (error) {
    console.error('Error fetching unregistered female percentage:', error);
    throw error;
  }
}

// percentage of unregistered males
export async function getUnregisteredMalePercentage() {
  try {
    const [rows] = await pool.query(
      `SELECT 
        (SELECT COUNT(*) FROM Person WHERE Gender = 'Male' AND Registered = ) AS UnregisteredMales,
        (SELECT COUNT(*) FROM Person WHERE Gender = 'Male') AS TotalMales`
    );

    if (rows.length > 0) {
      const unregisteredMales = rows[0].UnregisteredMales;
      const totalMales = rows[0].TotalMales;

      const percentage = (unregisteredMales / totalMales) * 100;
      return percentage.toFixed(2); // Return percentage with two decimal places
    } else {
      return null; // if no data is found
    }
  } catch (error) {
    console.error('Error fetching unregistered male percentage:', error);
    throw error;
  }
}


// 1. Percentage of unregistered females
export async function getUnregisteredFemalePercentage() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) AS UnregisteredFemales,
        COUNT(*) AS TotalFemales,
        ROUND((COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) / COUNT(*)) * 100, 2) AS Percentage
      FROM Person p
      JOIN Voter v ON p.PersonalID = v.PersonalID
      WHERE p.Gender = 'Female'
    `);

    return rows[0] || null;
  } catch (error) {
    console.error('Error fetching unregistered female percentage:', error);
    throw error;
  }
}

// 2. Percentage of unregistered males
export async function getUnregisteredMalePercentage() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) AS UnregisteredMales,
        COUNT(*) AS TotalMales,
        ROUND((COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) / COUNT(*)) * 100, 2) AS Percentage
      FROM Person p
      JOIN Voter v ON p.PersonalID = v.PersonalID
      WHERE p.Gender = 'Male'
    `);

    return rows[0] || null;
  } catch (error) {
    console.error('Error fetching unregistered male percentage:', error);
    throw error;
  }
}

// 3. Find all winning candidates in one table
export async function getAllWinningCandidates() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        p.FirstName,
        p.LastName,
        p.Gender,
        pp.PartyName,
        cand.Position,
        c.ConstituencyName,
        vote_counts.TotalVotes,
        e.ElectionType,
        e.ElectionYear
      FROM Candidate cand
      JOIN Person p ON cand.PersonalID = p.PersonalID
      LEFT JOIN PoliticalParty pp ON cand.PartyID = pp.PartyID
      LEFT JOIN Constituency c ON cand.ConstituencyID = c.ConstituencyID
      JOIN (
        SELECT 
          ce.CandidateID,
          ce.ElectionID,
          COUNT(*) as TotalVotes,
          ROW_NUMBER() OVER (
            PARTITION BY cand2.Position, cand2.ConstituencyID, ce2.ElectionID 
            ORDER BY COUNT(*) DESC
          ) as rank_num
        FROM Vote v
        JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
        JOIN CandidateElection ce2 ON ce.CandidateElectionID = ce2.CandidateElectionID
        JOIN Candidate cand2 ON ce.CandidateID = cand2.CandidateID
        GROUP BY ce.CandidateID, ce.ElectionID, cand2.Position, cand2.ConstituencyID
      ) vote_counts ON cand.CandidateID = vote_counts.CandidateID
      JOIN Election e ON vote_counts.ElectionID = e.ElectionID
      WHERE vote_counts.rank_num = 1
      ORDER BY cand.Position, c.ConstituencyName
    `);

    return rows;
  } catch (error) {
    console.error('Error fetching winning candidates:', error);
    throw error;
  }
}

// 4. Percentage of candidates that did not register as voters
export async function getUnregisteredCandidatesPercentage() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        COUNT(CASE WHEN v.Status = 'Not Registered' OR v.PersonalID IS NULL THEN 1 END) AS UnregisteredCandidates,
        COUNT(*) AS TotalCandidates,
        ROUND((COUNT(CASE WHEN v.Status = 'Not Registered' OR v.PersonalID IS NULL THEN 1 END) / COUNT(*)) * 100, 2) AS Percentage
      FROM Candidate c
      JOIN Person p ON c.PersonalID = p.PersonalID
      LEFT JOIN Voter v ON p.PersonalID = v.PersonalID
    `);

    return rows[0] || null;
  } catch (error) {
    console.error('Error fetching unregistered candidates percentage:', error);
    throw error;
  }
}

// 5. Number and percentage of Null and Void votes per ward
// Note: Since your Vote table doesn't have VoteType, this assumes you'll add it or track invalid votes differently
export async function getNullVoidVotesPerWard() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        w.WardName,
        d.DistrictName,
        -- For now, counting total votes per ward
        -- You'll need to modify this based on how you track null/void votes
        COUNT(*) AS TotalVotes,
        0 AS NullVotes, -- Placeholder - modify based on your null vote tracking
        0 AS VoidVotes, -- Placeholder - modify based on your void vote tracking
        0 AS TotalNullVoidVotes,
        0.00 AS NullVotePercentage,
        0.00 AS VoidVotePercentage,
        0.00 AS TotalNullVoidPercentage
      FROM Vote v
      JOIN Voter voter ON v.VoterID = voter.VoterID
      JOIN Ward w ON voter.WardID = w.WardID
      JOIN District d ON w.DistrictID = d.DistrictID
      GROUP BY w.WardID, w.WardName, d.DistrictName
      ORDER BY d.DistrictName, w.WardName
    `);

    return rows;
  } catch (error) {
    console.error('Error fetching null and void votes per ward:', error);
    throw error;
  }
}

// 6. Female voters voting for female candidates vs Male voters voting for male candidates
export async function getGenderVotingPatterns() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        'Female voters for female candidates' AS VotingPattern,
        COUNT(*) AS VoteCount,
        ROUND((COUNT(*) / (
          SELECT COUNT(*) 
          FROM Vote v2 
          JOIN Voter voter2 ON v2.VoterID = voter2.VoterID 
          JOIN Person p2 ON voter2.PersonalID = p2.PersonalID 
          WHERE p2.Gender = 'Female'
        )) * 100, 2) AS Percentage
      FROM Vote v
      JOIN Voter voter ON v.VoterID = voter.VoterID
      JOIN Person voter_person ON voter.PersonalID = voter_person.PersonalID
      JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
      JOIN Candidate cand ON ce.CandidateID = cand.CandidateID
      JOIN Person cand_person ON cand.PersonalID = cand_person.PersonalID
      WHERE voter_person.Gender = 'Female' AND cand_person.Gender = 'Female'
      
      UNION ALL
      
      SELECT 
        'Male voters for male candidates' AS VotingPattern,
        COUNT(*) AS VoteCount,
        ROUND((COUNT(*) / (
          SELECT COUNT(*) 
          FROM Vote v2 
          JOIN Voter voter2 ON v2.VoterID = voter2.VoterID 
          JOIN Person p2 ON voter2.PersonalID = p2.PersonalID 
          WHERE p2.Gender = 'Male'
        )) * 100, 2) AS Percentage
      FROM Vote v
      JOIN Voter voter ON v.VoterID = voter.VoterID
      JOIN Person voter_person ON voter.PersonalID = voter_person.PersonalID
      JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
      JOIN Candidate cand ON ce.CandidateID = cand.CandidateID
      JOIN Person cand_person ON cand.PersonalID = cand_person.PersonalID
      WHERE voter_person.Gender = 'Male' AND cand_person.Gender = 'Male'
      
      UNION ALL
      
      SELECT 
        'Female voters for male candidates' AS VotingPattern,
        COUNT(*) AS VoteCount,
        ROUND((COUNT(*) / (
          SELECT COUNT(*) 
          FROM Vote v2 
          JOIN Voter voter2 ON v2.VoterID = voter2.VoterID 
          JOIN Person p2 ON voter2.PersonalID = p2.PersonalID 
          WHERE p2.Gender = 'Female'
        )) * 100, 2) AS Percentage
      FROM Vote v
      JOIN Voter voter ON v.VoterID = voter.VoterID
      JOIN Person voter_person ON voter.PersonalID = voter_person.PersonalID
      JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
      JOIN Candidate cand ON ce.CandidateID = cand.CandidateID
      JOIN Person cand_person ON cand.PersonalID = cand_person.PersonalID
      WHERE voter_person.Gender = 'Female' AND cand_person.Gender = 'Male'
      
      UNION ALL
      
      SELECT 
        'Male voters for female candidates' AS VotingPattern,
        COUNT(*) AS VoteCount,
        ROUND((COUNT(*) / (
          SELECT COUNT(*) 
          FROM Vote v2 
          JOIN Voter voter2 ON v2.VoterID = voter2.VoterID 
          JOIN Person p2 ON voter2.PersonalID = p2.PersonalID 
          WHERE p2.Gender = 'Male'
        )) * 100, 2) AS Percentage
      FROM Vote v
      JOIN Voter voter ON v.VoterID = voter.VoterID
      JOIN Person voter_person ON voter.PersonalID = voter_person.PersonalID
      JOIN CandidateElection ce ON v.CandidateElectionID = ce.CandidateElectionID
      JOIN Candidate cand ON ce.CandidateID = cand.CandidateID
      JOIN Person cand_person ON cand.PersonalID = cand_person.PersonalID
      WHERE voter_person.Gender = 'Male' AND cand_person.Gender = 'Female'
    `);

    return rows;
  } catch (error) {
    console.error('Error fetching gender voting patterns:', error);
    throw error;
  }
}

// 7. Summary statistics for dashboard
export async function getElectionSummary() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM Person p JOIN Voter v ON p.PersonalID = v.PersonalID WHERE v.Status = 'Registered') AS TotalRegisteredVoters,
        (SELECT COUNT(*) FROM Person p JOIN Voter v ON p.PersonalID = v.PersonalID WHERE v.Status = 'Not Registered') AS TotalUnregisteredPersons,
        (SELECT COUNT(*) FROM Candidate) AS TotalCandidates,
        (SELECT COUNT(*) FROM Vote) AS TotalVotes,
        (SELECT COUNT(*) FROM Constituency) AS TotalConstituencies,
        (SELECT COUNT(*) FROM Ward) AS TotalWards,
        (SELECT COUNT(*) FROM District) AS TotalDistricts,
        (SELECT COUNT(*) FROM Election) AS TotalElections
    `);

    return rows[0] || null;
  } catch (error) {
    console.error('Error fetching election summary:', error);
    throw error;
  }
}