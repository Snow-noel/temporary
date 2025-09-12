const express = require('express');
const dotenv = require('dotenv');
const Router = require('./routes/Router');

dotenv.config();
const app = express();

app.use('/', Router);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: '404 Not Found' });
});

app.listen(process.env.PORT, () => {
  console.log(`Server is running on port ${process.env.PORT}`);
});