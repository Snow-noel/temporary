const express = require('express');
const Router = require('./routes/Router');

const app = express();

app.use('/', Router);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: '404 Not Found' });
});

app.listen(3000, () => {
  console.log(`Server is running on port 3000`);
});