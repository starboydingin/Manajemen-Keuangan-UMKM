const { body } = require('express-validator');

const updateProfileValidator = [
  body('fullName')
    .trim()
    .isLength({ min: 3 })
    .withMessage('Nama lengkap minimal 3 karakter'),
  body('businessName')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 150 })
    .withMessage('Nama usaha maksimal 150 karakter')
];

module.exports = {
  updateProfileValidator
};
