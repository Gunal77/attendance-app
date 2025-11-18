const db = require('../config/db');
const { verifyToken } = require('../utils/jwt');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');

  if (!token || scheme !== 'Bearer') {
    return res.status(401).json({ message: 'Authorization header missing or malformed' });
  }

  try {
    const decoded = verifyToken(token);
    const { rows } = await db.query('SELECT id, email FROM users WHERE id = $1', [decoded.id]);

    if (!rows.length) {
      return res.status(401).json({ message: 'User not found' });
    }

    req.user = rows[0];
    return next();
  } catch (error) {
    console.error('Auth middleware error', error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;

