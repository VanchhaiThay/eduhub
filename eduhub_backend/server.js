const express = require('express');
require('dotenv').config();

// Import modules
const { setupMiddleware } = require('./middleware');
const { initDatabase } = require('./utils/db');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const timeTrackerRoutes = require('./routes/time_tracker');
const assignmentRoutes = require('./routes/assignments');
// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Setup middleware
setupMiddleware(app);

// Setup routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/time-tracker', timeTrackerRoutes);
app.use('/api/assignments', assignmentRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'EduHub API is running' });
});

// Start server
app.listen(PORT, async () => {
  await initDatabase();
  console.log(`Server running on port ${PORT}`);
});