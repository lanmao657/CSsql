<template>
  <div class="space-grid">
    <div
      v-for="space in spaces"
      :key="space.space_id"
      class="space-box"
      :class="space.status"
    >
      <div class="num">{{ space.space_number }}</div>
      <div class="info">{{ space.road_name }}</div>
      <div class="info">{{ space.space_position || '-' }}</div>
      <div class="info">{{ space.plate_number || '-' }}</div>
    </div>
    <el-empty v-if="!spaces.length" description="暂无车位数据" />
  </div>
</template>

<script setup>
defineProps({
  spaces: { type: Array, default: () => [] }
})
</script>

<style scoped>
.space-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
}
.space-box {
  padding: 12px; border-radius: 8px; text-align: center;
  border: 2px solid #e0e0e0; transition: all .2s;
}
.space-box.free     { background: #f6ffed; border-color: #b7eb8f; }
.space-box.occupied { background: #fff1f0; border-color: #ffa39e; }
.space-box.fault    { background: #fff7e6; border-color: #ffd591; }
.space-box.reserved { background: #f0f5ff; border-color: #adc6ff; }
.space-box .num  { font-weight: 700; font-size: 15px; }
.space-box .info { font-size: 11px; color: #888; margin-top: 4px; }
</style>
