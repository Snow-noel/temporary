const mysql =  require('mysql2/promise');

export const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'Snow@mubas1',
  database: 'Elections',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
