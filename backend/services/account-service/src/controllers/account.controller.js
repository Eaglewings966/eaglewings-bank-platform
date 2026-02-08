const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');

const accountController = {
  createAccount: async (req, res) => {
    try {
      const { accountType, initialBalance } = req.body;
      const userId = req.user.id;

      const result = await pool.query(
        'INSERT INTO accounts (user_id, account_type, balance, created_at) VALUES ($1, $2, $3, NOW()) RETURNING *',
        [userId, accountType, initialBalance || 0]
      );

      logger.info(`Account created for user ${userId}`);
      res.status(201).json(result.rows[0]);
    } catch (error) {
      logger.error(`Create account error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getAccounts: async (req, res) => {
    try {
      const userId = req.user.id;

      const result = await pool.query(
        'SELECT * FROM accounts WHERE user_id = $1 AND is_active = true',
        [userId]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Get accounts error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getAccountById: async (req, res) => {
    try {
      const { accountId } = req.params;
      const userId = req.user.id;

      const result = await pool.query(
        'SELECT * FROM accounts WHERE id = $1 AND user_id = $2',
        [accountId, userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Account not found' });
      }

      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Get account error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  updateAccount: async (req, res) => {
    try {
      const { accountId } = req.params;
      const { accountType } = req.body;
      const userId = req.user.id;

      const result = await pool.query(
        'UPDATE accounts SET account_type = $1 WHERE id = $2 AND user_id = $3 RETURNING *',
        [accountType, accountId, userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Account not found' });
      }

      logger.info(`Account ${accountId} updated`);
      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Update account error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  closeAccount: async (req, res) => {
    try {
      const { accountId } = req.params;
      const userId = req.user.id;

      const result = await pool.query(
        'UPDATE accounts SET is_active = false WHERE id = $1 AND user_id = $2 RETURNING *',
        [accountId, userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Account not found' });
      }

      logger.info(`Account ${accountId} closed`);
      res.json({ message: 'Account closed successfully' });
    } catch (error) {
      logger.error(`Close account error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getAccountBalance: async (req, res) => {
    try {
      const { accountId } = req.params;
      const userId = req.user.id;

      const result = await pool.query(
        'SELECT balance FROM accounts WHERE id = $1 AND user_id = $2',
        [accountId, userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Account not found' });
      }

      res.json({ accountId, balance: result.rows[0].balance });
    } catch (error) {
      logger.error(`Get balance error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = accountController;
