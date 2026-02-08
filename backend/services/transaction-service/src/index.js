require('dotenv').config();
const express = require('express');
const logger = require('../../shared/logger');
const transactionRoutes = require('./routes/transaction.routes');
const { authMiddleware } = require('./middleware/auth.middleware');

const app = express();
const PORT = process.env.PORT || 3003;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

app.use('/api/transactions', authMiddleware, transactionRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'Transaction Service is running' });
});

app.listen(PORT, () => {
  logger.info(`Transaction Service started on port ${PORT}`);
});

module.exports = app;
