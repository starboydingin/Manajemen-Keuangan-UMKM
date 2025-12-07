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

const listCategories = async (userId, accountId) => {
  await assertAccountOwnership(accountId, userId);
  return repo.listCategories(accountId);
};

module.exports = {
  listCategories
};
