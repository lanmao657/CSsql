import request from './request'

export const vehicleEntry = (data) => request.post('/entry', data)

export const vehicleExit = (plateNumber) =>
  request.post('/exit', { plate_number: plateNumber })

export const getEntries = () => request.get('/entries')

export const getExits = () => request.get('/exits')
