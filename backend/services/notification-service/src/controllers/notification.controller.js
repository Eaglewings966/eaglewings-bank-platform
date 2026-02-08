const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');

const notificationController = {
  sendEmail: async (req, res) => {
    try {
      const { userId, email, subject, body } = req.body;

      // TODO: Integrate with email service (SendGrid, AWS SES, etc.)

      const result = await pool.query(
        'INSERT INTO notifications (user_id, type, recipient, subject, body, status, created_at) VALUES ($1, $2, $3, $4, $5, $6, NOW()) RETURNING *',
        [userId, 'EMAIL', email, subject, body, 'SENT']
      );

      logger.info(`Email sent to ${email}`);
      res.json({ message: 'Email sent successfully', notification: result.rows[0] });
    } catch (error) {
      logger.error(`Send email error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  sendSMS: async (req, res) => {
    try {
      const { userId, phoneNumber, message } = req.body;

      // TODO: Integrate with SMS service (Twilio, AWS SNS, etc.)

      const result = await pool.query(
        'INSERT INTO notifications (user_id, type, recipient, body, status, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
        [userId, 'SMS', phoneNumber, message, 'SENT']
      );

      logger.info(`SMS sent to ${phoneNumber}`);
      res.json({ message: 'SMS sent successfully', notification: result.rows[0] });
    } catch (error) {
      logger.error(`Send SMS error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  getNotificationHistory: async (req, res) => {
    try {
      const { userId } = req.params;
      const { limit = 50, offset = 0 } = req.query;

      const result = await pool.query(
        'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
        [userId, limit, offset]
      );

      res.json(result.rows);
    } catch (error) {
      logger.error(`Get notification history error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  updatePreferences: async (req, res) => {
    try {
      const { userId } = req.params;
      const { emailNotifications, smsNotifications, pushNotifications } = req.body;

      const result = await pool.query(
        'UPDATE notification_preferences SET email_enabled = $1, sms_enabled = $2, push_enabled = $3 WHERE user_id = $4 RETURNING *',
        [emailNotifications, smsNotifications, pushNotifications, userId]
      );

      logger.info(`Preferences updated for user ${userId}`);
      res.json(result.rows[0]);
    } catch (error) {
      logger.error(`Update preferences error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = notificationController;
