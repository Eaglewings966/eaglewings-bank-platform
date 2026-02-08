require('dotenv').config();
const express = require('express');
const logger = require('../../shared/logger');
const paymentRoutes = require('./routes/payment.routes');
const { authMiddleware } = require('./middleware/auth.middleware');

const app = express();
const PORT = process.env.PORT || 3004;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

app.use('/api/payments', authMiddleware, paymentRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'Payment Service is running' });
});

app.listen(PORT, () => {
  logger.info(`Payment Service started on port ${PORT}`);
});

module.exports = app;
