const express = require('express');
const notificationController = require('../controllers/notification.controller');

const router = express.Router();

router.post('/send-email', notificationController.sendEmail);
router.post('/send-sms', notificationController.sendSMS);
router.get('/history/:userId', notificationController.getNotificationHistory);
router.put('/preferences/:userId', notificationController.updatePreferences);

module.exports = router;
