const pool = require('../config/database');

// Authentication middleware for protected routes
const auth = async (req, res, next) => {
  try {
    // Get user ID from the request (this should come from client after login)
    const userId = req.headers['x-user-id'];
    
    if (!userId) {
      return res.status(401).json({ error: 'User ID required' });
    }

    // Verify user exists in database
    const query = 'SELECT id, firebase_uid, email FROM "eduUsers" WHERE id = $1';
    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }

    // Attach user info to request
    req.user = {
      id: result.rows[0].id,
      firebase_uid: result.rows[0].firebase_uid,
      email: result.rows[0].email
    };

    next();
  } catch (error) {
    console.error('Auth middleware error:', error.message);
    res.status(500).json({ error: 'Authentication failed' });
  }
};

module.exports = auth;
