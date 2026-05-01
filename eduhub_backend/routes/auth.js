const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../config/database');

const router = express.Router();

// Signup endpoint - Store user in PostgreSQL
router.post('/signup', async (req, res) => {
  try {
    const { firebaseUid, firstName, lastName, email, password, role } = req.body;

    // Validate required fields
    if (!firebaseUid || !firstName || !lastName || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user into PostgreSQL
    const query = `
      INSERT INTO "eduUsers" (firebase_uid, first_name, last_name, email, password, role)
      VALUES ($1, $2, $3, $4, $5, $6)
      ON CONFLICT (email) DO UPDATE SET
        firebase_uid = EXCLUDED.firebase_uid,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        role = EXCLUDED.role
      RETURNING id, firebase_uid, first_name, last_name, email, role, created_at;
    `;

    const values = [firebaseUid, firstName, lastName, email.toLowerCase(), hashedPassword, role || 'student'];
    const result = await pool.query(query, values);

    // Log successful signup to terminal
    const user = result.rows[0];
    console.log('✅ USER SIGNUP SUCCESS');
    console.log('------------------------');
    console.log(`User ID: ${user.id}`);
    console.log(`Name: ${user.first_name} ${user.last_name}`);
    console.log(`Email: ${user.email}`);
    console.log(`Firebase UID: ${user.firebase_uid}`);
    console.log(`Role: ${user.role}`);
    console.log(`Created At: ${user.created_at}`);
    console.log('------------------------');

    res.status(201).json({
      message: 'User created successfully',
      user: result.rows[0]
    });
  } catch (error) {
    console.error('Signup error:', error.message);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Login endpoint - Verify user credentials
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const query = 'SELECT * FROM "eduUsers" WHERE email = $1';
    const result = await pool.query(query, [email.toLowerCase()]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        firebaseUid: user.firebase_uid,
        firstName: user.first_name,
        lastName: user.last_name,
        email: user.email,
        role: user.role,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    console.error('Login error:', error.message);
    res.status(500).json({ error: 'Failed to login' });
  }
});

module.exports = router;
