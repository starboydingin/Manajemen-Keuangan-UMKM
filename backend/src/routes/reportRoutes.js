const express = require('express');
const controller = require('../controllers/reportController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router({ mergeParams: true });

router.use(authMiddleware);
router.get('/', controller.getReport);

module.exports = router;
