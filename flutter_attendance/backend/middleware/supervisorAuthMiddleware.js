const jwt = require('jsonwebtoken');
const env = require('../config/env');

const supervisorAuthMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, env.jwtSecret);

    if (decoded.role !== 'supervisor') {
      return res.status(403).json({ message: 'Supervisor access required' });
    }

    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }
    console.error('Auth middleware error', err);
    return res.status(500).json({ message: 'Authentication error' });
  }
};

module.exports = supervisorAuthMiddleware;

