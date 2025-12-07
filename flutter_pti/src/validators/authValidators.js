const { body } = require('express-validator');

const registerValidator = [
  body('fullName').isLength({ min: 3 }).withMessage('Nama lengkap minimal 3 karakter'),
  body('email').isEmail().withMessage('Email tidak valid'),
  body('password').isLength({ min: 6 }).withMessage('Password minimal 6 karakter'),
  body('businessName').notEmpty().withMessage('Nama usaha wajib diisi')
];

const loginValidator = [
  body('email').isEmail().withMessage('Email tidak valid'),
  body('password').notEmpty().withMessage('Password wajib diisi')
];

module.exports = {
  registerValidator,
  loginValidator
};
