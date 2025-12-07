const pool = require('../config/db');

const getConnection = () => pool.getConnection();

const findUserByEmail = async (email) => {
  const [rows] = await pool.query(
    'SELECT id, email, password_hash AS passwordHash, full_name AS fullName FROM users WHERE email = ? LIMIT 1',
    [email]
  );
  return rows[0];
};

const findUserById = async (userId) => {
  const [rows] = await pool.query(
    'SELECT id, email, full_name AS fullName FROM users WHERE id = ? LIMIT 1',
    [userId]
  );
  return rows[0];
};

const insertUser = async (conn, { fullName, email, passwordHash }) => {
  const [result] = await conn.query(
    'INSERT INTO users (full_name, email, password_hash) VALUES (?, ?, ?)',
    [fullName, email, passwordHash]
  );
  return result.insertId;
};

const insertAccount = async (conn, { userId, businessName, currency = 'IDR' }) => {
  const [result] = await conn.query(
    'INSERT INTO accounts (user_id, business_name, currency) VALUES (?, ?, ?)',
    [userId, businessName, currency]
  );
  return result.insertId;
};

const insertBalanceRow = async (conn, accountId) => {
  await conn.query(
    'INSERT INTO balances (account_id) VALUES (?) ON DUPLICATE KEY UPDATE current_balance = current_balance',
    [accountId]
  );
};

const insertDefaultCategories = async (conn, accountId) => {
  const defaults = [
    { name: 'Penjualan', type: 'income' },
    { name: 'Investasi', type: 'income' },
    { name: 'Operasional', type: 'expense' },
    { name: 'Gaji', type: 'expense' }
  ];

  const values = defaults.map((c) => [accountId, c.name, c.type]);
  const placeholders = values.map(() => '(?,?,?)').join(',');
  await conn.query(
    `INSERT IGNORE INTO transaction_categories (account_id, name, type) VALUES ${placeholders}`,
    values.flat()
  );
};

const updateUserName = async (conn, { userId, fullName }) => {
  await conn.query('UPDATE users SET full_name = ? WHERE id = ?', [fullName, userId]);
};

const updateAccountBusiness = async (conn, { accountId, businessName }) => {
  await conn.query('UPDATE accounts SET business_name = ? WHERE id = ?', [businessName, accountId]);
};

const getAccountById = async (accountId, userId) => {
  const params = [accountId];
  let query = 'SELECT * FROM accounts WHERE id = ?';
  if (userId) {
    query += ' AND user_id = ?';
    params.push(userId);
  }
  const [rows] = await pool.query(query + ' LIMIT 1', params);
  return rows[0];
};

const getCategoryById = async (accountId, categoryId) => {
  const [rows] = await pool.query(
    'SELECT id, type FROM transaction_categories WHERE account_id = ? AND id = ? LIMIT 1',
    [accountId, categoryId]
  );
  return rows[0];
};

const listCategories = async (accountId) => {
  const [rows] = await pool.query(
    'SELECT id, name, type FROM transaction_categories WHERE account_id = ? ORDER BY name ASC',
    [accountId]
  );
  return rows;
};

const findFirstAccountByUser = async (userId) => {
  const [rows] = await pool.query(
    'SELECT id, business_name AS businessName, currency FROM accounts WHERE user_id = ? ORDER BY id ASC LIMIT 1',
    [userId]
  );
  return rows[0];
};

const insertTransaction = async (conn, payload) => {
  const {
    accountId,
    categoryId,
    amount,
    transactionType,
    description,
    transactionDate
  } = payload;

  const [result] = await conn.query(
    `INSERT INTO transactions
    (account_id, category_id, amount, transaction_type, description, transaction_date)
    VALUES (?, ?, ?, ?, ?, ?)`,
    [accountId, categoryId, amount, transactionType, description || null, transactionDate]
  );
  return result.insertId;
};

const upsertBalance = async (conn, accountId, incomeDelta, expenseDelta) => {
  const balanceDelta = incomeDelta - expenseDelta;

  await conn.query(
    `INSERT INTO balances (account_id, total_income, total_expense, current_balance)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       total_income = total_income + VALUES(total_income),
       total_expense = total_expense + VALUES(total_expense),
       current_balance = current_balance + VALUES(current_balance)`
      ,
    [accountId, incomeDelta, expenseDelta, balanceDelta]
  );
};

const listTransactions = async (accountId, { startDate, endDate, categoryId }) => {
  let query = `SELECT t.id, t.amount, t.transaction_type AS transactionType, t.description,
                      t.transaction_date AS transactionDate,
                      c.name AS categoryName, c.type AS categoryType
               FROM transactions t
               JOIN transaction_categories c ON c.id = t.category_id
               WHERE t.account_id = ?`;
  const params = [accountId];

  if (startDate) {
    query += ' AND t.transaction_date >= ?';
    params.push(startDate);
  }
  if (endDate) {
    query += ' AND t.transaction_date <= ?';
    params.push(endDate);
  }
  if (categoryId) {
    query += ' AND t.category_id = ?';
    params.push(categoryId);
  }

  query += ' ORDER BY t.transaction_date DESC, t.id DESC';

  const [rows] = await pool.query(query, params);
  return rows;
};

const getBalanceSnapshot = async (accountId) => {
  const [rows] = await pool.query(
    'SELECT account_id AS accountId, total_income AS totalIncome, total_expense AS totalExpense, current_balance AS currentBalance, updated_at AS updatedAt FROM balances WHERE account_id = ? LIMIT 1',
    [accountId]
  );
  return rows[0];
};

const computeBalanceFromTransactions = async (accountId) => {
  const [rows] = await pool.query(
    `SELECT
       SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) AS totalIncome,
       SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) AS totalExpense
     FROM transactions WHERE account_id = ?`,
    [accountId]
  );
  const totals = rows[0] || {};
  const totalIncome = Number(totals.totalIncome || 0);
  const totalExpense = Number(totals.totalExpense || 0);
  return {
    totalIncome,
    totalExpense,
    currentBalance: totalIncome - totalExpense
  };
};

const getReportSummary = async (accountId, { periodStart, periodEnd }) => {
  const [rows] = await pool.query(
    `SELECT
        SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) AS totalIncome,
        SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) AS totalExpense,
        COUNT(*) AS totalTransactions
     FROM transactions
     WHERE account_id = ? AND transaction_date BETWEEN ? AND ?`,
    [accountId, periodStart, periodEnd]
  );

  const summary = rows[0] || {};
  const totalIncome = Number(summary.totalIncome || 0);
  const totalExpense = Number(summary.totalExpense || 0);
  return {
    totalIncome,
    totalExpense,
    netProfit: totalIncome - totalExpense,
    totalTransactions: Number(summary.totalTransactions || 0)
  };
};

const insertStorageRef = async ({ accountId, fileType, storageUrl, metadata }) => {
  await pool.query(
    'INSERT INTO cloud_storage_refs (account_id, file_type, storage_url, metadata) VALUES (?, ?, ?, ?)',
    [accountId, fileType, storageUrl, metadata ? JSON.stringify(metadata) : null]
  );
};

const insertRevokedToken = async ({ tokenHash, expiresAt }) => {
  await pool.query(
    'INSERT IGNORE INTO revoked_tokens (token_hash, expires_at) VALUES (?, ?)',
    [tokenHash, expiresAt]
  );
};

const findRevokedTokenByHash = async (tokenHash) => {
  const [rows] = await pool.query(
    'SELECT id FROM revoked_tokens WHERE token_hash = ? AND expires_at > NOW() LIMIT 1',
    [tokenHash]
  );
  return rows[0];
};

module.exports = {
  getConnection,
  findUserByEmail,
  findUserById,
  insertUser,
  insertAccount,
  insertBalanceRow,
  insertDefaultCategories,
  updateUserName,
  updateAccountBusiness,
  getAccountById,
  getCategoryById,
  listCategories,
  findFirstAccountByUser,
  insertTransaction,
  upsertBalance,
  listTransactions,
  getBalanceSnapshot,
  computeBalanceFromTransactions,
  getReportSummary,
  insertStorageRef,
  insertRevokedToken,
  findRevokedTokenByHash
};
