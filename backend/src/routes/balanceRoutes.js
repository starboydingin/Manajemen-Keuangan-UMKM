const express = require('express');
const controller = require('../controllers/balanceController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router({ mergeParams: true });

router.use(authMiddleware);
router.get('/', controller.getBalance);

module.exports = router;
