const express = require('express');
const pool = require('../config/database');

const router = express.Router();

// Get all users
router.get('/', async (req, res) => {
  try {
    const query = 'SELECT id, firebase_uid, first_name, last_name, email, role, created_at FROM "eduUsers"';
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Get all users error:', error.message);
    res.status(500).json({ error: 'Failed to get users' });
  }
});

// Get user by Firebase UID
router.get('/:firebaseUid', async (req, res) => {
  try {
    const { firebaseUid } = req.params;
    const query = 'SELECT id, firebase_uid, first_name, last_name, email, role, created_at FROM "eduUsers" WHERE firebase_uid = $1';
    const result = await pool.query(query, [firebaseUid]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get user error:', error.message);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// Update user by Firebase UID
router.put('/:firebaseUid', async (req, res) => {
  try {
    const { firebaseUid } = req.params;
    const { firstName, lastName } = req.body;

    // Validate that at least one field is provided
    if (!firstName && !lastName) {
      return res.status(400).json({ error: 'At least one field (firstName or lastName) is required' });
    }

    // Build dynamic update query
    let updateFields = [];
    let updateValues = [];
    let paramIndex = 1;

    if (firstName) {
      updateFields.push(`first_name = $${paramIndex}`);
      updateValues.push(firstName);
      paramIndex++;
    }

    if (lastName) {
      updateFields.push(`last_name = $${paramIndex}`);
      updateValues.push(lastName);
      paramIndex++;
    }

    // Add firebaseUid to values array
    updateValues.push(firebaseUid);

    const query = `
      UPDATE "eduUsers" 
      SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE firebase_uid = $${paramIndex}
      RETURNING id, firebase_uid, first_name, last_name, email, role, created_at, updated_at;
    `;

    const result = await pool.query(query, updateValues);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Log successful update to terminal
    const user = result.rows[0];
    console.log('✅ USER UPDATE SUCCESS');
    console.log('------------------------');
    console.log(`User ID: ${user.id}`);
    console.log(`Name: ${user.first_name} ${user.last_name}`);
    console.log(`Email: ${user.email}`);
    console.log(`Firebase UID: ${user.firebase_uid}`);
    console.log(`Role: ${user.role}`);
    console.log(`Updated At: ${user.updated_at}`);
    console.log('------------------------');

    res.json({
      message: 'User updated successfully',
      user: result.rows[0]
    });
  } catch (error) {
    console.error('Update user error:', error.message);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

module.exports = router;
