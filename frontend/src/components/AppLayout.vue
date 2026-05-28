<template>
  <el-container class="app-container">
    <el-header class="app-header">
      <h1>城市路侧停车位动态感知与结算系统</h1>
      <span class="clock">{{ currentTime }}</span>
    </el-header>
    <el-container>
      <el-aside width="200px" class="app-aside">
        <el-menu
          :default-active="activeMenu"
          router
          background-color="#fff"
          text-color="#555"
          active-text-color="#1890ff"
        >
          <el-menu-item index="/dashboard">
            <el-icon><DataAnalysis /></el-icon>
            <span>系统总览</span>
          </el-menu-item>
          <el-menu-item index="/roads">
            <el-icon><Guide /></el-icon>
            <span>路段管理</span>
          </el-menu-item>
          <el-menu-item index="/spaces">
            <el-icon><Grid /></el-icon>
            <span>车位管理</span>
          </el-menu-item>
          <el-menu-item index="/users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/entry">
            <el-icon><Right /></el-icon>
            <span>车辆入场</span>
          </el-menu-item>
          <el-menu-item index="/exit">
            <el-icon><Back /></el-icon>
            <span>车辆出场</span>
          </el-menu-item>
          <el-menu-item index="/billing">
            <el-icon><Money /></el-icon>
            <span>计费记录</span>
          </el-menu-item>
          <el-menu-item index="/arrears">
            <el-icon><Warning /></el-icon>
            <span>欠费追缴</span>
          </el-menu-item>
          <el-menu-item index="/statistics">
            <el-icon><TrendCharts /></el-icon>
            <span>统计分析</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main class="app-main">
        <router-view v-slot="{ Component }">
          <transition name="page-fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const activeMenu = computed(() => route.path)

const currentTime = ref('')
let timer = null

function updateTime() {
  currentTime.value = new Date().toLocaleString('zh-CN')
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif; background: #f0f2f5; }
.app-container { height: 100vh; }
.app-header {
  background: linear-gradient(135deg, #1a1a2e, #16213e);
  color: #fff; display: flex; align-items: center;
  justify-content: space-between; padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,.3);
}
.app-header h1 { font-size: 18px; font-weight: 600; letter-spacing: 1px; }
.app-header .clock { font-size: 13px; opacity: .8; }
.app-aside {
  background: #fff; border-right: 1px solid #e0e0e0;
  overflow-y: auto;
}
.app-aside .el-menu { border-right: none; }
.app-main { padding: 24px; background: #f0f2f5; overflow-y: auto; }

/* Page transition */
.page-fade-enter-active { transition: opacity 0.25s ease, transform 0.25s ease; }
.page-fade-leave-active { transition: opacity 0.15s ease; }
.page-fade-enter-from { opacity: 0; transform: translateY(8px); }
.page-fade-leave-to { opacity: 0; }

/* Sidebar active indicator */
.app-aside .el-menu-item.is-active {
  background: #ecf5ff !important;
  border-right: 3px solid #409eff;
}

/* Card hover effect */
:deep(.el-card) { transition: box-shadow 0.2s ease; }
:deep(.el-card:hover) { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); }

/* Table improvements */
:deep(.el-table) { border-radius: 8px; overflow: hidden; }
:deep(.el-table th.el-table__cell) { background: #fafafa; font-weight: 600; }

/* Scrollbar styling */
.app-aside::-webkit-scrollbar { width: 4px; }
.app-aside::-webkit-scrollbar-thumb { background: #d9d9d9; border-radius: 2px; }
</style>
