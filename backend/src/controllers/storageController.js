const storageService = require('../services/storageService');
const { success } = require('../utils/http');
const { assertValidRequest } = require('../utils/validation');

const saveReference = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const result = await storageService.saveReference(req.user.id, req.body);
    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  saveReference
};
