const repo = require('../repositories/financeRepository');

const assertAccountOwnership = async (accountId, userId) => {
  const account = await repo.getAccountById(accountId, userId);
  if (!account) {
    const error = new Error('Akun usaha tidak ditemukan');
    error.status = 404;
    throw error;
  }
  return account;
};

const getBalance = async (userId, accountId) => {
  const account = await assertAccountOwnership(accountId, userId);
  const snapshot = await repo.getBalanceSnapshot(accountId);

  if (snapshot) {
    return {
      account,
      totals: snapshot
    };
  }

  const totals = await repo.computeBalanceFromTransactions(accountId);
  return {
    account,
    totals: {
      accountId,
      ...totals,
      updatedAt: null
    }
  };
};

module.exports = {
  getBalance
};
