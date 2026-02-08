const bcrypt = require('bcryptjs');
const { generateToken, generateRefreshToken } = require('../../../shared/auth');
const pool = require('../../../shared/database');
const logger = require('../../../shared/logger');

const authController = {
  // Register new user
  register: async (req, res) => {
    try {
      const { email, password, firstName, lastName } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert user into database
      const result = await pool.query(
        'INSERT INTO users (email, password_hash, first_name, last_name, created_at) VALUES ($1, $2, $3, $4, NOW()) RETURNING id, email, first_name, last_name',
        [email, hashedPassword, firstName, lastName]
      );

      const user = result.rows[0];
      const token = generateToken({ id: user.id, email: user.email });

      logger.info(`User registered: ${email}`);

      res.status(201).json({
        message: 'User registered successfully',
        user,
        token
      });
    } catch (error) {
      logger.error(`Registration error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Login user
  login: async (req, res) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      // Get user from database
      const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      const user = result.rows[0];

      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Compare password
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);

      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const token = generateToken({ id: user.id, email: user.email });
      const refreshToken = generateRefreshToken({ id: user.id });

      logger.info(`User logged in: ${email}`);

      res.json({
        message: 'Login successful',
        user: { id: user.id, email: user.email, firstName: user.first_name, lastName: user.last_name },
        token,
        refreshToken
      });
    } catch (error) {
      logger.error(`Login error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Refresh token
  refreshToken: async (req, res) => {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({ error: 'Refresh token is required' });
      }

      const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
      const user = result.rows[0];

      const newToken = generateToken({ id: user.id, email: user.email });

      res.json({ token: newToken });
    } catch (error) {
      logger.error(`Refresh token error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Get user profile
  getProfile: async (req, res) => {
    try {
      const result = await pool.query('SELECT id, email, first_name, last_name, created_at FROM users WHERE id = $1', [req.user.id]);
      const user = result.rows[0];

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json(user);
    } catch (error) {
      logger.error(`Get profile error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Change password
  changePassword: async (req, res) => {
    try {
      const { oldPassword, newPassword } = req.body;

      const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
      const user = result.rows[0];

      const isPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);

      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Old password is incorrect' });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await pool.query('UPDATE users SET password_hash = $1 WHERE id = $2', [hashedPassword, req.user.id]);

      logger.info(`Password changed for user: ${user.email}`);

      res.json({ message: 'Password changed successfully' });
    } catch (error) {
      logger.error(`Change password error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Logout
  logout: async (req, res) => {
    try {
      logger.info(`User logged out: ${req.user.email}`);
      res.json({ message: 'Logout successful' });
    } catch (error) {
      logger.error(`Logout error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Verify token
  verifyToken: (req, res) => {
    res.json({ message: 'Token is valid', user: req.user });
  },

  // Forgot password
  forgotPassword: async (req, res) => {
    try {
      const { email } = req.body;

      const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      // TODO: Send reset password email

      logger.info(`Forgot password request for: ${email}`);

      res.json({ message: 'Check your email for password reset instructions' });
    } catch (error) {
      logger.error(`Forgot password error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  },

  // Reset password
  resetPassword: async (req, res) => {
    try {
      const { token, newPassword } = req.body;

      // TODO: Verify reset token

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // TODO: Update password with reset token validation

      res.json({ message: 'Password reset successfully' });
    } catch (error) {
      logger.error(`Reset password error: ${error.message}`);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = authController;
