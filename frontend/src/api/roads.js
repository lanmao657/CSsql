import request from './request'

export const getRoads = () => request.get('/roads')

export const addRoad = (data) => request.post('/roads', data)

export const deleteRoad = (roadId) => request.delete(`/roads/${roadId}`)

export const getStandards = (roadId) => request.get(`/roads/${roadId}/standards`)

export const addStandard = (data) => request.post('/standards', data)
