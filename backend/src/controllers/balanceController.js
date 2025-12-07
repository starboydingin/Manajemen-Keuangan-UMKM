const balanceService = require('../services/balanceService');
const { success } = require('../utils/http');

const getBalance = async (req, res, next) => {
  try {
    const { accountId } = req.params;
    const result = await balanceService.getBalance(req.user.id, Number(accountId));
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getBalance
};
