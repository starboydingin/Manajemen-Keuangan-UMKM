const transactionService = require('../services/transactionService');
const { success } = require('../utils/http');
const { assertValidRequest } = require('../utils/validation');

const createTransaction = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const { accountId } = req.params;
    const result = await transactionService.createTransaction(
      req.user.id,
      Number(accountId),
      req.body
    );
    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
};

const listTransactions = async (req, res, next) => {
  try {
    assertValidRequest(req);
    const { accountId } = req.params;
    const { startDate, endDate, categoryId } = req.query;
    const result = await transactionService.listTransactions(
      req.user.id,
      Number(accountId),
      {
        startDate,
        endDate,
        categoryId: categoryId ? Number(categoryId) : undefined
      }
    );
    return success(res, result);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  createTransaction,
  listTransactions
};
