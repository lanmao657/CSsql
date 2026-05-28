<template>
  <div>
    <h2 class="page-title">系统总览</h2>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :xs="12" :sm="6" v-for="s in statCards" :key="s.label">
        <el-card shadow="hover" class="stat-card" :style="{ borderTopColor: s.color }">
          <div class="stat-value" :style="{ color: s.color }">{{ s.value }}</div>
          <div class="stat-label">{{ s.label }}</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="16" style="margin-bottom: 20px">
      <el-col :xs="24" :sm="12">
        <el-card shadow="never">
          <template #header><span>车位占用率</span></template>
          <div ref="pieChartRef" style="height: 280px"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12">
        <el-card shadow="never">
          <template #header><span>路段泊位周转率</span></template>
          <div ref="barChartRef" style="height: 280px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 车位状态总览 -->
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>实时车位状态总览</span>
          <el-select v-model="roadFilter" placeholder="全部路段" clearable style="width: 200px" @change="loadSpaces">
            <el-option label="全部路段" value="" />
            <el-option v-for="r in roads" :key="r.road_id" :label="r.road_name" :value="r.road_id" />
          </el-select>
        </div>
      </template>
      <SpaceGrid :spaces="spaces" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import * as echarts from 'echarts'
import { getDashboardStats } from '../api/stats'
import { getRoads } from '../api/roads'
import { getSpaces } from '../api/spaces'
import { getDailyStats } from '../api/stats'
import SpaceGrid from '../components/SpaceGrid.vue'

const stats = ref({})
const roads = ref([])
const spaces = ref([])
const dailyStats = ref([])
const roadFilter = ref('')

const pieChartRef = ref(null)
const barChartRef = ref(null)
let pieChart = null
let barChart = null

const statCards = computed(() => [
  { label: '路段总数',   value: stats.value.total_roads ?? '-',   color: '#409eff' },
  { label: '总车位数',   value: stats.value.total_spaces ?? '-',  color: '#67c23a' },
  { label: '空闲车位',   value: stats.value.free_spaces ?? '-',   color: '#409eff' },
  { label: '占用率',     value: stats.value.occupancy_rate != null ? stats.value.occupancy_rate + '%' : '-', color: '#e6a23c' },
  { label: '今日出场',   value: stats.value.today_exits ?? '-',   color: '#722ed1' },
  { label: '今日营收',   value: stats.value.today_revenue != null ? '¥' + stats.value.today_revenue : '-', color: '#67c23a' },
  { label: '今日欠费',   value: stats.value.today_arrears != null ? '¥' + stats.value.today_arrears : '-', color: '#f56c6c' },
  { label: '注册用户',   value: stats.value.total_users ?? '-',   color: '#409eff' },
])

function initPieChart() {
  if (!pieChartRef.value) return
  pieChart = echarts.init(pieChartRef.value)
  const occupied = stats.value.occupied_spaces || 0
  const free = stats.value.free_spaces || 0
  pieChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0, itemWidth: 12, itemHeight: 12, textStyle: { fontSize: 12 } },
    series: [{
      type: 'pie',
      radius: ['45%', '70%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
      label: { show: true, formatter: '{b}\n{c}个', fontSize: 12 },
      data: [
        { value: occupied, name: '占用', itemStyle: { color: '#f56c6c' } },
        { value: free, name: '空闲', itemStyle: { color: '#67c23a' } },
      ]
    }]
  })
}

function initBarChart() {
  if (!barChartRef.value || !dailyStats.value.length) return
  barChart = echarts.init(barChartRef.value)
  const names = dailyStats.value.map(d => d.road_name)
  const turnover = dailyStats.value.map(d => Number(d.turnover_rate) || 0)
  const revenue = dailyStats.value.map(d => Number(d.expected_revenue) || 0)
  barChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, itemWidth: 12, itemHeight: 12, textStyle: { fontSize: 12 } },
    grid: { top: 10, bottom: 50, left: 50, right: 20 },
    xAxis: { type: 'category', data: names, axisLabel: { fontSize: 11 } },
    yAxis: [
      { type: 'value', name: '周转率', position: 'left', axisLabel: { fontSize: 11 } },
      { type: 'value', name: '金额(元)', position: 'right', axisLabel: { fontSize: 11 } }
    ],
    series: [
      {
        name: '泊位周转率', type: 'bar', data: turnover,
        itemStyle: { color: '#409eff', borderRadius: [4, 4, 0, 0] },
        barWidth: 30
      },
      {
        name: '应收金额', type: 'bar', yAxisIndex: 1, data: revenue,
        itemStyle: { color: '#e6a23c', borderRadius: [4, 4, 0, 0] },
        barWidth: 30
      }
    ]
  })
}

async function loadSpaces() {
  spaces.value = await getSpaces(roadFilter.value || undefined)
}

onMounted(async () => {
  const [s, r, d] = await Promise.all([
    getDashboardStats(),
    getRoads(),
    getDailyStats(new Date().toISOString().slice(0, 10))
  ])
  stats.value = s
  roads.value = r
  dailyStats.value = d
  await loadSpaces()

  await nextTick()
  initPieChart()
  initBarChart()

  window.addEventListener('resize', () => {
    pieChart?.resize()
    barChart?.resize()
  })
})
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; color: #1a1a2e; }
.stat-row .el-col { margin-bottom: 16px; }
.stat-card {
  text-align: center; border-top: 3px solid #409eff; border-radius: 8px;
  transition: transform 0.2s ease;
}
.stat-card:hover { transform: translateY(-2px); }
.stat-value { font-size: 28px; font-weight: 700; margin: 8px 0; }
.stat-label { font-size: 13px; color: #909399; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
