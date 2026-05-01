const pool = require('../config/database');



// Initialize Database - Create table if not exists

const initDatabase = async () => {

  const createUsersTableQuery = `

    CREATE TABLE IF NOT EXISTS "eduUsers" (

      id SERIAL PRIMARY KEY,

      firebase_uid VARCHAR(255) UNIQUE,

      first_name VARCHAR(100) NOT NULL,

      last_name VARCHAR(100) NOT NULL,

      email VARCHAR(255) UNIQUE NOT NULL,

      password VARCHAR(255) NOT NULL,

      role VARCHAR(20) DEFAULT 'student',

      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    );

  `;

  const createTimeTrackerTableQuery = `

    CREATE TABLE IF NOT EXISTS time_tracker (

      id SERIAL PRIMARY KEY,

      user_id INTEGER REFERENCES eduUsers(id) ON DELETE CASCADE,

      start_time TIMESTAMP NOT NULL,

      end_time TIMESTAMP,

      spend_time INTERVAL,

      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    );

  `;

  try {

    await pool.query(createUsersTableQuery);

    await pool.query(createTimeTrackerTableQuery);

    console.log('Database tables eduUsers and time_tracker initialized');

  } catch (error) {

    console.error('Error initializing database:', error.message);

  }

};



module.exports = { initDatabase };

