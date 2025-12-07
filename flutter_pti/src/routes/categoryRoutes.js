const express = require('express');
const controller = require('../controllers/categoryController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router({ mergeParams: true });

router.use(authMiddleware);
router.get('/', controller.listCategories);

module.exports = router;
