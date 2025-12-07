const express = require('express');
const controller = require('../controllers/storageController');
const authMiddleware = require('../middleware/authMiddleware');
const { storageValidator } = require('../validators/storageValidators');

const router = express.Router();

router.use(authMiddleware);
router.post('/', storageValidator, controller.saveReference);

module.exports = router;
