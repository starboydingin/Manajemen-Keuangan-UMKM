const express = require('express');
const controller = require('../controllers/profileController');
const authMiddleware = require('../middleware/authMiddleware');
const { updateProfileValidator } = require('../validators/profileValidators');

const router = express.Router();

router.use(authMiddleware);
router.get('/', controller.getProfile);
router.put('/', updateProfileValidator, controller.updateProfile);

module.exports = router;
