<template>
  <div>
    <h2 class="page-title">车辆出场</h2>

    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>出场操作</span></template>
      <el-form :inline="true" @submit.prevent="handleExit">
        <el-form-item label="车牌号码">
          <el-input v-model="plate" placeholder="输入车牌号" style="width: 200px" :disabled="exiting" />
        </el-form-item>
        <el-form-item>
          <el-button type="warning" @click="handleExit" :loading="exiting">确认出场</el-button>
        </el-form-item>
      </el-form>

      <el-alert v-if="exitResult" type="success" show-icon :closable="true" @close="exitResult = null" style="margin-top: 12px">
        <template #title>
          <div>
            <div><strong>{{ exitResult.message }}</strong></div>
            <div>车牌: {{ plate }}</div>
            <div>出场时间: {{ formatTime(exitResult.exit_time) }}</div>
            <div>停车时长: {{ formatDuration(exitResult.duration_minutes) }}</div>
            <div>停车费用: <strong>¥{{ exitResult.fee }}</strong></div>
            <div v-if="exitResult.billing">支付状态: {{ payStatusLabel(exitResult.billing.payment_status) }}</div>
          </div>
        </template>
      </el-alert>
      <el-alert v-if="exitWarning" :title="exitWarning" type="warning" show-icon
        :closable="true" @close="exitWarning = null" style="margin-top: 12px" />
      <el-alert v-if="exitError" :title="exitError" type="error" show-icon
        :closable="true" @close="exitError = null" style="margin-top: 12px" />
    </el-card>

    <el-card shadow="never">
      <template #header><span>出场记录</span></template>
      <el-table :data="exits" stripe>
        <el-table-column prop="plate_number" label="车牌" />
        <el-table-column prop="road_name" label="路段" />
        <el-table-column prop="space_number" label="车位" />
        <el-table-column label="入场时间">
          <template #default="{ row }">{{ formatTime(row.entry_time) }}</template>
        </el-table-column>
        <el-table-column label="出场时间">
          <template #default="{ row }">{{ formatTime(row.exit_time) }}</template>
        </el-table-column>
        <el-table-column label="时长">
          <template #default="{ row }">{{ formatDuration(row.duration_minutes) }}</template>
        </el-table-column>
        <el-table-column label="费用">
          <template #default="{ row }">¥{{ row.fee || 0 }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { vehicleExit, getExits } from '../api/parking'

const plate = ref('')
const exits = ref([])
const exitResult = ref(null)
const exitWarning = ref(null)
const exitError = ref(null)
const exiting = ref(false)

function formatTime(t) {
  return t ? new Date(t).toLocaleString('zh-CN') : '-'
}

function formatDuration(m) {
  if (m == null) return '-'
  if (m < 60) return `${m} 分`
  return `${Math.floor(m / 60)}时${m % 60}分`
}

function payStatusLabel(s) {
  const m = { paid: '已付', unpaid: '未付', arrears: '欠费', partial: '部分' }
  return m[s] || s
}

async function loadExits() {
  exits.value = await getExits()
}

async function handleExit() {
  exitResult.value = null
  exitWarning.value = null
  exitError.value = null
  if (!plate.value.trim()) { ElMessage.warning('请输入车牌号'); return }
  exiting.value = true
  try {
    const res = await vehicleExit(plate.value.trim())
    exitResult.value = res
    exitWarning.value = res.warning || null
    ElMessage.success(res.message)
    await loadExits()
  } catch (e) {
    exitError.value = e.response?.data?.error || '出场失败'
  } finally {
    exiting.value = false
  }
}

onMounted(loadExits)
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
