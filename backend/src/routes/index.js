const express = require('express');
const authRoutes = require('./authRoutes');
const transactionRoutes = require('./transactionRoutes');
const balanceRoutes = require('./balanceRoutes');
const reportRoutes = require('./reportRoutes');
const storageRoutes = require('./storageRoutes');
const categoryRoutes = require('./categoryRoutes');
const profileRoutes = require('./profileRoutes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/storage', storageRoutes);
router.use('/profile', profileRoutes);
router.use('/accounts/:accountId/categories', categoryRoutes);
router.use('/accounts/:accountId/transactions', transactionRoutes);
router.use('/accounts/:accountId/balance', balanceRoutes);
router.use('/accounts/:accountId/reports', reportRoutes);

module.exports = router;
