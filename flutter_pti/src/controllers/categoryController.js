const categoryService = require('../services/categoryService');
const { success } = require('../utils/http');

const listCategories = async (req, res, next) => {
  try {
    const { accountId } = req.params;
    const result = await categoryService.listCategories(req.user.id, Number(accountId));
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  listCategories
};
