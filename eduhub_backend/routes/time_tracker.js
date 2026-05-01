const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

// Start time tracking
router.post('/start', auth, async (req, res) => {
  try {
    const userId = req.user.id; // This comes from the auth middleware (PostgreSQL user ID)
    const firebaseUid = req.user.firebase_uid; // Firebase UID from database

    // Check if there's already an active tracking session
    const activeSessionQuery = `
      SELECT id FROM time_tracker 
      WHERE user_id = $1 AND end_time IS NULL
    `;
    const activeSession = await pool.query(activeSessionQuery, [userId]);

    if (activeSession.rows.length > 0) {
      return res.status(400).json({ 
        error: 'You already have an active tracking session' 
      });
    }

    // Start new tracking session
    const insertQuery = `
      INSERT INTO time_tracker (user_id, start_time)
      VALUES ($1, NOW())
      RETURNING id, user_id, start_time
    `;
    
    const result = await pool.query(insertQuery, [userId]);
    
    console.log('Time tracking started:', {
      userId: userId,
      firebaseUid: firebaseUid,
      sessionId: result.rows[0].id,
      startTime: result.rows[0].start_time
    });

    res.status(201).json({
      message: 'Time tracking started',
      session: result.rows[0]
    });
  } catch (error) {
    console.error('Start tracking error:', error.message);
    res.status(500).json({ error: 'Failed to start time tracking' });
  }
});

// End time tracking
router.post('/end', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    // Find active tracking session
    const activeSessionQuery = `
      SELECT id, start_time FROM time_tracker 
      WHERE user_id = $1 AND end_time IS NULL
      ORDER BY start_time DESC LIMIT 1
    `;
    const activeSession = await pool.query(activeSessionQuery, [userId]);

    if (activeSession.rows.length === 0) {
      return res.status(400).json({ 
        error: 'No active tracking session found' 
      });
    }

    const session = activeSession.rows[0];

    // End the tracking session
    const updateQuery = `
      UPDATE time_tracker 
      SET end_time = NOW(),
          spend_time = NOW() - start_time
      WHERE id = $1 AND user_id = $2
      RETURNING id, user_id, start_time, end_time, spend_time
    `;
    
    const result = await pool.query(updateQuery, [session.id, userId]);
    
    console.log('Time tracking ended:', {
      userId: userId,
      sessionId: result.rows[0].id,
      startTime: result.rows[0].start_time,
      endTime: result.rows[0].end_time,
      spendTime: result.rows[0].spend_time
    });

    res.json({
      message: 'Time tracking ended',
      session: result.rows[0]
    });
  } catch (error) {
    console.error('End tracking error:', error.message);
    res.status(500).json({ error: 'Failed to end time tracking' });
  }
});

// Get tracking history for a user
router.get('/history', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 50, offset = 0 } = req.query;

    const historyQuery = `
      SELECT id, start_time, end_time, spend_time, created_at
      FROM time_tracker 
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3
    `;
    
    const result = await pool.query(historyQuery, [userId, limit, offset]);

    res.json({
      sessions: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Get history error:', error.message);
    res.status(500).json({ error: 'Failed to get tracking history' });
  }
});

// Get current active session
router.get('/active', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    const activeSessionQuery = `
      SELECT id, start_time
      FROM time_tracker 
      WHERE user_id = $1 AND end_time IS NULL
      ORDER BY start_time DESC LIMIT 1
    `;
    
    const result = await pool.query(activeSessionQuery, [userId]);

    if (result.rows.length === 0) {
      return res.json({ activeSession: null });
    }

    res.json({
      activeSession: result.rows[0]
    });
  } catch (error) {
    console.error('Get active session error:', error.message);
    res.status(500).json({ error: 'Failed to get active session' });
  }
});

// Get total time spent today
router.get('/total-today', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    const totalTodayQuery = `
      SELECT SUM(EXTRACT(EPOCH FROM spend_time)) as total_seconds
      FROM time_tracker 
      WHERE user_id = $1 
        AND DATE(start_time) = CURRENT_DATE
        AND spend_time IS NOT NULL
    `;
    
    const result = await pool.query(totalTodayQuery, [userId]);
    const totalSeconds = Math.floor(result.rows[0].total_seconds || 0);

    // Format the time as hours, minutes, seconds
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    let formattedTime = '';
    if (hours > 0) {
      formattedTime = `${hours}h ${minutes}m ${seconds}s`;
    } else if (minutes > 0) {
      formattedTime = `${minutes}m ${seconds}s`;
    } else {
      formattedTime = `${seconds}s`;
    }

    res.json({
      totalSeconds: totalSeconds,
      formattedTime: formattedTime,
      timeSpent: {
        hours: hours,
        minutes: minutes,
        seconds: seconds
      }
    });
  } catch (error) {
    console.error('Get total today error:', error.message);
    res.status(500).json({ error: 'Failed to get total time spent today' });
  }
});

module.exports = router;
