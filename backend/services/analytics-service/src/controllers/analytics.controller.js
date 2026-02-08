const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');

const analyticsController = {
  getUserActivity: async (req, res) => {
    try {
      const { userId, days = 30 } = req.query;

      const result = await pool.query(
        `SELECT 
          DATE(created_at) as date, 
          COUNT(*) as transaction_count 
        FROM transactions 
        WHERE (from_account_id IN (SELECT id FROM accounts WHERE user_id = $1) OR 
               to_account_id IN (SELECT id FROM accounts WHERE user_id = $1))
        AND created_at > NOW() - INTERVAL '${days} days'
        GROUP BY DATE(created_at)
        ORDER BY date DESC`,
        [userId]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`User activity error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getTransactionSummary: async (req, res) => {
    try {
      const { userId, period = 'MONTH' } = req.query;

      const result = await pool.query(
        `SELECT 
          transaction_type,
          COUNT(*) as count,
          SUM(amount) as total_amount,
          AVG(amount) as avg_amount
        FROM transactions
        WHERE (from_account_id IN (SELECT id FROM accounts WHERE user_id = $1) OR 
               to_account_id IN (SELECT id FROM accounts WHERE user_id = $1))
        GROUP BY transaction_type`,
        [userId]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Transaction summary error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getAccountAnalytics: async (req, res) => {
    try {
      const { userId } = req.query;

      const result = await pool.query(
        `SELECT 
          a.id,
          a.account_type,
          a.balance,
          COUNT(t.id) as transaction_count,
          MAX(t.created_at) as last_transaction
        FROM accounts a
        LEFT JOIN transactions t ON a.id = t.from_account_id OR a.id = t.to_account_id
        WHERE a.user_id = $1
        GROUP BY a.id, a.account_type, a.balance`,
        [userId]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Account analytics error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  generateReport: async (req, res) => {
    try {
      const { userId, startDate, endDate, reportType } = req.query;

      // TODO: Generate comprehensive report based on reportType

      res.json({
        message: 'Report generated successfully',
        reportType,
        startDate,
        endDate,
        userId
      });
    } catch (error) {
      logger.error(`Generate report error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = analyticsController;
