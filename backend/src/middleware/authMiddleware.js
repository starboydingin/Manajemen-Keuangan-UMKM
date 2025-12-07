const jwt = require('jsonwebtoken');
const { error } = require('../utils/http');
const repo = require('../repositories/financeRepository');
const { hashToken } = require('../utils/token');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return error(res, 'Authorization header missing', 401);
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return error(res, 'Invalid authorization header', 401);
  }

  try {
    const payload = jwt.verify(token, process.env.APP_JWT_SECRET);
    const tokenHash = hashToken(token);
    const revoked = await repo.findRevokedTokenByHash(tokenHash);
    if (revoked) {
      return error(res, 'Token sudah tidak berlaku', 401);
    }
    req.user = payload;
    req.authToken = token;
    if (payload.exp) {
      req.tokenExpiresAt = new Date(payload.exp * 1000);
    }
    return next();
  } catch (err) {
    return error(res, 'Invalid or expired token', 401);
  }
};

module.exports = authMiddleware;
