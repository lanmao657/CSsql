<template>
  <div>
    <h2 class="page-title">统计分析</h2>

    <!-- 每日路段统计 -->
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>每日路段统计（存储过程）</span></template>
      <el-form :inline="true" @submit.prevent="loadStats">
        <el-form-item label="查询日期">
          <el-date-picker v-model="statDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadStats">查询统计</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="stats" stripe style="margin-top: 12px">
        <el-table-column prop="rank" label="排名" width="70">
          <template #default="{ row }"><strong>{{ row.rank }}</strong></template>
        </el-table-column>
        <el-table-column prop="road_name" label="路段" />
        <el-table-column prop="total_park_minutes" label="总停车时长(分)" width="130" />
        <el-table-column prop="total_hours" label="总停车时长(h)" width="130" />
        <el-table-column label="应收(元)">
          <template #default="{ row }">¥{{ row.expected_revenue }}</template>
        </el-table-column>
        <el-table-column label="实收(元)">
          <template #default="{ row }">¥{{ row.actual_revenue }}</template>
        </el-table-column>
        <el-table-column label="欠费(元)">
          <template #default="{ row }">
            <span style="color: #f5222d">¥{{ row.arrears_amount }}</span>
          </template>
        </el-table-column>
        <el-table-column label="欠费率">
          <template #default="{ row }">{{ row.arrears_rate }}%</template>
        </el-table-column>
        <el-table-column label="泊位周转率" width="110">
          <template #default="{ row }"><strong>{{ row.turnover_rate }}</strong></template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!stats.length" description="当日暂无数据" />
    </el-card>

    <!-- 可用空闲车位视图 -->
    <el-card shadow="never">
      <template #header><span>可用空闲车位（视图查询）</span></template>
      <el-table :data="available" stripe>
        <el-table-column prop="road_name" label="路段" />
        <el-table-column prop="space_number" label="编号" />
        <el-table-column prop="section_code" label="路段编码" />
        <el-table-column prop="space_position" label="位置">
          <template #default="{ row }">{{ row.space_position || '-' }}</template>
        </el-table-column>
        <el-table-column label="最近释放时间">
          <template #default="{ row }">{{ formatTime(row.last_freed_at) }}</template>
        </el-table-column>
        <el-table-column label="空闲时长(分)">
          <template #default="{ row }">{{ Math.round(row.minutes_since_freed) }}</template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!available.length" description="暂无空闲车位" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getDailyStats } from '../api/stats'
import { getAvailableSpaces } from '../api/spaces'

const statDate = ref(new Date().toISOString().slice(0, 10))
const stats = ref([])
const available = ref([])

function formatTime(t) {
  return t ? new Date(t).toLocaleString('zh-CN') : '-'
}

async function loadStats() {
  stats.value = await getDailyStats(statDate.value)
}

async function loadAvailable() {
  available.value = await getAvailableSpaces()
}

onMounted(() => {
  loadStats()
  loadAvailable()
})
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
