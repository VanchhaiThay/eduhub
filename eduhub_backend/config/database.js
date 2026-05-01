const { Pool } = require('pg');
require('dotenv').config();

// PostgreSQL Connection Pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'eduUsers',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'VaKS83CA',
});

module.exports = pool;
