const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');

const transactionController = {
  transfer: async (req, res) => {
    try {
      const { fromAccountId, toAccountId, amount } = req.body;

      const result = await pool.query(
        'INSERT INTO transactions (from_account_id, to_account_id, amount, transaction_type, status, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
        [fromAccountId, toAccountId, amount, 'TRANSFER', 'COMPLETED']
      );

      logger.info(`Transfer processed: ${fromAccountId} -> ${toAccountId}`);
      res.status(201).json(result.rows[0]);
    } catch (error) {
      logger.error(`Transfer error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  deposit: async (req, res) => {
    try {
      const { accountId, amount } = req.body;

      const result = await pool.query(
        'INSERT INTO transactions (to_account_id, amount, transaction_type, status, created_at) VALUES ($1, $2, $3, $4, NOW()) RETURNING *',
        [accountId, amount, 'DEPOSIT', 'COMPLETED']
      );

      logger.info(`Deposit processed: ${accountId}`);
      res.status(201).json(result.rows[0]);
    } catch (error) {
      logger.error(`Deposit error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  withdraw: async (req, res) => {
    try {
      const { accountId, amount } = req.body;

      const result = await pool.query(
        'INSERT INTO transactions (from_account_id, amount, transaction_type, status, created_at) VALUES ($1, $2, $3, $4, NOW()) RETURNING *',
        [accountId, amount, 'WITHDRAWAL', 'COMPLETED']
      );

      logger.info(`Withdrawal processed: ${accountId}`);
      res.status(201).json(result.rows[0]);
    } catch (error) {
      logger.error(`Withdrawal error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getTransactionHistory: async (req, res) => {
    try {
      const { accountId, limit = 50, offset = 0 } = req.query;

      const result = await pool.query(
        'SELECT * FROM transactions WHERE from_account_id = $1 OR to_account_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
        [accountId, limit, offset]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Get history error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getTransactionById: async (req, res) => {
    try {
      const { transactionId } = req.params;

      const result = await pool.query(
        'SELECT * FROM transactions WHERE id = $1',
        [transactionId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Transaction not found' });
      }

      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Get transaction error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = transactionController;
