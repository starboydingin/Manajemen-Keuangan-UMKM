const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const { error: sendError } = require('./utils/http');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_, res) => res.json({ status: 'ok' }));
app.use('/api/v1', routes);

// fallback route
app.use((req, res) => {
  return sendError(res, 'Route not found', 404);
});

// centralized error handler
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  return sendError(res, message, status, err.details);
});

module.exports = app;
