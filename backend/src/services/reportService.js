const REPORT_PERIODS = require('../constants/reportPeriods');
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

const pad = (value) => (value < 10 ? `0${value}` : `${value}`);

const toDateInput = (date) => `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;

const resolvePeriod = (query) => {
  const period = query.period || REPORT_PERIODS.MONTHLY;

  if (period === REPORT_PERIODS.MONTHLY) {
    const now = new Date();
    const month = query.month ? Number(query.month) : now.getMonth() + 1;
    const year = query.year ? Number(query.year) : now.getFullYear();
    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 0);
    return { period, periodStart: toDateInput(start), periodEnd: toDateInput(end) };
  }

  if (period === REPORT_PERIODS.WEEKLY) {
    if (!query.startDate) {
      const error = new Error('startDate wajib diisi untuk laporan mingguan');
      error.status = 400;
      throw error;
    }
    const start = new Date(query.startDate);
    if (Number.isNaN(start.getTime())) {
      const error = new Error('Format startDate tidak valid');
      error.status = 400;
      throw error;
    }
    const end = new Date(start);
    end.setDate(start.getDate() + 6);
    return { period, periodStart: toDateInput(start), periodEnd: toDateInput(end) };
  }

  if (period === REPORT_PERIODS.CUSTOM) {
    if (!query.startDate || !query.endDate) {
      const error = new Error('startDate dan endDate wajib diisi untuk periode custom');
      error.status = 400;
      throw error;
    }
    const start = new Date(query.startDate);
    const end = new Date(query.endDate);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      const error = new Error('Format tanggal custom tidak valid');
      error.status = 400;
      throw error;
    }
    return {
      period,
      periodStart: toDateInput(start),
      periodEnd: toDateInput(end)
    };
  }

  const error = new Error('Periode laporan tidak dikenal');
  error.status = 400;
  throw error;
};

const getReport = async (userId, accountId, query) => {
  const account = await assertAccountOwnership(accountId, userId);
  const range = resolvePeriod(query);
  const summary = await repo.getReportSummary(accountId, range);

  return {
    account,
    period: range,
    summary
  };
};

module.exports = {
  getReport
};
