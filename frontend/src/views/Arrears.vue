<template>
  <div>
    <PageBanner type="arrears" />

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>欠费记录</span>
          <el-select v-model="statusFilter" placeholder="全部状态" clearable style="width: 150px" @change="loadArrears">
            <el-option label="全部" value="" />
            <el-option label="待缴" value="pending" />
            <el-option label="已缴" value="paid" />
            <el-option label="减免" value="waived" />
          </el-select>
        </div>
      </template>
      <el-table :data="arrears" stripe>
        <el-table-column prop="arrears_id" label="ID" width="60" />
        <el-table-column prop="plate_number" label="车牌" />
        <el-table-column prop="username" label="用户">
          <template #default="{ row }">{{ row.username || '-' }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号">
          <template #default="{ row }">{{ row.phone || '-' }}</template>
        </el-table-column>
        <el-table-column label="欠费金额">
          <template #default="{ row }">
            <span :style="{ color: row.status === 'pending' ? '#f5222d' : '#333', fontWeight: 600 }">
              ¥{{ row.arrears_amount }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="arrearsTagType(row.status)" size="small">
              {{ arrearsStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="生成时间">
          <template #default="{ row }">{{ formatTime(row.created_at) }}</template>
        </el-table-column>
        <el-table-column label="缴清时间">
          <template #default="{ row }">{{ formatTime(row.paid_at) }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getArrears } from '../api/billing'
import PageBanner from '../components/PageBanner.vue'

const arrears = ref([])
const statusFilter = ref('')

function formatTime(t) {
  return t ? new Date(t).toLocaleString('zh-CN') : '-'
}

function arrearsStatusLabel(s) {
  const m = { pending: '待缴', paid: '已缴', waived: '减免' }
  return m[s] || s
}

function arrearsTagType(s) {
  const m = { pending: 'danger', paid: 'success', waived: 'info' }
  return m[s] || 'info'
}

async function loadArrears() {
  arrears.value = await getArrears(statusFilter.value || undefined)
}

onMounted(loadArrears)
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
