<template>
  <div>
    <PageBanner type="roads" />

    <!-- 添加路段 -->
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>添加路段</span></template>
      <el-form :inline="true" :model="form" @submit.prevent="handleAddRoad">
        <el-form-item label="路段名称"><el-input v-model="form.road_name" placeholder="例：中山北路" /></el-form-item>
        <el-form-item label="路段编号"><el-input v-model="form.section_code" placeholder="例：ZSBL-005" /></el-form-item>
        <el-form-item label="规划车位数"><el-input-number v-model="form.total_spaces" :min="1" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="form.address" placeholder="路段起止位置" /></el-form-item>
        <el-form-item><el-button type="primary" @click="handleAddRoad">添加路段</el-button></el-form-item>
      </el-form>
    </el-card>

    <!-- 路段列表 -->
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>路段列表</span></template>
      <el-table :data="roads" stripe>
        <el-table-column prop="road_id" label="ID" width="60" />
        <el-table-column prop="road_name" label="路段名称" />
        <el-table-column prop="section_code" label="编号" />
        <el-table-column prop="total_spaces" label="规划车位" width="90" />
        <el-table-column prop="actual_spaces" label="实际车位" width="90" />
        <el-table-column prop="free_spaces" label="空闲车位" width="90" />
        <el-table-column prop="address" label="地址" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 'normal' ? 'success' : 'warning'" size="small">
              {{ row.status === 'normal' ? '正常' : row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="showStandards(row)">收费标准</el-button>
            <el-button size="small" type="danger" @click="handleDeleteRoad(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 收费标准管理 -->
    <el-card shadow="never">
      <template #header><span>收费标准管理</span></template>
      <el-form :inline="true" :model="stdForm" @submit.prevent="handleAddStandard">
        <el-form-item label="选择路段">
          <el-select v-model="stdForm.road_id" placeholder="请选择" style="width: 200px" @change="loadStandards">
            <el-option v-for="r in roads" :key="r.road_id" :label="r.road_name" :value="r.road_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="时段名称"><el-input v-model="stdForm.period_name" placeholder="例：日间" /></el-form-item>
        <el-form-item label="开始时"><el-input-number v-model="stdForm.start_hour" :min="0" :max="23" /></el-form-item>
        <el-form-item label="结束时"><el-input-number v-model="stdForm.end_hour" :min="0" :max="24" /></el-form-item>
        <el-form-item label="单价(元/h)"><el-input-number v-model="stdForm.price_per_hour" :min="0" :step="0.5" /></el-form-item>
        <el-form-item><el-button type="primary" @click="handleAddStandard">添加标准</el-button></el-form-item>
      </el-form>
      <el-table :data="standards" stripe style="margin-top: 12px">
        <el-table-column prop="standard_id" label="ID" width="60" />
        <el-table-column label="路段" width="120">
          <template #default>{{ currentRoadName }}</template>
        </el-table-column>
        <el-table-column prop="period_name" label="时段" />
        <el-table-column label="时间段">
          <template #default="{ row }">{{ row.start_hour }}:00 - {{ row.end_hour }}:00</template>
        </el-table-column>
        <el-table-column label="单价(元/h)">
          <template #default="{ row }">¥{{ row.price_per_hour }}</template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 收费标准弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogRoadName + ' - 收费标准'" width="500">
      <el-table :data="dialogStandards" stripe>
        <el-table-column prop="standard_id" label="ID" width="60" />
        <el-table-column prop="period_name" label="时段" />
        <el-table-column label="时间段">
          <template #default="{ row }">{{ row.start_hour }}:00 - {{ row.end_hour }}:00</template>
        </el-table-column>
        <el-table-column label="单价(元/h)">
          <template #default="{ row }">¥{{ row.price_per_hour }}</template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getRoads, addRoad, deleteRoad, getStandards, addStandard } from '../api/roads'
import PageBanner from '../components/PageBanner.vue'

const roads = ref([])
const standards = ref([])
const currentRoadName = ref('')

const form = ref({ road_name: '', section_code: '', total_spaces: 8, address: '' })
const stdForm = ref({ road_id: null, period_name: '', start_hour: 8, end_hour: 17, price_per_hour: 8 })

const dialogVisible = ref(false)
const dialogRoadName = ref('')
const dialogStandards = ref([])

async function loadRoads() {
  roads.value = await getRoads()
}

async function loadStandards() {
  if (!stdForm.value.road_id) { standards.value = []; return }
  standards.value = await getStandards(stdForm.value.road_id)
  currentRoadName.value = roads.value.find(r => r.road_id === stdForm.value.road_id)?.road_name || ''
}

async function handleAddRoad() {
  await addRoad(form.value)
  ElMessage.success('路段添加成功')
  form.value = { road_name: '', section_code: '', total_spaces: 8, address: '' }
  await loadRoads()
}

async function handleDeleteRoad(row) {
  await ElMessageBox.confirm('确定删除该路段？', '提示', { type: 'warning' })
  await deleteRoad(row.road_id)
  ElMessage.success('删除成功')
  await loadRoads()
}

async function handleAddStandard() {
  await addStandard(stdForm.value)
  ElMessage.success('收费标准添加成功')
  await loadStandards()
}

async function showStandards(row) {
  dialogRoadName.value = row.road_name
  dialogStandards.value = await getStandards(row.road_id)
  dialogVisible.value = true
}

onMounted(loadRoads)
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
