const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const repo = require('../repositories/financeRepository');
const { hashToken } = require('../utils/token');

const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.APP_JWT_SECRET, { expiresIn: '12h' });
};

const register = async ({ fullName, email, password, businessName, currency }) => {
  const existing = await repo.findUserByEmail(email);
  if (existing) {
    const error = new Error('Email sudah terdaftar');
    error.status = 409;
    throw error;
  }

  const connection = await repo.getConnection();
  try {
    await connection.beginTransaction();
    const passwordHash = await bcrypt.hash(password, 10);
    const userId = await repo.insertUser(connection, { fullName, email, passwordHash });
    const accountId = await repo.insertAccount(connection, { userId, businessName, currency });
    await repo.insertBalanceRow(connection, accountId);
    await repo.insertDefaultCategories(connection, accountId);
    await connection.commit();

    const token = generateToken(userId);
    return {
      token,
      user: { id: userId, email, fullName },
      defaultAccountId: accountId,
      business: { name: businessName, currency: currency || 'IDR' }
    };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

const login = async ({ email, password }) => {
  const user = await repo.findUserByEmail(email);
  if (!user) {
    const error = new Error('Email atau password salah');
    error.status = 401;
    throw error;
  }

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) {
    const error = new Error('Email atau password salah');
    error.status = 401;
    throw error;
  }

  const account = await repo.findFirstAccountByUser(user.id);
  if (!account) {
    const error = new Error('Akun usaha tidak ditemukan untuk pengguna ini');
    error.status = 400;
    throw error;
  }

  const token = generateToken(user.id);
  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      fullName: user.fullName
    },
    defaultAccountId: account.id,
    business: { name: account.businessName, currency: account.currency }
  };
};

const logout = async ({ token, expiresAt }) => {
  if (!token) {
    return;
  }
  const tokenHash = hashToken(token);
  const expiryDate = expiresAt || new Date(Date.now() + 12 * 60 * 60 * 1000);
  await repo.insertRevokedToken({ tokenHash, expiresAt: expiryDate });
};

module.exports = {
  register,
  login,
  logout
};
