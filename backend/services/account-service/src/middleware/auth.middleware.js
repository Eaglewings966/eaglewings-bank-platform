const { verifyToken } = require('../../../shared/auth');
const logger = require('../../../shared/logger');

const authMiddleware = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    logger.error(`Auth error: ${error.message}`);
    res.status(401).json({ error: 'Invalid token' });
  }
};

module.exports = { authMiddleware };
