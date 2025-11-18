const { verifyToken } = require('../utils/jwt');

const adminAuthMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');

  if (!token || scheme !== 'Bearer') {
    return res.status(401).json({ message: 'Authorization header missing or malformed' });
  }

  try {
    const decoded = verifyToken(token);

    if (decoded.role !== 'admin') {
      return res.status(403).json({ message: 'Admin privileges required' });
    }

    req.admin = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role,
    };
    return next();
  } catch (error) {
    console.error('Admin auth error', error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = adminAuthMiddleware;


