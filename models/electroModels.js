const pool = require('../lib/db')

// Percentage of unregistered females
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

// Percentage of unregistered males
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

// Percentage of candidates that did not register as voters
export async function getUnregisteredCandidatesPercentage() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) AS UnregisteredCandidates,
        COUNT(*) AS TotalCandidates,
        ROUND((COUNT(CASE WHEN v.Status = 'Not Registered' THEN 1 END) / COUNT(*)) * 100, 2) AS Percentage
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