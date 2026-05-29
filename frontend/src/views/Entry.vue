<template>
  <div>
    <PageBanner type="entry" />

    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>入场登记</span></template>
      <el-form :inline="true" :model="form" @submit.prevent="handleEntry">
        <el-form-item label="选择路段">
          <el-select v-model="form.road_id" placeholder="请选择路段" style="width: 200px" @change="loadSpaces">
            <el-option v-for="r in roads" :key="r.road_id" :label="r.road_name + ' (' + r.section_code + ')'" :value="r.road_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="选择车位">
          <el-select v-model="form.space_id" placeholder="请先选择路段" style="width: 260px">
            <el-option v-for="s in availableSpaces" :key="s.space_id"
              :label="s.space_number + ' - ' + (s.space_position || '') + ' (空闲' + Math.round(s.minutes_since_freed) + '分)'"
              :value="s.space_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="车牌号码">
          <el-input v-model="form.plate_number" placeholder="京A·12345" />
        </el-form-item>
        <el-form-item>
          <el-button type="success" @click="handleEntry">确认入场</el-button>
        </el-form-item>
      </el-form>

      <el-alert v-if="entryResult" :title="entryResult.message" type="success" show-icon
        :closable="true" @close="entryResult = null" style="margin-top: 12px" />
      <el-alert v-if="entryError" :title="entryError" type="error" show-icon
        :closable="true" @close="entryError = null" style="margin-top: 12px" />
    </el-card>

    <el-card shadow="never">
      <template #header><span>当前在场车辆</span></template>
      <el-table :data="entries" stripe>
        <el-table-column prop="plate_number" label="车牌" />
        <el-table-column prop="road_name" label="路段" />
        <el-table-column prop="space_id" label="车位ID" width="80" />
        <el-table-column label="入场时间">
          <template #default="{ row }">{{ formatTime(row.entry_time) }}</template>
        </el-table-column>
        <el-table-column label="地磁状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.geomagnetic_status === 'occupied' ? 'danger' : 'success'" size="small">
              {{ row.geomagnetic_status === 'occupied' ? '有车' : '空地' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.current_status === '在场' ? 'danger' : 'success'" size="small">
              {{ row.current_status }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getRoads } from '../api/roads'
import { getAvailableSpaces } from '../api/spaces'
import { vehicleEntry, getEntries } from '../api/parking'
import PageBanner from '../components/PageBanner.vue'

const roads = ref([])
const availableSpaces = ref([])
const entries = ref([])
const form = ref({ road_id: null, space_id: null, plate_number: '' })
const entryResult = ref(null)
const entryError = ref(null)

function formatTime(t) {
  return t ? new Date(t).toLocaleString('zh-CN') : '-'
}

async function loadSpaces() {
  form.value.space_id = null
  if (!form.value.road_id) { availableSpaces.value = []; return }
  availableSpaces.value = await getAvailableSpaces(form.value.road_id)
}

async function loadEntries() {
  entries.value = await getEntries()
}

async function handleEntry() {
  entryResult.value = null
  entryError.value = null
  if (!form.value.road_id || !form.value.space_id || !form.value.plate_number.trim()) {
    ElMessage.warning('请完整填写入场信息')
    return
  }
  try {
    const res = await vehicleEntry({
      road_id: form.value.road_id,
      space_id: form.value.space_id,
      plate_number: form.value.plate_number.trim()
    })
    entryResult.value = res
    ElMessage.success(res.message)
    form.value.plate_number = ''
    await loadSpaces()
    await loadEntries()
  } catch (e) {
    entryError.value = e.response?.data?.error || '入场失败'
  }
}

onMounted(async () => {
  roads.value = await getRoads()
  await loadEntries()
})
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
