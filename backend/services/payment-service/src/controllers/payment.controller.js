const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');
const axios = require('axios');

const paymentController = {
  initiatePayment: async (req, res) => {
    try {
      const { accountId, amount, paymentMethod, description } = req.body;

      const result = await pool.query(
        'INSERT INTO payments (account_id, amount, payment_method, status, description, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
        [accountId, amount, paymentMethod, 'INITIATED', description]
      );

      logger.info(`Payment initiated: ${result.rows[0].id}`);
      res.status(201).json(result.rows[0]);
    } catch (error) {
      logger.error(`Initiate payment error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  confirmPayment: async (req, res) => {
    try {
      const { paymentId, otp } = req.body;

      // TODO: Verify OTP

      const result = await pool.query(
        'UPDATE payments SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
        ['CONFIRMED', paymentId]
      );

      logger.info(`Payment confirmed: ${paymentId}`);
      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Confirm payment error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getPaymentStatus: async (req, res) => {
    try {
      const { paymentId } = req.params;

      const result = await pool.query(
        'SELECT * FROM payments WHERE id = $1',
        [paymentId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Get payment status error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getPaymentHistory: async (req, res) => {
    try {
      const { accountId, limit = 50, offset = 0 } = req.query;

      const result = await pool.query(
        'SELECT * FROM payments WHERE account_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
        [accountId, limit, offset]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Get payment history error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = paymentController;
