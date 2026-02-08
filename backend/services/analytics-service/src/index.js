require('dotenv').config();
const express = require('express');
const logger = require('../../shared/logger');
const analyticsRoutes = require('./routes/analytics.routes');
const { authMiddleware } = require('./middleware/auth.middleware');

const app = express();
const PORT = process.env.PORT || 3006;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

app.use('/api/analytics', authMiddleware, analyticsRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'Analytics Service is running' });
});

app.listen(PORT, () => {
  logger.info(`Analytics Service started on port ${PORT}`);
});

module.exports = app;
