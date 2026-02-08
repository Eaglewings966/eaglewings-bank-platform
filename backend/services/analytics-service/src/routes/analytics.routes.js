const express = require('express');
const analyticsController = require('../controllers/analytics.controller');

const router = express.Router();

router.get('/user-activity', analyticsController.getUserActivity);
router.get('/transaction-summary', analyticsController.getTransactionSummary);
router.get('/account-analytics', analyticsController.getAccountAnalytics);
router.get('/reports', analyticsController.generateReport);

module.exports = router;
