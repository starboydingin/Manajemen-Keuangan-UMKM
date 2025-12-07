const repo = require('../repositories/financeRepository');

const saveReference = async (userId, payload) => {
  const account = await repo.getAccountById(payload.accountId, userId);
  if (!account) {
    const error = new Error('Akun usaha tidak ditemukan');
    error.status = 404;
    throw error;
  }

  await repo.insertStorageRef(payload);
  return { accountId: payload.accountId, storageUrl: payload.storageUrl };
};

module.exports = {
  saveReference
};
