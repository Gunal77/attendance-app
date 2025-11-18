const express = require('express');
const { register, login, signup } = require('../controllers/authController');

const router = express.Router();

router.post('/register', register);
router.post('/signup', signup);
router.post('/login', login);

module.exports = router;

