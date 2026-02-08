const express = require('express');
const accountController = require('../controllers/account.controller');

const router = express.Router();

router.post('/', accountController.createAccount);
router.get('/', accountController.getAccounts);
router.get('/:accountId', accountController.getAccountById);
router.put('/:accountId', accountController.updateAccount);
router.delete('/:accountId', accountController.closeAccount);
router.get('/:accountId/balance', accountController.getAccountBalance);

module.exports = router;
