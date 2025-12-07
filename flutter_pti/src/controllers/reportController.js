const reportService = require('../services/reportService');
const { success } = require('../utils/http');

const getReport = async (req, res, next) => {
  try {
    const { accountId } = req.params;
    const result = await reportService.getReport(req.user.id, Number(accountId), req.query);
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getReport
};
