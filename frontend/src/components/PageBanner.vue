<template>
  <div class="page-banner" :style="{ background: config.gradient }">
    <div class="page-banner__content">
      <div class="page-banner__icon">
        <el-icon :size="42"><component :is="config.icon" /></el-icon>
      </div>
      <div class="page-banner__text">
        <h2 class="page-banner__title">{{ config.label }}</h2>
        <p class="page-banner__subtitle">{{ subtitle || config.desc }}</p>
      </div>
    </div>
    <div class="page-banner__illustration" v-html="illustrations[type]"></div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: { type: String, required: true },
  subtitle: { type: String, default: '' }
})

const configMap = {
  dashboard: { gradient: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 40%, #0f3460 100%)', icon: 'DataAnalysis', label: '系统总览', desc: '实时监控停车场运营数据与车位状态' },
  roads:     { gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', icon: 'Guide', label: '路段管理', desc: '管理城市路侧停车路段与收费标准' },
  spaces:    { gradient: 'linear-gradient(135deg, #11998e 0%, #38ef7d 100%)', icon: 'Grid', label: '车位管理', desc: '实时可视化车位占用情况与空闲明细' },
  users:     { gradient: 'linear-gradient(135deg, #6a11cb 0%, #2575fc 100%)', icon: 'User', label: '用户管理', desc: '用户注册、充值、车辆绑定与状态管理' },
  entry:     { gradient: 'linear-gradient(135deg, #11998e 0%, #0d8a7a 50%, #1a7a6d 100%)', icon: 'Right', label: '车辆入场', desc: '记录车辆入场、分配车位与地磁感应' },
  exit:      { gradient: 'linear-gradient(135deg, #f7971e 0%, #ffd200 100%)', icon: 'Back', label: '车辆出场', desc: '处理车辆出场、自动计费与余额结算' },
  billing:   { gradient: 'linear-gradient(135deg, #2193b0 0%, #6dd5ed 100%)', icon: 'Money', label: '计费记录', desc: '停车费用明细、支付状态与结算管理' },
  arrears:   { gradient: 'linear-gradient(135deg, #eb3349 0%, #f45c43 100%)', icon: 'Warning', label: '欠费追缴', desc: '欠费记录跟踪、催缴状态与减免处理' },
  statistics:{ gradient: 'linear-gradient(135deg, #4568dc 0%, #b06ab3 100%)', icon: 'TrendCharts', label: '统计分析', desc: '路段营收排名、周转率与空闲车位查询' }
}

const config = computed(() => configMap[props.type] || configMap.dashboard)

const illustrations = {
  dashboard: `
    <svg viewBox="0 0 520 150" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="d-sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#1a1a3e" />
          <stop offset="100%" stop-color="#2d2d5e" />
        </linearGradient>
        <linearGradient id="d-ground" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#2c2c4a" />
          <stop offset="100%" stop-color="#1a1a2e" />
        </linearGradient>
      </defs>
      <rect width="520" height="150" fill="url(#d-sky)" />
      <!-- Stars -->
      <circle cx="40" cy="20" r="1" fill="#fff" opacity="0.7" />
      <circle cx="100" cy="12" r="1.5" fill="#fff" opacity="0.5" />
      <circle cx="180" cy="25" r="1" fill="#fff" opacity="0.8" />
      <circle cx="250" cy="10" r="1.5" fill="#fff" opacity="0.6" />
      <circle cx="320" cy="18" r="1" fill="#fff" opacity="0.7" />
      <circle cx="400" cy="8" r="1.5" fill="#fff" opacity="0.5" />
      <circle cx="460" cy="22" r="1" fill="#fff" opacity="0.8" />
      <circle cx="490" cy="15" r="1" fill="#fff" opacity="0.6" />
      <!-- Moon -->
      <circle cx="470" cy="30" r="12" fill="#ffd700" opacity="0.15" />
      <circle cx="474" cy="27" r="10" fill="#ffd700" opacity="0.25" />
      <!-- Buildings -->
      <rect x="30" y="50" width="28" height="100" rx="2" fill="#3d3d6b" />
      <rect x="34" y="56" width="5" height="6" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="43" y="56" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="34" y="68" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="43" y="68" width="5" height="6" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="34" y="80" width="5" height="6" rx="1" fill="#ffd700" opacity="0.4" />
      <rect x="43" y="80" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="68" y="30" width="35" height="120" rx="2" fill="#2e2e5a" />
      <rect x="73" y="36" width="5" height="6" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="83" y="36" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="93" y="36" width="5" height="6" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="73" y="50" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="83" y="50" width="5" height="6" rx="1" fill="#ffd700" opacity="0.8" />
      <rect x="93" y="50" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.4" />
      <rect x="73" y="64" width="5" height="6" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="83" y="64" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="93" y="64" width="5" height="6" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="73" y="78" width="5" height="6" rx="1" fill="#87ceeb" opacity="0.8" />
      <rect x="83" y="78" width="5" height="6" rx="1" fill="#ffd700" opacity="0.4" />
      <rect x="115" y="65" width="25" height="85" rx="2" fill="#44447a" />
      <rect x="119" y="71" width="4" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="127" y="71" width="4" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="119" y="82" width="4" height="5" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="127" y="82" width="4" height="5" rx="1" fill="#ffd700" opacity="0.4" />
      <rect x="150" y="40" width="32" height="110" rx="2" fill="#3a3a6a" />
      <rect x="155" y="46" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="164" y="46" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="173" y="46" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="155" y="58" width="5" height="5" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="164" y="58" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.8" />
      <rect x="173" y="58" width="5" height="5" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="155" y="70" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.4" />
      <rect x="164" y="70" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="195" y="20" width="40" height="130" rx="2" fill="#2d2d58" />
      <rect x="200" y="26" width="5" height="5" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="210" y="26" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="220" y="26" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="200" y="38" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="210" y="38" width="5" height="5" rx="1" fill="#ffd700" opacity="0.8" />
      <rect x="220" y="38" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.4" />
      <rect x="200" y="50" width="5" height="5" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="210" y="50" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="220" y="50" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="200" y="62" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.8" />
      <rect x="210" y="62" width="5" height="5" rx="1" fill="#ffd700" opacity="0.4" />
      <rect x="250" y="55" width="28" height="95" rx="2" fill="#3e3e70" />
      <rect x="254" y="61" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="263" y="61" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="254" y="73" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="263" y="73" width="5" height="5" rx="1" fill="#ffd700" opacity="0.8" />
      <rect x="290" y="35" width="38" height="115" rx="2" fill="#333366" />
      <rect x="295" y="41" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="305" y="41" width="5" height="5" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="315" y="41" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="295" y="53" width="5" height="5" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="305" y="53" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.8" />
      <rect x="315" y="53" width="5" height="5" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="340" y="70" width="22" height="80" rx="2" fill="#484880" />
      <rect x="344" y="76" width="4" height="5" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="352" y="76" width="4" height="5" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="375" y="45" width="45" height="105" rx="2" fill="#3b3b6e" />
      <rect x="380" y="51" width="6" height="6" rx="1" fill="#ffd700" opacity="0.6" />
      <rect x="392" y="51" width="6" height="6" rx="1" fill="#87ceeb" opacity="0.7" />
      <rect x="404" y="51" width="6" height="6" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="380" y="65" width="6" height="6" rx="1" fill="#87ceeb" opacity="0.5" />
      <rect x="392" y="65" width="6" height="6" rx="1" fill="#ffd700" opacity="0.8" />
      <rect x="404" y="65" width="6" height="6" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="380" y="79" width="6" height="6" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="392" y="79" width="6" height="6" rx="1" fill="#87ceeb" opacity="0.4" />
      <rect x="435" y="60" width="30" height="90" rx="2" fill="#36366a" />
      <rect x="440" y="66" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.6" />
      <rect x="449" y="66" width="5" height="5" rx="1" fill="#ffd700" opacity="0.7" />
      <rect x="440" y="78" width="5" height="5" rx="1" fill="#ffd700" opacity="0.5" />
      <rect x="449" y="78" width="5" height="5" rx="1" fill="#87ceeb" opacity="0.8" />
      <rect x="478" y="75" width="22" height="75" rx="2" fill="#3f3f72" />
      <!-- Ground -->
      <rect x="0" y="140" width="520" height="10" fill="url(#d-ground)" />
      <!-- Road -->
      <rect x="0" y="136" width="520" height="4" fill="#3a3a5c" />
      <line x1="20" y1="138" x2="40" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="70" y1="138" x2="90" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="120" y1="138" x2="140" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="170" y1="138" x2="190" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="220" y1="138" x2="240" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="270" y1="138" x2="290" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="320" y1="138" x2="340" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="370" y1="138" x2="390" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="420" y1="138" x2="440" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="470" y1="138" x2="490" y2="138" stroke="#ffd700" stroke-width="0.8" stroke-dasharray="8 6" opacity="0.5" />
      <!-- Parking P sign -->
      <circle cx="105" cy="128" r="6" fill="#409eff" />
      <text x="105" y="131" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">P</text>
      <!-- Data points -->
      <circle cx="200" cy="18" r="4" fill="none" stroke="#67c23a" stroke-width="1.5" opacity="0.7">
        <animate attributeName="r" values="3;5;3" dur="2s" repeatCount="indefinite" />
        <animate attributeName="opacity" values="0.7;0.3;0.7" dur="2s" repeatCount="indefinite" />
      </circle>
      <circle cx="300" cy="25" r="4" fill="none" stroke="#409eff" stroke-width="1.5" opacity="0.7">
        <animate attributeName="r" values="4;6;4" dur="2.5s" repeatCount="indefinite" />
        <animate attributeName="opacity" values="0.5;0.3;0.5" dur="2.5s" repeatCount="indefinite" />
      </circle>
      <circle cx="400" cy="15" r="4" fill="none" stroke="#e6a23c" stroke-width="1.5" opacity="0.7">
        <animate attributeName="r" values="3;5;3" dur="3s" repeatCount="indefinite" />
        <animate attributeName="opacity" values="0.6;0.3;0.6" dur="3s" repeatCount="indefinite" />
      </circle>
      <!-- Floating decorations -->
      <circle cx="80" cy="25" r="6" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1.5" class="float-slow" />
      <polygon points="350,22 356,12 362,22" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-fast" />
      <circle cx="500" cy="45" r="4" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1" class="float-slow" />
    </svg>`,

  roads: `
    <svg viewBox="0 0 480 140" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="r-sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#8e9eab" />
          <stop offset="100%" stop-color="#667eea" />
        </linearGradient>
      </defs>
      <rect width="480" height="140" fill="url(#r-sky)" />
      <!-- Distant hills -->
      <ellipse cx="120" cy="85" rx="160" ry="35" fill="#7b68ae" opacity="0.4" />
      <ellipse cx="350" cy="88" rx="180" ry="30" fill="#7b68ae" opacity="0.3" />
      <!-- Road perspective -->
      <polygon points="200,50 280,50 480,140 0,140" fill="#555" />
      <polygon points="210,50 270,50 440,140 40,140" fill="#444" />
      <!-- Lane markings -->
      <line x1="240" y1="55" x2="240" y2="140" stroke="#ffd700" stroke-width="2" stroke-dasharray="10 8" opacity="0.8" />
      <line x1="340" y1="140" x2="260" y2="60" stroke="#fff" stroke-width="1.5" stroke-dasharray="8 12" opacity="0.4" />
      <line x1="140" y1="140" x2="220" y2="60" stroke="#fff" stroke-width="1.5" stroke-dasharray="8 12" opacity="0.4" />
      <!-- Side buildings -->
      <rect x="10" y="60" width="18" height="80" rx="1" fill="#8b7dbd" />
      <rect x="14" y="66" width="3" height="4" rx="0.5" fill="#ffd700" opacity="0.6" />
      <rect x="21" y="66" width="3" height="4" rx="0.5" fill="#87ceeb" opacity="0.5" />
      <rect x="14" y="76" width="3" height="4" rx="0.5" fill="#87ceeb" opacity="0.5" />
      <rect x="35" y="50" width="22" height="90" rx="1" fill="#7b6fae" />
      <rect x="40" y="56" width="4" height="4" rx="0.5" fill="#ffd700" opacity="0.5" />
      <rect x="48" y="56" width="4" height="4" rx="0.5" fill="#87ceeb" opacity="0.6" />
      <rect x="40" y="66" width="4" height="4" rx="0.5" fill="#87ceeb" opacity="0.6" />
      <rect x="48" y="66" width="4" height="4" rx="0.5" fill="#ffd700" opacity="0.5" />
      <rect x="440" y="55" width="16" height="85" rx="1" fill="#8b7dbd" />
      <rect x="443" y="61" width="3" height="4" rx="0.5" fill="#ffd700" opacity="0.6" />
      <rect x="450" y="61" width="3" height="4" rx="0.5" fill="#87ceeb" opacity="0.5" />
      <rect x="462" y="65" width="18" height="75" rx="1" fill="#7b6fae" />
      <rect x="466" y="71" width="3" height="4" rx="0.5" fill="#87ceeb" opacity="0.6" />
      <rect x="473" y="71" width="3" height="4" rx="0.5" fill="#ffd700" opacity="0.5" />
      <!-- Roadside trees -->
      <circle cx="85" cy="75" r="10" fill="#38b06a" opacity="0.7" />
      <rect x="83" y="85" width="4" height="15" fill="#8b6914" opacity="0.6" />
      <circle cx="400" cy="72" r="10" fill="#38b06a" opacity="0.7" />
      <rect x="398" y="82" width="4" height="15" fill="#8b6914" opacity="0.6" />
      <!-- Traffic sign -->
      <rect x="168" y="48" width="3" height="25" fill="#888" />
      <rect x="160" y="42" width="19" height="12" rx="2" fill="#409eff" />
      <text x="169.5" y="51" text-anchor="middle" fill="#fff" font-size="7" font-weight="bold">P</text>
      <!-- Vehicles -->
      <g transform="translate(220, 80) scale(0.6)">
        <rect x="0" y="2" width="25" height="12" rx="4" fill="#409eff" />
        <rect x="4" y="0" width="8" height="6" rx="2" fill="#87ceeb" opacity="0.7" />
        <circle cx="5" cy="15" r="3" fill="#333" />
        <circle cx="20" cy="15" r="3" fill="#333" />
      </g>
      <g transform="translate(280, 95) scale(0.55)">
        <rect x="0" y="2" width="25" height="12" rx="4" fill="#67c23a" />
        <rect x="4" y="0" width="8" height="6" rx="2" fill="#87ceeb" opacity="0.7" />
        <circle cx="5" cy="15" r="3" fill="#333" />
        <circle cx="20" cy="15" r="3" fill="#333" />
      </g>
      <!-- Clouds -->
      <ellipse cx="150" cy="20" rx="25" ry="8" fill="#fff" opacity="0.2" />
      <ellipse cx="160" cy="18" rx="15" ry="6" fill="#fff" opacity="0.15" />
      <ellipse cx="380" cy="15" rx="20" ry="7" fill="#fff" opacity="0.2" />
      <!-- Floating decorations -->
      <circle cx="60" cy="20" r="5" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="1" class="float-slow" />
      <circle cx="430" cy="25" r="4" fill="none" stroke="rgba(255,255,255,0.12)" stroke-width="1" class="float-fast" />
    </svg>`,

  spaces: `
    <svg viewBox="0 0 460 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="s-bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#1a6b5a" />
          <stop offset="100%" stop-color="#0d8a7a" />
        </linearGradient>
      </defs>
      <rect width="460" height="130" fill="url(#s-bg)" />
      <!-- Parking lot surface -->
      <rect x="30" y="20" width="400" height="95" rx="4" fill="#4a4a4a" opacity="0.4" />
      <!-- Grid lines -->
      <line x1="30" y1="55" x2="430" y2="55" stroke="#fff" stroke-width="1" opacity="0.3" />
      <line x1="30" y1="85" x2="430" y2="85" stroke="#fff" stroke-width="1" opacity="0.3" />
      <line x1="110" y1="20" x2="110" y2="115" stroke="#fff" stroke-width="1" opacity="0.3" />
      <line x1="190" y1="20" x2="190" y2="115" stroke="#fff" stroke-width="1" opacity="0.3" />
      <line x1="270" y1="20" x2="270" y2="115" stroke="#fff" stroke-width="1" opacity="0.3" />
      <line x1="350" y1="20" x2="350" y2="115" stroke="#fff" stroke-width="1" opacity="0.3" />
      <!-- Parking spaces - Row 1 -->
      <rect x="38" y="24" width="64" height="26" rx="3" fill="#52c41a" opacity="0.8" />
      <text x="70" y="40" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">A01</text>
      <circle cx="48" cy="32" r="2" fill="#fff" opacity="0.4" />
      <rect x="118" y="24" width="64" height="26" rx="3" fill="#ff4d4f" opacity="0.8" />
      <text x="150" y="40" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">A02</text>
      <circle cx="128" cy="32" r="2" fill="#fff" opacity="0.4" />
      <rect x="198" y="24" width="64" height="26" rx="3" fill="#52c41a" opacity="0.8" />
      <text x="230" y="40" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">A03</text>
      <circle cx="208" cy="32" r="2" fill="#fff" opacity="0.4" />
      <rect x="278" y="24" width="64" height="26" rx="3" fill="#ff4d4f" opacity="0.8" />
      <text x="310" y="40" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">A04</text>
      <circle cx="288" cy="32" r="2" fill="#fff" opacity="0.4" />
      <rect x="358" y="24" width="64" height="26" rx="3" fill="#faad14" opacity="0.8" />
      <text x="390" y="40" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">A05</text>
      <circle cx="368" cy="32" r="2" fill="#fff" opacity="0.4" />
      <!-- Row 2 -->
      <rect x="38" y="58" width="64" height="24" rx="3" fill="#ff4d4f" opacity="0.8" />
      <text x="70" y="73" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">B01</text>
      <circle cx="48" cy="66" r="2" fill="#fff" opacity="0.4" />
      <rect x="118" y="58" width="64" height="24" rx="3" fill="#52c41a" opacity="0.8" />
      <text x="150" y="73" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">B02</text>
      <circle cx="128" cy="66" r="2" fill="#fff" opacity="0.4" />
      <rect x="198" y="58" width="64" height="24" rx="3" fill="#ff4d4f" opacity="0.8" />
      <text x="230" y="73" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">B03</text>
      <circle cx="208" cy="66" r="2" fill="#fff" opacity="0.4" />
      <rect x="278" y="58" width="64" height="24" rx="3" fill="#52c41a" opacity="0.8" />
      <text x="310" y="73" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">B04</text>
      <circle cx="288" cy="66" r="2" fill="#fff" opacity="0.4" />
      <rect x="358" y="58" width="64" height="24" rx="3" fill="#1890ff" opacity="0.8" />
      <text x="390" y="73" text-anchor="middle" fill="#fff" font-size="8" font-weight="bold">B05</text>
      <circle cx="368" cy="66" r="2" fill="#fff" opacity="0.4" />
      <!-- Entrance arrow -->
      <polygon points="220,118 235,108 250,118" fill="#fff" opacity="0.5" />
      <text x="235" y="128" text-anchor="middle" fill="#fff" font-size="7" opacity="0.6">入口</text>
      <!-- Gate barrier -->
      <rect x="195" y="100" width="3" height="18" fill="#888" />
      <rect x="195" y="99" width="44" height="3" rx="1" fill="#f5222d" opacity="0.8" />
      <!-- Floating decorations -->
      <circle cx="20" cy="15" r="4" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="1" class="float-slow" />
      <circle cx="445" cy="18" r="5" fill="none" stroke="rgba(255,255,255,0.12)" stroke-width="1" class="float-fast" />
      <polygon points="450,10 454,4 458,10" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1" class="float-slow" />
    </svg>`,

  users: `
    <svg viewBox="0 0 420 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="u-bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#4a1a8a" />
          <stop offset="100%" stop-color="#2575fc" />
        </linearGradient>
      </defs>
      <rect width="420" height="130" fill="url(#u-bg)" />
      <circle cx="60" cy="25" r="20" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1.5" />
      <circle cx="380" cy="100" r="25" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1.5" />
      <circle cx="350" cy="20" r="8" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1" class="float-slow" />
      <circle cx="80" cy="110" r="6" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-fast" />
      <!-- Connection lines -->
      <line x1="210" y1="50" x2="110" y2="70" stroke="rgba(255,255,255,0.15)" stroke-width="1" stroke-dasharray="4 3" />
      <line x1="210" y1="50" x2="310" y2="65" stroke="rgba(255,255,255,0.15)" stroke-width="1" stroke-dasharray="4 3" />
      <line x1="210" y1="50" x2="150" y2="100" stroke="rgba(255,255,255,0.12)" stroke-width="1" stroke-dasharray="4 3" />
      <line x1="210" y1="50" x2="275" y2="105" stroke="rgba(255,255,255,0.12)" stroke-width="1" stroke-dasharray="4 3" />
      <line x1="210" y1="50" x2="60" y2="55" stroke="rgba(255,255,255,0.1)" stroke-width="1" stroke-dasharray="4 3" />
      <line x1="210" y1="50" x2="360" y2="40" stroke="rgba(255,255,255,0.1)" stroke-width="1" stroke-dasharray="4 3" />
      <!-- Central user (main) -->
      <circle cx="210" cy="42" r="14" fill="#6a11cb" stroke="rgba(255,255,255,0.4)" stroke-width="2" />
      <circle cx="210" cy="37" r="5" fill="#fff" opacity="0.9" />
      <path d="M200 52 Q210 60 220 52" fill="#fff" opacity="0.9" />
      <!-- Surrounding users -->
      <g>
        <circle cx="110" cy="62" r="10" fill="#764ba2" stroke="rgba(255,255,255,0.3)" stroke-width="1.5" />
        <circle cx="110" cy="58" r="3.5" fill="#fff" opacity="0.8" />
        <path d="M103 67 Q110 73 117 67" fill="#fff" opacity="0.8" />
      </g>
      <g>
        <circle cx="310" cy="58" r="10" fill="#764ba2" stroke="rgba(255,255,255,0.3)" stroke-width="1.5" />
        <circle cx="310" cy="54" r="3.5" fill="#fff" opacity="0.8" />
        <path d="M303 63 Q310 69 317 63" fill="#fff" opacity="0.8" />
      </g>
      <g>
        <circle cx="150" cy="95" r="9" fill="#2575fc" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <circle cx="150" cy="91" r="3" fill="#fff" opacity="0.8" />
        <path d="M144 99 Q150 105 156 99" fill="#fff" opacity="0.8" />
      </g>
      <g>
        <circle cx="275" cy="98" r="9" fill="#2575fc" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <circle cx="275" cy="94" r="3" fill="#fff" opacity="0.8" />
        <path d="M269 103 Q275 109 281 103" fill="#fff" opacity="0.8" />
      </g>
      <g>
        <circle cx="60" cy="50" r="8" fill="#2575fc" stroke="rgba(255,255,255,0.2)" stroke-width="1" />
        <circle cx="60" cy="46" r="2.5" fill="#fff" opacity="0.7" />
        <path d="M55 54 Q60 59 65 54" fill="#fff" opacity="0.7" />
      </g>
      <g>
        <circle cx="360" cy="35" r="8" fill="#2575fc" stroke="rgba(255,255,255,0.2)" stroke-width="1" />
        <circle cx="360" cy="31" r="2.5" fill="#fff" opacity="0.7" />
        <path d="M355 39 Q360 44 365 39" fill="#fff" opacity="0.7" />
      </g>
      <!-- Vehicle icons near users -->
      <g transform="translate(325,70) scale(0.5)">
        <rect x="0" y="2" width="20" height="10" rx="4" fill="#ffd700" opacity="0.6" />
        <circle cx="4" cy="13" r="2.5" fill="rgba(255,255,255,0.3)" />
        <circle cx="16" cy="13" r="2.5" fill="rgba(255,255,255,0.3)" />
      </g>
      <g transform="translate(80,82) scale(0.45)">
        <rect x="0" y="2" width="20" height="10" rx="4" fill="#ffd700" opacity="0.5" />
        <circle cx="4" cy="13" r="2.5" fill="rgba(255,255,255,0.3)" />
        <circle cx="16" cy="13" r="2.5" fill="rgba(255,255,255,0.3)" />
      </g>
    </svg>`,

  entry: `
    <svg viewBox="0 0 440 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="e-sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#1a7a6d" />
          <stop offset="100%" stop-color="#0d5e52" />
        </linearGradient>
      </defs>
      <rect width="440" height="130" fill="url(#e-sky)" />
      <!-- Ground -->
      <rect x="0" y="90" width="440" height="40" fill="#3a6b5a" opacity="0.5" />
      <!-- Road -->
      <rect x="140" y="86" width="160" height="4" fill="#555" />
      <line x1="160" y1="88" x2="180" y2="88" stroke="#ffd700" stroke-width="1" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="200" y1="88" x2="220" y2="88" stroke="#ffd700" stroke-width="1" stroke-dasharray="8 6" opacity="0.5" />
      <line x1="240" y1="88" x2="260" y2="88" stroke="#ffd700" stroke-width="1" stroke-dasharray="8 6" opacity="0.5" />
      <!-- Gate posts -->
      <rect x="130" y="35" width="6" height="55" rx="1" fill="#666" />
      <rect x="304" y="40" width="6" height="50" rx="1" fill="#666" />
      <!-- Gate top -->
      <rect x="127" y="30" width="186" height="8" rx="2" fill="#555" />
      <!-- Entry sign -->
      <rect x="185" y="15" width="70" height="20" rx="3" fill="#52c41a" />
      <text x="220" y="29" text-anchor="middle" fill="#fff" font-size="10" font-weight="bold">入口 ENTRY</text>
      <!-- Barrier arm -->
      <rect x="133" y="55" width="100" height="4" rx="2" fill="#f5222d">
        <animateTransform attributeName="transform" type="rotate" values="-15 133 57;0 133 57;-15 133 57" dur="4s" repeatCount="indefinite" />
      </rect>
      <circle cx="133" cy="57" r="5" fill="#888" />
      <!-- Car entering -->
      <g transform="translate(240, 62)">
        <rect x="0" y="4" width="30" height="14" rx="5" fill="#409eff" />
        <rect x="6" y="0" width="10" height="8" rx="2" fill="#87ceeb" opacity="0.8" />
        <circle cx="7" cy="20" r="3.5" fill="#333" />
        <circle cx="23" cy="20" r="3.5" fill="#333" />
        <rect x="27" y="8" width="4" height="2" rx="1" fill="#f5222d" opacity="0.8" />
        <rect x="-3" y="8" width="4" height="2" rx="1" fill="#ffd700" opacity="0.8" />
      </g>
      <!-- Sensor indicator -->
      <circle cx="220" cy="75" r="4" fill="#52c41a" opacity="0.6">
        <animate attributeName="opacity" values="0.6;1;0.6" dur="1.5s" repeatCount="indefinite" />
      </circle>
      <text x="220" y="82" text-anchor="middle" fill="#fff" font-size="6" opacity="0.7">地磁</text>
      <!-- Arrow -->
      <polygon points="280,70 290,66 290,74" fill="#fff" opacity="0.4" />
      <!-- Floating decorations -->
      <circle cx="50" cy="25" r="6" fill="none" stroke="rgba(255,255,255,0.12)" stroke-width="1" class="float-slow" />
      <circle cx="400" cy="20" r="5" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1" class="float-fast" />
      <polygon points="410,30 414,24 418,30" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-slow" />
    </svg>`,

  exit: `
    <svg viewBox="0 0 460 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="x-sky" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#f7971e" />
          <stop offset="100%" stop-color="#e6a23c" />
        </linearGradient>
      </defs>
      <rect width="460" height="130" fill="url(#x-sky)" />
      <!-- Road perspective -->
      <polygon points="180,45 280,45 460,130 0,130" fill="#666" opacity="0.4" />
      <polygon points="195,45 265,45 420,130 40,130" fill="#555" opacity="0.5" />
      <!-- Lane markings -->
      <line x1="230" y1="50" x2="230" y2="130" stroke="#ffd700" stroke-width="2" stroke-dasharray="10 8" opacity="0.6" />
      <!-- Horizon buildings -->
      <rect x="20" y="50" width="15" height="45" rx="1" fill="#b8860b" opacity="0.4" />
      <rect x="42" y="42" width="20" height="53" rx="1" fill="#daa520" opacity="0.3" />
      <rect x="70" y="55" width="12" height="40" rx="1" fill="#b8860b" opacity="0.35" />
      <rect x="380" y="48" width="18" height="47" rx="1" fill="#daa520" opacity="0.3" />
      <rect x="405" y="52" width="14" height="43" rx="1" fill="#b8860b" opacity="0.35" />
      <rect x="425" y="45" width="20" height="50" rx="1" fill="#daa520" opacity="0.3" />
      <!-- Car leaving (moving right) -->
      <g transform="translate(300, 65)">
        <rect x="0" y="4" width="32" height="15" rx="5" fill="#409eff" />
        <rect x="6" y="0" width="11" height="8" rx="2" fill="#87ceeb" opacity="0.8" />
        <circle cx="7" cy="21" r="3.5" fill="#333" />
        <circle cx="25" cy="21" r="3.5" fill="#333" />
        <!-- Motion lines -->
        <line x1="-10" y1="8" x2="-20" y2="8" stroke="#fff" stroke-width="1.5" opacity="0.3" />
        <line x1="-8" y1="13" x2="-22" y2="13" stroke="#fff" stroke-width="1" opacity="0.2" />
        <line x1="-10" y1="18" x2="-18" y2="18" stroke="#fff" stroke-width="1.5" opacity="0.3" />
      </g>
      <!-- Smaller car ahead -->
      <g transform="translate(380, 78) scale(0.7)">
        <rect x="0" y="4" width="28" height="13" rx="4" fill="#67c23a" />
        <rect x="5" y="0" width="9" height="7" rx="2" fill="#87ceeb" opacity="0.7" />
        <circle cx="6" cy="19" r="3" fill="#333" />
        <circle cx="22" cy="19" r="3" fill="#333" />
        <line x1="-8" y1="8" x2="-16" y2="8" stroke="#fff" stroke-width="1" opacity="0.2" />
        <line x1="-6" y1="12" x2="-14" y2="12" stroke="#fff" stroke-width="1" opacity="0.15" />
      </g>
      <!-- Gate -->
      <rect x="90" y="55" width="5" height="40" fill="#888" opacity="0.6" />
      <rect x="90" y="54" width="55" height="4" rx="1" fill="#52c41a" opacity="0.7" />
      <!-- Exit sign -->
      <rect x="100" y="38" width="65" height="18" rx="3" fill="#52c41a" />
      <text x="132" y="51" text-anchor="middle" fill="#fff" font-size="9" font-weight="bold">出口 EXIT</text>
      <!-- Coins/billing -->
      <circle cx="240" cy="25" r="10" fill="#ffd700" opacity="0.6" />
      <text x="240" y="29" text-anchor="middle" fill="#b8860b" font-size="11" font-weight="bold">¥</text>
      <circle cx="265" cy="22" r="7" fill="#ffd700" opacity="0.4" />
      <text x="265" y="25" text-anchor="middle" fill="#b8860b" font-size="8" font-weight="bold">¥</text>
      <!-- Floating decorations -->
      <circle cx="30" cy="20" r="5" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="1" class="float-slow" />
      <circle cx="440" cy="15" r="4" fill="none" stroke="rgba(255,255,255,0.12)" stroke-width="1" class="float-fast" />
    </svg>`,

  billing: `
    <svg viewBox="0 0 420 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="b-bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#1a7a9e" />
          <stop offset="100%" stop-color="#4ab8d8" />
        </linearGradient>
      </defs>
      <rect width="420" height="130" fill="url(#b-bg)" />
      <circle cx="50" cy="20" r="18" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1.5" class="float-slow" />
      <circle cx="390" cy="110" r="15" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1" class="float-fast" />
      <!-- Receipt 1 (back) -->
      <g transform="translate(88, 14) rotate(-5)">
        <rect width="85" height="105" rx="4" fill="#fff" opacity="0.2" />
        <line x1="10" y1="18" x2="75" y2="18" stroke="rgba(255,255,255,0.2)" stroke-width="1" />
        <rect x="10" y="25" width="40" height="4" rx="1" fill="rgba(255,255,255,0.15)" />
        <rect x="55" y="25" width="20" height="4" rx="1" fill="rgba(255,255,255,0.15)" />
        <line x1="10" y1="35" x2="75" y2="35" stroke="rgba(255,255,255,0.12)" stroke-width="0.5" stroke-dasharray="3 2" />
        <rect x="10" y="42" width="35" height="4" rx="1" fill="rgba(255,255,255,0.12)" />
        <rect x="55" y="42" width="20" height="4" rx="1" fill="rgba(255,255,255,0.12)" />
        <line x1="10" y1="52" x2="75" y2="52" stroke="rgba(255,255,255,0.1)" stroke-width="0.5" stroke-dasharray="3 2" />
        <rect x="10" y="59" width="30" height="4" rx="1" fill="rgba(255,255,255,0.1)" />
        <rect x="55" y="59" width="20" height="4" rx="1" fill="rgba(255,255,255,0.1)" />
        <line x1="10" y1="72" x2="75" y2="72" stroke="rgba(255,255,255,0.2)" stroke-width="1" />
        <rect x="30" y="78" width="25" height="5" rx="1" fill="rgba(255,255,255,0.2)" />
        <rect x="25" y="90" width="35" height="3" rx="1" fill="rgba(255,255,255,0.1)" />
      </g>
      <!-- Receipt 2 (front) -->
      <g transform="translate(110, 10) rotate(3)">
        <path d="M0 5 Q0 0 5 0 L80 0 Q85 0 85 5 L85 98 L78 92 L71 98 L64 92 L57 98 L50 92 L43 98 L36 92 L29 98 L22 92 L15 98 L8 92 L0 98 Z" fill="#fff" opacity="0.35" />
        <text x="42" y="18" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-size="8" font-weight="bold">停车计费单</text>
        <line x1="8" y1="24" x2="77" y2="24" stroke="rgba(255,255,255,0.25)" stroke-width="0.8" />
        <text x="10" y="36" fill="rgba(255,255,255,0.5)" font-size="6">路段</text>
        <text x="60" y="36" fill="rgba(255,255,255,0.5)" font-size="6">中山北路</text>
        <line x1="8" y1="42" x2="77" y2="42" stroke="rgba(255,255,255,0.15)" stroke-width="0.5" stroke-dasharray="3 2" />
        <text x="10" y="52" fill="rgba(255,255,255,0.5)" font-size="6">车位</text>
        <text x="60" y="52" fill="rgba(255,255,255,0.5)" font-size="6">A-012</text>
        <line x1="8" y1="58" x2="77" y2="58" stroke="rgba(255,255,255,0.15)" stroke-width="0.5" stroke-dasharray="3 2" />
        <text x="10" y="68" fill="rgba(255,255,255,0.5)" font-size="6">时长</text>
        <text x="60" y="68" fill="rgba(255,255,255,0.5)" font-size="6">2小时30分</text>
        <line x1="8" y1="74" x2="77" y2="74" stroke="rgba(255,255,255,0.25)" stroke-width="0.8" />
        <text x="10" y="85" fill="rgba(255,255,255,0.7)" font-size="7" font-weight="bold">合计</text>
        <text x="58" y="85" fill="#ffd700" font-size="9" font-weight="bold">¥18.50</text>
      </g>
      <!-- Large coin -->
      <g transform="translate(280, 40)">
        <circle cx="0" cy="0" r="22" fill="#ffd700" opacity="0.5" />
        <circle cx="0" cy="0" r="18" fill="#ffd700" opacity="0.3" stroke="#daa520" stroke-width="1.5" />
        <text x="0" y="7" text-anchor="middle" fill="#b8860b" font-size="18" font-weight="bold">¥</text>
      </g>
      <!-- Small coins -->
      <g transform="translate(330, 70)">
        <circle cx="0" cy="0" r="14" fill="#ffd700" opacity="0.4" />
        <circle cx="0" cy="0" r="11" fill="#ffd700" opacity="0.2" stroke="#daa520" stroke-width="1" />
        <text x="0" y="4" text-anchor="middle" fill="#b8860b" font-size="12" font-weight="bold">¥</text>
      </g>
      <g transform="translate(310, 100)">
        <circle cx="0" cy="0" r="10" fill="#ffd700" opacity="0.3" />
        <text x="0" y="3.5" text-anchor="middle" fill="#b8860b" font-size="9" font-weight="bold">¥</text>
      </g>
      <!-- Check mark -->
      <g transform="translate(360, 25)">
        <circle cx="0" cy="0" r="12" fill="#52c41a" opacity="0.6" />
        <polyline points="-5,0 -1,5 6,-4" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
      </g>
      <!-- Floating decorations -->
      <circle cx="20" cy="100" r="5" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1" class="float-fast" />
      <circle cx="400" cy="20" r="6" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-slow" />
    </svg>`,

  arrears: `
    <svg viewBox="0 0 420 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="a-bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#8b1a1a" />
          <stop offset="100%" stop-color="#c44040" />
        </linearGradient>
      </defs>
      <rect width="420" height="130" fill="url(#a-bg)" />
      <circle cx="40" cy="100" r="20" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1.5" class="float-slow" />
      <circle cx="390" cy="25" r="15" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-fast" />
      <circle cx="350" cy="110" r="10" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="1" class="float-slow" />
      <!-- Large warning triangle -->
      <g transform="translate(140, 8)">
        <polygon points="60,5 115,95 5,95" fill="#ffd700" opacity="0.25" />
        <polygon points="60,12 108,90 12,90" fill="none" stroke="#ffd700" stroke-width="2.5" opacity="0.6" />
        <text x="60" y="72" text-anchor="middle" fill="#fff" font-size="40" font-weight="bold">!</text>
      </g>
      <!-- Exclamation mark -->
      <g transform="translate(300, 30)">
        <circle cx="0" cy="0" r="25" fill="#f5222d" opacity="0.3" />
        <circle cx="0" cy="0" r="20" fill="#f5222d" opacity="0.2" stroke="#ff7875" stroke-width="2" />
        <text x="0" y="9" text-anchor="middle" fill="#fff" font-size="26" font-weight="bold">!</text>
      </g>
      <!-- Warning signs small -->
      <g transform="translate(60, 40)">
        <polygon points="12,2 22,18 2,18" fill="#ffd700" opacity="0.3" />
        <polygon points="12,5 19,16 5,16" fill="none" stroke="#ffd700" stroke-width="1" opacity="0.5" />
        <text x="12" y="15" text-anchor="middle" fill="#fff" font-size="7" font-weight="bold">!</text>
      </g>
      <g transform="translate(370, 65)">
        <polygon points="10,2 18,15 2,15" fill="#ffd700" opacity="0.25" />
        <polygon points="10,4 16,14 4,14" fill="none" stroke="#ffd700" stroke-width="1" opacity="0.4" />
        <text x="10" y="13" text-anchor="middle" fill="#fff" font-size="6" font-weight="bold">!</text>
      </g>
      <!-- Money crossed out -->
      <g transform="translate(280, 80)">
        <circle cx="0" cy="0" r="14" fill="#ffd700" opacity="0.25" />
        <text x="0" y="5" text-anchor="middle" fill="#b8860b" font-size="14" font-weight="bold">¥</text>
        <line x1="-10" y1="10" x2="10" y2="-10" stroke="#f5222d" stroke-width="2.5" opacity="0.7" stroke-linecap="round" />
      </g>
      <!-- Clock (overdue) -->
      <g transform="translate(55, 75)">
        <circle cx="0" cy="0" r="12" fill="none" stroke="rgba(255,255,255,0.2)" stroke-width="1.5" />
        <line x1="0" y1="0" x2="0" y2="-7" stroke="rgba(255,255,255,0.4)" stroke-width="1.5" stroke-linecap="round" />
        <line x1="0" y1="0" x2="5" y2="3" stroke="rgba(255,255,255,0.4)" stroke-width="1.5" stroke-linecap="round" />
      </g>
      <!-- Document -->
      <g transform="translate(355, 90)">
        <rect x="0" y="0" width="25" height="32" rx="2" fill="#fff" opacity="0.12" />
        <rect x="4" y="5" width="12" height="2" rx="0.5" fill="rgba(255,255,255,0.15)" />
        <rect x="4" y="10" width="17" height="2" rx="0.5" fill="rgba(255,255,255,0.1)" />
        <rect x="4" y="15" width="14" height="2" rx="0.5" fill="rgba(255,255,255,0.1)" />
        <line x1="4" y1="22" x2="21" y2="22" stroke="rgba(255,255,255,0.15)" stroke-width="0.8" />
        <rect x="6" y="24" width="8" height="3" rx="0.5" fill="#f5222d" opacity="0.4" />
      </g>
    </svg>`,

  statistics: `
    <svg viewBox="0 0 520 130" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="st-bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#2a1a5e" />
          <stop offset="100%" stop-color="#6a3fa0" />
        </linearGradient>
      </defs>
      <rect width="520" height="130" fill="url(#st-bg)" />
      <circle cx="40" cy="110" r="18" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1.5" class="float-slow" />
      <circle cx="490" cy="20" r="12" fill="none" stroke="rgba(255,255,255,0.08)" stroke-width="1" class="float-fast" />
      <polygon points="470,100 476,90 482,100" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1" class="float-slow" />
      <!-- Bar chart -->
      <g transform="translate(30, 15)">
        <!-- Axes -->
        <line x1="25" y1="5" x2="25" y2="95" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <line x1="25" y1="95" x2="195" y2="95" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <!-- Grid lines -->
        <line x1="25" y1="25" x2="195" y2="25" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <line x1="25" y1="45" x2="195" y2="45" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <line x1="25" y1="65" x2="195" y2="65" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <line x1="25" y1="85" x2="195" y2="85" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <!-- Bar groups -->
        <rect x="40" y="30" width="10" height="65" rx="2" fill="#409eff" opacity="0.8" />
        <rect x="52" y="50" width="10" height="45" rx="2" fill="#ffd700" opacity="0.7" />
        <rect x="75" y="20" width="10" height="75" rx="2" fill="#409eff" opacity="0.8" />
        <rect x="87" y="35" width="10" height="60" rx="2" fill="#ffd700" opacity="0.7" />
        <rect x="110" y="45" width="10" height="50" rx="2" fill="#409eff" opacity="0.8" />
        <rect x="122" y="60" width="10" height="35" rx="2" fill="#ffd700" opacity="0.7" />
        <rect x="145" y="25" width="10" height="70" rx="2" fill="#409eff" opacity="0.8" />
        <rect x="157" y="40" width="10" height="55" rx="2" fill="#ffd700" opacity="0.7" />
        <!-- Labels -->
        <text x="51" y="105" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="6">路段A</text>
        <text x="86" y="105" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="6">路段B</text>
        <text x="121" y="105" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="6">路段C</text>
        <text x="156" y="105" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="6">路段D</text>
        <!-- Legend -->
        <rect x="105" y="3" width="6" height="6" rx="1" fill="#409eff" opacity="0.8" />
        <text x="114" y="9" fill="rgba(255,255,255,0.5)" font-size="6">周转率</text>
        <rect x="140" y="3" width="6" height="6" rx="1" fill="#ffd700" opacity="0.7" />
        <text x="149" y="9" fill="rgba(255,255,255,0.5)" font-size="6">营收</text>
      </g>
      <!-- Line chart -->
      <g transform="translate(240, 15)">
        <!-- Axes -->
        <line x1="25" y1="5" x2="25" y2="95" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <line x1="25" y1="95" x2="245" y2="95" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" />
        <!-- Grid lines -->
        <line x1="25" y1="25" x2="245" y2="25" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <line x1="25" y1="45" x2="245" y2="45" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <line x1="25" y1="65" x2="245" y2="65" stroke="rgba(255,255,255,0.06)" stroke-width="0.5" />
        <!-- Area fill -->
        <polygon points="40,70 80,50 120,55 160,30 200,38 240,20 240,95 40,95" fill="url(#st-area)" opacity="0.2" />
        <line x1="40" y1="70" x2="80" y2="50" stroke="#67c23a" stroke-width="2" opacity="0.7" />
        <line x1="80" y1="50" x2="120" y2="55" stroke="#67c23a" stroke-width="2" opacity="0.7" />
        <line x1="120" y1="55" x2="160" y2="30" stroke="#67c23a" stroke-width="2" opacity="0.7" />
        <line x1="160" y1="30" x2="200" y2="38" stroke="#67c23a" stroke-width="2" opacity="0.7" />
        <line x1="200" y1="38" x2="240" y2="20" stroke="#67c23a" stroke-width="2" opacity="0.7" />
        <!-- Data points -->
        <circle cx="40" cy="70" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <circle cx="80" cy="50" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <circle cx="120" cy="55" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <circle cx="160" cy="30" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <circle cx="200" cy="38" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <circle cx="240" cy="20" r="4" fill="#67c23a" stroke="#fff" stroke-width="1.5" />
        <!-- Second line -->
        <line x1="40" y1="85" x2="80" y2="75" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="5 3" opacity="0.6" />
        <line x1="80" y1="75" x2="120" y2="80" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="5 3" opacity="0.6" />
        <line x1="120" y1="80" x2="160" y2="60" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="5 3" opacity="0.6" />
        <line x1="160" y1="60" x2="200" y2="65" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="5 3" opacity="0.6" />
        <line x1="200" y1="65" x2="240" y2="50" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="5 3" opacity="0.6" />
        <!-- Legend -->
        <circle cx="160" cy="8" r="3" fill="#67c23a" opacity="0.7" />
        <text x="166" y="11" fill="rgba(255,255,255,0.5)" font-size="6">营收趋势</text>
        <line x1="200" y1="8" x2="210" y2="8" stroke="#f5222d" stroke-width="1.5" stroke-dasharray="3 2" opacity="0.6" />
        <text x="213" y="11" fill="rgba(255,255,255,0.5)" font-size="6">欠费率</text>
      </g>
      <defs>
        <linearGradient id="st-area" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#67c23a" />
          <stop offset="100%" stop-color="#67c23a" stop-opacity="0" />
        </linearGradient>
      </defs>
    </svg>`
}
</script>

<style>
@keyframes banner-float-slow {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}
@keyframes banner-float-fast {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}
.float-slow { animation: banner-float-slow 4s ease-in-out infinite; }
.float-fast { animation: banner-float-fast 3s ease-in-out infinite; }

.page-banner {
  position: relative;
  border-radius: 12px;
  padding: 28px 32px;
  margin-bottom: 24px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 180px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  transition: box-shadow 0.3s ease;
}
.page-banner:hover {
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.2);
}
.page-banner[data-type="dashboard"] { min-height: 220px; }

.page-banner__content {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  gap: 20px;
}

.page-banner__icon {
  width: 68px;
  height: 68px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  flex-shrink: 0;
  transition: transform 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.1);
}
.page-banner:hover .page-banner__icon {
  transform: scale(1.08);
}

.page-banner__text {
  color: #fff;
}

.page-banner__title {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 6px;
  letter-spacing: 0.5px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.page-banner__subtitle {
  font-size: 14px;
  opacity: 0.85;
  margin: 0;
  letter-spacing: 0.3px;
  max-width: 320px;
  line-height: 1.5;
}

.page-banner__illustration {
  position: relative;
  z-index: 1;
  flex-shrink: 0;
  opacity: 0.9;
  transition: opacity 0.3s ease;
}
.page-banner:hover .page-banner__illustration {
  opacity: 1;
}
.page-banner__illustration svg {
  display: block;
  height: 130px;
  width: auto;
  border-radius: 8px;
  filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.15));
}
.page-banner[data-type="dashboard"] .page-banner__illustration svg {
  height: 150px;
}

@media (max-width: 900px) {
  .page-banner__illustration { display: none; }
}
</style>
