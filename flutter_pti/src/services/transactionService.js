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

const createTransaction = async (userId, accountId, payload) => {
  await assertAccountOwnership(accountId, userId);

  const category = await repo.getCategoryById(accountId, payload.categoryId);
  if (!category) {
    const error = new Error('Kategori tidak ditemukan');
    error.status = 404;
    throw error;
  }
  if (category.type !== payload.transactionType) {
    const error = new Error('Tipe transaksi tidak sesuai dengan kategori');
    error.status = 400;
    throw error;
  }

  const amount = Number(payload.amount);
  const connection = await repo.getConnection();
  try {
    await connection.beginTransaction();
    const transactionId = await repo.insertTransaction(connection, {
      accountId,
      categoryId: payload.categoryId,
      amount,
      transactionType: payload.transactionType,
      description: payload.description,
      transactionDate: payload.transactionDate
    });

    const incomeDelta = payload.transactionType === 'income' ? amount : 0;
    const expenseDelta = payload.transactionType === 'expense' ? amount : 0;

    await repo.upsertBalance(connection, accountId, incomeDelta, expenseDelta);
    await connection.commit();

    return { transactionId };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

const listTransactions = async (userId, accountId, filters) => {
  await assertAccountOwnership(accountId, userId);
  return repo.listTransactions(accountId, filters);
};

module.exports = {
  createTransaction,
  listTransactions
};
