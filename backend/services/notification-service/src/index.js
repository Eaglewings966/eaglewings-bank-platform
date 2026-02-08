require('dotenv').config();
const express = require('express');
const logger = require('../../shared/logger');
const notificationRoutes = require('./routes/notification.routes');
const { authMiddleware } = require('./middleware/auth.middleware');

const app = express();
const PORT = process.env.PORT || 3005;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

app.use('/api/notifications', notificationRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'Notification Service is running' });
});

app.listen(PORT, () => {
  logger.info(`Notification Service started on port ${PORT}`);
});

module.exports = app;
