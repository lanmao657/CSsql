<template>
  <div>
    <PageBanner type="users" />

    <!-- 用户注册 -->
    <el-card shadow="never" style="margin-bottom: 20px">
      <template #header><span>用户注册</span></template>
      <el-form :inline="true" :model="form" @submit.prevent="handleAddUser">
        <el-form-item label="用户名"><el-input v-model="form.username" placeholder="中文姓名" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="form.phone" placeholder="13800001111" /></el-form-item>
        <el-form-item label="初始余额"><el-input-number v-model="form.balance" :min="0" :step="10" /></el-form-item>
        <el-form-item><el-button type="primary" @click="handleAddUser">注册</el-button></el-form-item>
      </el-form>
    </el-card>

    <!-- 用户列表 -->
    <el-card shadow="never">
      <template #header><span>用户列表</span></template>
      <el-table :data="users" stripe>
        <el-table-column prop="user_id" label="ID" width="60" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="phone" label="手机号" />
        <el-table-column label="余额">
          <template #default="{ row }">¥{{ row.balance }}</template>
        </el-table-column>
        <el-table-column prop="vehicle_count" label="车辆数" width="80" />
        <el-table-column label="欠费">
          <template #default="{ row }">
            <span v-if="Number(row.total_arrears) > 0" style="color: #f5222d">¥{{ row.total_arrears }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'" size="small">
              {{ row.status === 'active' ? '正常' : row.status === 'arrears' ? '欠费' : row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template #default="{ row }">
            <el-button size="small" type="success" @click="showTopup(row)">充值</el-button>
            <el-button size="small" @click="showVehicles(row)">车辆</el-button>
            <el-button size="small" @click="showBind(row)">绑定</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 充值弹窗 -->
    <el-dialog v-model="topupVisible" :title="'充值 - ' + topupUser.username" width="400">
      <el-form label-width="80px">
        <el-form-item label="充值金额">
          <el-input-number v-model="topupAmount" :min="1" :step="10" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="topupVisible = false">取消</el-button>
        <el-button type="success" @click="handleTopup">确认充值</el-button>
      </template>
    </el-dialog>

    <!-- 车辆列表弹窗 -->
    <el-dialog v-model="vehicleVisible" :title="vehicleUser.username + ' - 绑定车辆'" width="500">
      <el-table :data="vehicles" stripe>
        <el-table-column prop="plate_number" label="车牌号" />
        <el-table-column label="绑定时间">
          <template #default="{ row }">{{ formatTime(row.bind_time) }}</template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!vehicles.length" description="暂无绑定车辆" />
    </el-dialog>

    <!-- 绑定车辆弹窗 -->
    <el-dialog v-model="bindVisible" title="绑定车辆" width="400">
      <el-form label-width="80px">
        <el-form-item label="车牌号码">
          <el-input v-model="bindPlate" placeholder="京A·12345" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="bindVisible = false">取消</el-button>
        <el-button type="primary" @click="handleBind">绑定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getUsers, addUser, topupUser as topupUserApi, getUserVehicles, bindVehicle } from '../api/users'
import PageBanner from '../components/PageBanner.vue'

const users = ref([])
const form = ref({ username: '', phone: '', balance: 0 })

const topupVisible = ref(false)
const topupUser = ref({})
const topupAmount = ref(100)

const vehicleVisible = ref(false)
const vehicleUser = ref({})
const vehicles = ref([])

const bindVisible = ref(false)
const bindUserId = ref(null)
const bindPlate = ref('')

function formatTime(t) {
  return t ? new Date(t).toLocaleString('zh-CN') : '-'
}

async function loadUsers() {
  users.value = await getUsers()
}

async function handleAddUser() {
  await addUser(form.value)
  ElMessage.success('注册成功')
  form.value = { username: '', phone: '', balance: 0 }
  await loadUsers()
}

function showTopup(row) {
  topupUser.value = row
  topupAmount.value = 100
  topupVisible.value = true
}

async function handleTopup() {
  const res = await topupUserApi(topupUser.value.user_id, topupAmount.value)
  ElMessage.success(res.message)
  topupVisible.value = false
  await loadUsers()
}

async function showVehicles(row) {
  vehicleUser.value = row
  vehicles.value = await getUserVehicles(row.user_id)
  vehicleVisible.value = true
}

function showBind(row) {
  bindUserId.value = row.user_id
  bindPlate.value = ''
  bindVisible.value = true
}

async function handleBind() {
  if (!bindPlate.value.trim()) { ElMessage.warning('请输入车牌号'); return }
  await bindVehicle({ user_id: bindUserId.value, plate_number: bindPlate.value.trim() })
  ElMessage.success('绑定成功')
  bindVisible.value = false
  await loadUsers()
}

onMounted(loadUsers)
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 600; margin-bottom: 20px; }
</style>
