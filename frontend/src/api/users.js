import request from './request'

export const getUsers = () => request.get('/users')

export const addUser = (data) => request.post('/users', data)

export const topupUser = (userId, amount) =>
  request.post(`/users/${userId}/topup`, { amount })

export const getUserVehicles = (userId) =>
  request.get(`/users/${userId}/vehicles`)

export const bindVehicle = (data) => request.post('/vehicles', data)
