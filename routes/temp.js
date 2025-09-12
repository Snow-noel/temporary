// index.js
const express = require('express');
const pool = require('./lib/db');
require('dotenv').config();

const app = express();
app.use(express.json());

app.get('/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM users'); // raw SQL
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

app.post('/users', async (req, res) => {
  const { name, email } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO users (name, email) VALUES (?, ?)',
      [name, email]
    );
    res.json({ id: result.insertId, name, email });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
