const repo = require('../repositories/financeRepository');

const ensureUser = async (userId) => {
  const user = await repo.findUserById(userId);
  if (!user) {
    const error = new Error('Pengguna tidak ditemukan');
    error.status = 404;
    throw error;
  }
  return user;
};

const ensureAccount = async (userId) => {
  const account = await repo.findFirstAccountByUser(userId);
  if (!account) {
    const error = new Error('Akun usaha tidak ditemukan');
    error.status = 404;
    throw error;
  }
  return account;
};

const mapBusinessName = (name) => {
  if (!name) return null;
  const trimmed = name.trim();
  return trimmed.length === 0 ? null : trimmed;
};

const buildPayload = (user, account) => ({
  user: {
    id: user.id,
    email: user.email,
    fullName: user.fullName
  },
  defaultAccountId: account.id,
  business: {
    name: mapBusinessName(account.businessName) || null,
    currency: account.currency
  }
});

const getProfile = async (userId) => {
  const [user, account] = await Promise.all([ensureUser(userId), ensureAccount(userId)]);
  return buildPayload(user, account);
};

const updateProfile = async (userId, { fullName, businessName }) => {
  await ensureUser(userId);
  const account = await ensureAccount(userId);
  const connection = await repo.getConnection();
  try {
    await connection.beginTransaction();
    await repo.updateUserName(connection, { userId, fullName: fullName.trim() });
    if (typeof businessName === 'string') {
      await repo.updateAccountBusiness(connection, {
        accountId: account.id,
        businessName: businessName.trim()
      });
    }
    await connection.commit();
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
  return getProfile(userId);
};

module.exports = {
  getProfile,
  updateProfile
};
