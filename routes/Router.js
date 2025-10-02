const express = require('express');
const router = express.Router();
const pool = require('../lib/db')
const { getUnregisteredFemalePercentage } = require('../models/electroModels');

router.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Home Page' });
});

// percentage of unregistered females
router.get('/unregistered-females', async (req, res) => {
  try {
    const percentage = await getUnregisteredFemalePercentage();
    res.json({ percentage: percentage });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
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