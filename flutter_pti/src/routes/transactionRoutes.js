const express = require('express');
const controller = require('../controllers/transactionController');
const authMiddleware = require('../middleware/authMiddleware');
const { createTransactionValidator, transactionListValidator } = require('../validators/transactionValidators');

const router = express.Router({ mergeParams: true });

router.use(authMiddleware);
router.post('/', createTransactionValidator, controller.createTransaction);
router.get('/', transactionListValidator, controller.listTransactions);

module.exports = router;
