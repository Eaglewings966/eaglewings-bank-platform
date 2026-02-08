const express = require('express');
const transactionController = require('../controllers/transaction.controller');

const router = express.Router();

router.post('/transfer', transactionController.transfer);
router.post('/deposit', transactionController.deposit);
router.post('/withdraw', transactionController.withdraw);
router.get('/history', transactionController.getTransactionHistory);
router.get('/:transactionId', transactionController.getTransactionById);

module.exports = router;
