// db.js
const mysql =  require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'Snow@mubas1',
  database: 'elections',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
