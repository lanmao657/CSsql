<template>
  <div>
    <h2 class="page-title">车位管理</h2>

    <el-card shadow="never" style="margin-bottom: 20px" v-loading="loading">
      <template #header>
        <div class="card-header">
          <div style="display: flex; align-items: center; gap: 16px">
            <el-select v-model="roadFilter" placeholder="全部路段" clearable style="width: 200px" @change="loadData">
              <el-option label="全部路段" value="" />
              <el-option v-for="r in roads" :key="r.road_id" :label="r.road_name" :value="r.road_id" />
            </el-select>
            <div class="legend">
              <el-tag type="success" size="small" effect="plain">空闲</el-tag>
              <el-tag type="danger" size="small" effect="plain">占用</el-tag>
              <el-tag type="warning" size="small" effect="plain">故障</el-tag>
              <el-tag size="small" effect="plain">预留</el-tag>
            </div>
          </div>
          <span style="font-size: 13px; color: #909399">共 {{ spaces.length }} 个车位</span>
        </div>
      </template>
      <SpaceGrid :spaces="spaces" />
    </el-card>

    <el-card shadow="never">
      <template #header><span>空闲车位明细（视图查询）</span></template>
      <el-table :data="available" stripe>
        <el-table-column prop="road_name" label="路段" />
        <el-table-column prop="space_number" label="编号" />
        <el-table-column prop="space_position" label="位置">
          <template #default="{ row }">{{ row.space_position || '-' }}</template>
        </el-table-column>
        <el-table-column label="空闲时长">
          <template #default="{ row }">{{ Math.round(row.minutes_since_freed) }} 分钟</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRoads } from '../api/roads'
import { getSpaces, getAvailableSpaces } from '../api/spaces'
import SpaceGrid from '../components/SpaceGrid.vue'

const roads = ref([])
const spaces = ref([])
const available = ref([])
const roadFilter = ref('')
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const rid = roadFilter.value || undefined
    const [s, a] = await Promise.all([getSpaces(rid), getAvailableSpaces(rid)])
    spaces.value = s
    available.value = a
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  roads.value = await getRoads()
  await loadData()
})
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.legend { display: flex; gap: 8px; }
</style>
