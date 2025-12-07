const { body, query } = require('express-validator');

const createTransactionValidator = [
  body('categoryId').isInt({ min: 1 }).withMessage('Kategori wajib diisi'),
  body('amount').isFloat({ min: 0.01 }).withMessage('Nominal tidak valid'),
  body('transactionType').isIn(['income', 'expense']).withMessage('Tipe transaksi tidak valid'),
  body('transactionDate').isISO8601().toDate().withMessage('Tanggal transaksi tidak valid'),
  body('description').optional().isLength({ max: 255 }).withMessage('Deskripsi terlalu panjang')
];

const transactionListValidator = [
  query('startDate').optional().isISO8601().withMessage('Format startDate salah'),
  query('endDate').optional().isISO8601().withMessage('Format endDate salah'),
  query('categoryId').optional().isInt({ min: 1 }).withMessage('Kategori tidak valid')
];

module.exports = {
  createTransactionValidator,
  transactionListValidator
};
