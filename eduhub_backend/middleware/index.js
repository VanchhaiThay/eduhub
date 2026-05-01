const express = require('express');
const cors = require('cors');

// Setup middleware
const setupMiddleware = (app) => {
  app.use(cors());
  app.use(express.json());
};

module.exports = { setupMiddleware };
