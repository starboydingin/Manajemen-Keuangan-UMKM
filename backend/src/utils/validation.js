const { validationResult } = require('express-validator');

const assertValidRequest = (req) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const error = new Error('Validasi gagal');
    error.status = 422;
    error.details = errors.array();
    throw error;
  }
};

module.exports = {
  assertValidRequest
};
