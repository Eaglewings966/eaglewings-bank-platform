require('dotenv').config();
const express = require('express');
const logger = require('../../shared/logger');
const accountRoutes = require('./routes/account.routes');
const { authMiddleware } = require('./middleware/auth.middleware');

const app = express();
const PORT = process.env.PORT || 3002;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

app.use('/api/accounts', authMiddleware, accountRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'Account Service is running' });
});

app.listen(PORT, () => {
  logger.info(`Account Service started on port ${PORT}`);
});

module.exports = app;
