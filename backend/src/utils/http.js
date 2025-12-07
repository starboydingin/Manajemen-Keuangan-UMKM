const success = (res, data = {}, status = 200) => {
  return res.status(status).json({
    status: 'success',
    data
  });
};

const error = (res, message, status = 400, details) => {
  return res.status(status).json({
    status: 'error',
    message,
    details
  });
};

module.exports = {
  success,
  error
};
