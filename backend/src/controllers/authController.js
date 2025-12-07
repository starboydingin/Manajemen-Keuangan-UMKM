const authService = require('../services/authService');
const { success } = require('../utils/http');
const { assertValidRequest } = require('../utils/validation');

const register = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const result = await authService.register(req.body);
    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
};

const login = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const result = await authService.login(req.body);
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

const logout = async (req, res, next) => {
  try {
    await authService.logout({ token: req.authToken, expiresAt: req.tokenExpiresAt });
    return success(res, { message: 'Logout berhasil' });
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  register,
  login,
  logout
};
