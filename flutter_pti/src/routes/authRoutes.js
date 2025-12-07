const express = require('express');
const controller = require('../controllers/authController');
const { registerValidator, loginValidator } = require('../validators/authValidators');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/register', registerValidator, controller.register);
router.post('/login', loginValidator, controller.login);
router.post('/logout', authMiddleware, controller.logout);

module.exports = router;
