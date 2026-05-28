import request from './request'

export const getSpaces = (roadId) => {
  const params = roadId ? { road_id: roadId } : {}
  return request.get('/spaces', { params })
}

export const getAvailableSpaces = (roadId) => {
  const params = roadId ? { road_id: roadId } : {}
  return request.get('/spaces/available', { params })
}
