const profileService = require('../services/profileService');
const { success } = require('../utils/http');
const { assertValidRequest } = require('../utils/validation');

const getProfile = async (req, res, next) => {
  try {
    const result = await profileService.getProfile(req.user.id);
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const result = await profileService.updateProfile(req.user.id, req.body);
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getProfile,
  updateProfile
};
