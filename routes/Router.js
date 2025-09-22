const express = require('express');
const router = express.Router();
const pool = require('../lib/db')

router.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Home Page' });
});

// cast vote
router.post('/cast-vote', async (req, res) =>{
  const {VoterId, CandidateElectionID, 
    ElectionID, PollingStationID
  } = req.body;

  try {
    const [result] = await pool.query(
      'INSERT INTO vote (VoterId, CandidateElectionID, ElectionID, PollingStationID) VALUES (?, ?, ?, ?)',
      [VoterId, CandidateElectionID, 
       ElectionID, PollingStationID]
    )
    res.status(200).json({msg: 'success'});
  } catch (error) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }

})


module.exports = router;