const express = require('express');
const paymentController = require('../controllers/payment.controller');

const router = express.Router();

router.post('/initiate', paymentController.initiatePayment);
router.post('/confirm', paymentController.confirmPayment);
router.get('/status/:paymentId', paymentController.getPaymentStatus);
router.get('/history', paymentController.getPaymentHistory);

module.exports = router;
