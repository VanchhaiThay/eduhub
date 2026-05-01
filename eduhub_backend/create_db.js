const { Pool } = require('pg');
require('dotenv').config();

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'VaKS83CA',
};

// Superuser pool for system 'postgres' DB
const superPool = new Pool({ ...config, database: 'postgres' });

async function createDatabaseAndTables() {
  let client;
  try {
    client = await superPool.connect();
    
    // Create database
    await client.query(`CREATE DATABASE "eduUsers" OWNER postgres;`);
    console.log('✅ Database "eduUsers" created successfully');
    
    // Close superuser connection
    client.release();
    await superPool.end();
    
    // Now connect to new DB and create table/indexes
    const appPool = new Pool({ ...config, database: 'eduUsers' });
    const tableClient = await appPool.connect();
    
    // Create table
    await tableClient.query(`
      CREATE TABLE IF NOT EXISTS edu_user (
        id SERIAL PRIMARY KEY,
        firebase_uid VARCHAR(255) UNIQUE,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(20) DEFAULT 'student',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    // Indexes
    await tableClient.query('CREATE INDEX IF NOT EXISTS idx_edu_user_email ON edu_user(email);');
    await tableClient.query('CREATE INDEX IF NOT EXISTS idx_edu_user_firebase_uid ON edu_user(firebase_uid);');
    
    console.log('✅ edu_user table and indexes created');
    
    tableClient.release();
    await appPool.end();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (client) client.release();
  }
}

createDatabaseAndTables();
