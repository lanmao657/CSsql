import request from './request'

export const getBilling = () => request.get('/billing')

export const payBilling = (billingId) =>
  request.post(`/billing/${billingId}/pay`)

export const getArrears = (status) => {
  const params = status ? { status } : {}
  return request.get('/arrears', { params })
}
