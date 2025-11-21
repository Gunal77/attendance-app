const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const { supabase } = require('../config/supabaseClient');
const env = require('../config/env');

const router = express.Router();

// POST /supervisor/auth/login - Supervisor login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const normalizedEmail = email.toString().trim().toLowerCase();

    const { data: supervisor, error } = await supabase
      .from('supervisors')
      .select('*')
      .eq('email', normalizedEmail)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch supervisor' });
    }

    if (!supervisor) {
      return res.status(401).json({ message: 'Supervisor not found' });
    }

    const passwordMatch = await bcrypt.compare(password, supervisor.password_hash);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: supervisor.id, role: 'supervisor', email: supervisor.email },
      env.jwtSecret,
      { expiresIn: '7d' },
    );

    return res.json({
      token,
      message: 'Login successful',
      user: {
        id: supervisor.id,
        email: supervisor.email,
        name: supervisor.name,
        phone: supervisor.phone,
        role: 'supervisor',
      },
    });
  } catch (err) {
    console.error('Supervisor login error', err);
    return res.status(500).json({ message: 'Error logging in' });
  }
});

module.exports = router;

