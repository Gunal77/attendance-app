const jwt = require('jsonwebtoken');
const env = require('../config/env');

const DEFAULT_EXPIRY = '7d';

const signToken = (payload, options = {}) =>
  jwt.sign(payload, env.jwtSecret, { expiresIn: DEFAULT_EXPIRY, ...options });

const verifyToken = (token) => jwt.verify(token, env.jwtSecret);

module.exports = {
  signToken,
  verifyToken,
};

