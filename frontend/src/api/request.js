import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
})

request.interceptors.response.use(
  res => res.data,
  err => {
    const msg = err.response?.data?.error || err.message || '请求失败'
    ElMessage.error(msg)
    return Promise.reject(err)
  }
)

export default request
