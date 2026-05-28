import request from './request'

export const getDashboardStats = () => request.get('/stats/dashboard')

export const getDailyStats = (date) =>
  request.get('/stats/daily', { params: { date } })
