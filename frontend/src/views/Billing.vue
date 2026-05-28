<template>
  <div>
    <h2 class="page-title">计费记录</h2>

    <el-card shadow="never">
      <template #header><span>计费明细</span></template>
      <el-table :data="billing" stripe :default-sort="{ prop: 'billing_id', order: 'descending' }">
        <el-table-column prop="billing_id" label="ID" width="60" sortable />
        <el-table-column prop="plate_number" label="车牌" />
        <el-table-column prop="username" label="用户">
          <template #default="{ row }">{{ row.username || '-' }}</template>
        </el-table-column>
        <el-table-column prop="road_name" label="路段">
          <template #default="{ row }">{{ row.road_name || '-' }}</template>
        </el-table-column>
        <el-table-column prop="space_number" label="车位">
          <template #default="{ row }">{{ row.space_number || '-' }}</template>
        </el-table-column>
        <el-table-column label="时长" sortable :sort-method="(a, b) => (a.duration_minutes || 0) - (b.duration_minutes || 0)">
          <template #default="{ row }">{{ formatDuration(row.duration_minutes) }}</template>
        </el-table-column>
        <el-table-column label="应付" sortable :sort-method="(a, b) => Number(a.total_fee) - Number(b.total_fee)">
          <template #default="{ row }">¥{{ row.total_fee }}</template>
        </el-table-column>
        <el-table-column label="实付" sortable :sort-method="(a, b) => Number(a.actual_paid) - Number(b.actual_paid)">
          <template #default="{ row }">¥{{ row.actual_paid }}</template>
        </el-table-column>
        <el-table-column label="方式">
          <template #default="{ row }">{{ row.payment_method || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="payTagType(row.payment_status)" size="small">
              {{ payStatusLabel(row.payment_status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80">
          <template #default="{ row }">
            <el-button v-if="row.payment_status !== 'paid'" size="small" type="success" @click="handlePay(row)">
              结算
            </el-button>
            <span v-else>-</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getBilling, payBilling } from '../api/billing'

const billing = ref([])

function formatDuration(m) {
  if (m == null) return '-'
  if (m < 60) return `${m} 分`
  return `${Math.floor(m / 60)}时${m % 60}分`
}

function payStatusLabel(s) {
  const m = { paid: '已付', unpaid: '未付', arrears: '欠费', partial: '部分' }
  return m[s] || s
}

function payTagType(s) {
  const m = { paid: 'success', unpaid: 'danger', arrears: 'warning', partial: 'info' }
  return m[s] || 'info'
}

async function loadBilling() {
  billing.value = await getBilling()
}

async function handlePay(row) {
  try {
    const res = await payBilling(row.billing_id)
    ElMessage.success(res.message)
    await loadBilling()
  } catch (e) {
    // error already handled by interceptor
  }
}

onMounted(loadBilling)
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
