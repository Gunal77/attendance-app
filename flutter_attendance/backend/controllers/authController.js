const crypto = require('crypto');
const bcrypt = require('bcrypt');
const db = require('../config/db');
const { signToken } = require('../utils/jwt');

const normalizeEmail = (email = '') => email.trim().toLowerCase();

const createUser = async (email, password) => {
  const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [email]);
  if (existingUser.rows.length) {
    const error = new Error('Email already registered');
    error.status = 409;
    throw error;
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const userId = crypto.randomUUID();

  const { rows } = await db.query(
    'INSERT INTO users (id, email, password_hash) VALUES ($1, $2, $3) RETURNING id, email',
    [userId, email, passwordHash],
  );

  return rows[0];
};

const register = async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const password = req.body.password?.trim();

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const user = await createUser(email, password);
    return res.status(201).json({ user });
  } catch (error) {
    console.error('Register error', error);
    return res
      .status(error.status || 500)
      .json({ message: error.status ? error.message : 'Failed to register user' });
  }
};

const signup = async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const password = req.body.password?.trim();

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const user = await createUser(email, password);
    const token = signToken({ id: user.id, email: user.email });

    return res.status(201).json({
      token,
      user,
    });
  } catch (error) {
    console.error('Signup error', error);
    return res
      .status(error.status || 500)
      .json({ message: error.status ? error.message : 'Failed to sign up user' });
  }
};

const login = async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const password = req.body.password?.trim();

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const { rows } = await db.query('SELECT id, email, password_hash FROM users WHERE email = $1', [email]);
    if (!rows.length) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = signToken({ id: user.id, email: user.email });

    return res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (error) {
    console.error('Login error', error);
    return res.status(500).json({ message: 'Failed to login user' });
  }
};

module.exports = {
  register,
  login,
  signup,
};

