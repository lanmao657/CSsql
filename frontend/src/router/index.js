import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '../components/AppLayout.vue'

const routes = [
  {
    path: '/',
    component: AppLayout,
    redirect: '/dashboard',
    children: [
      { path: 'dashboard',  name: 'Dashboard',  component: () => import('../views/Dashboard.vue'),  meta: { title: '系统总览' } },
      { path: 'roads',      name: 'Roads',      component: () => import('../views/Roads.vue'),      meta: { title: '路段管理' } },
      { path: 'spaces',     name: 'Spaces',     component: () => import('../views/Spaces.vue'),     meta: { title: '车位管理' } },
      { path: 'users',      name: 'Users',      component: () => import('../views/Users.vue'),      meta: { title: '用户管理' } },
      { path: 'entry',      name: 'Entry',      component: () => import('../views/Entry.vue'),      meta: { title: '车辆入场' } },
      { path: 'exit',       name: 'Exit',       component: () => import('../views/Exit.vue'),       meta: { title: '车辆出场' } },
      { path: 'billing',    name: 'Billing',    component: () => import('../views/Billing.vue'),    meta: { title: '计费记录' } },
      { path: 'arrears',    name: 'Arrears',    component: () => import('../views/Arrears.vue'),    meta: { title: '欠费追缴' } },
      { path: 'statistics', name: 'Statistics', component: () => import('../views/Statistics.vue'), meta: { title: '统计分析' } },
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
