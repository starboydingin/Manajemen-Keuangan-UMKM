const { body } = require('express-validator');

const storageValidator = [
  body('accountId').isInt({ min: 1 }).withMessage('AccountId tidak valid'),
  body('fileType').isIn(['report', 'backup', 'other']).withMessage('Tipe file tidak valid'),
  body('storageUrl').isURL({ require_protocol: true }).withMessage('URL tidak valid'),
  body('metadata').optional().isObject().withMessage('Metadata harus berbentuk objek')
];

module.exports = {
  storageValidator
};
