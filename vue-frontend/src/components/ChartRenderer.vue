<!-- vue-frontend/src/components/ChartRenderer.vue -->
<template>
  <div class="chart-renderer">
    <!-- 로딩 상태 -->
    <div v-if="loading" class="chart-loading">
      <a-spin size="large" />
      <p>차트를 렌더링하고 있습니다...</p>
    </div>

    <!-- 에러 상태 -->
    <div v-else-if="error" class="chart-error">
      <a-alert
        :message="error.title || '차트 렌더링 오류'"
        :description="error.message"
        type="error"
        show-icon
      />
    </div>

    <!-- 차트 렌더링 영역 -->
    <div v-else class="chart-container">
      <!-- 테이블 차트 -->
      <div v-if="chartConfig.viz_type === 'table'" class="table-chart">
        <a-table
          :dataSource="processedData"
          :columns="tableColumns"
          :pagination="{ pageSize: 10, showSizeChanger: true }"
          size="small"
          bordered
        />
      </div>

      <!-- 막대 차트 -->
      <div v-else-if="chartConfig.viz_type === 'dist_bar'" class="bar-chart">
        <canvas ref="barCanvas" :width="chartWidth" :height="chartHeight"></canvas>
      </div>

      <!-- 선 차트 -->
      <div v-else-if="chartConfig.viz_type === 'line'" class="line-chart">
        <canvas ref="lineCanvas" :width="chartWidth" :height="chartHeight"></canvas>
      </div>

      <!-- 파이 차트 -->
      <div v-else-if="chartConfig.viz_type === 'pie'" class="pie-chart">
        <canvas ref="pieCanvas" :width="chartWidth" :height="chartHeight"></canvas>
      </div>

      <!-- 영역 차트 -->
      <div v-else-if="chartConfig.viz_type === 'area'" class="area-chart">
        <canvas ref="areaCanvas" :width="chartWidth" :height="chartHeight"></canvas>
      </div>

      <!-- 기본 차트 (지원되지 않는 타입) -->
      <div v-else class="unsupported-chart">
        <a-result
          status="info"
          :title="`${chartConfig.viz_type} 차트`"
          sub-title="이 차트 타입은 아직 Vue.js 렌더링을 지원하지 않습니다."
        >
          <template #extra>
            <a-button type="primary" @click="openInSuperset">
              Superset에서 열기
            </a-button>
          </template>
        </a-result>
      </div>

      <!-- 차트 정보 -->
      <div class="chart-info" v-if="chartData">
        <a-descriptions size="small" :column="4" bordered>
          <a-descriptions-item label="데이터 행 수">
            {{ chartData.query?.rowcount || 0 }}
          </a-descriptions-item>
          <a-descriptions-item label="실행 시간">
            {{ chartData.query?.duration || 0 }}ms
          </a-descriptions-item>
          <a-descriptions-item label="캐시 상태">
            {{ chartData.is_cached ? '캐시됨' : '실시간' }}
          </a-descriptions-item>
          <a-descriptions-item label="마지막 업데이트">
            {{ new Date().toLocaleString() }}
          </a-descriptions-item>
        </a-descriptions>
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, computed, watch, onMounted, nextTick } from 'vue'

export default defineComponent({
  name: 'ChartRenderer',
  props: {
    chartConfig: {
      type: Object,
      required: true
    },
    chartData: {
      type: Object,
      default: null
    },
    width: {
      type: Number,
      default: 800
    },
    height: {
      type: Number,
      default: 400
    }
  },
  setup(props) {
    const loading = ref(false)
    const error = ref(null)
    
    // Canvas 참조
    const barCanvas = ref(null)
    const lineCanvas = ref(null)
    const pieCanvas = ref(null)
    const areaCanvas = ref(null)

    const chartWidth = computed(() => props.width)
    const chartHeight = computed(() => props.height)

    // 테이블용 데이터 처리
    const processedData = computed(() => {
      if (!props.chartData?.data) return []
      
      return props.chartData.data.map((row, index) => ({
        key: index,
        ...row
      }))
    })

    // 테이블 컬럼 정의
    const tableColumns = computed(() => {
      if (!props.chartData?.data || props.chartData.data.length === 0) {
        return []
      }
      
      const firstRow = props.chartData.data[0]
      return Object.keys(firstRow).map(key => ({
        title: key.charAt(0).toUpperCase() + key.slice(1),
        dataIndex: key,
        key: key,
        sorter: (a, b) => {
          if (typeof a[key] === 'number' && typeof b[key] === 'number') {
            return a[key] - b[key]
          }
          return String(a[key]).localeCompare(String(b[key]))
        }
      }))
    })

    // 차트 색상 팔레트
    const colorPalette = [
      '#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd',
      '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf'
    ]

    // 막대 차트 렌더링
    const renderBarChart = () => {
      if (!barCanvas.value || !props.chartData?.data) return

      const canvas = barCanvas.value
      const ctx = canvas.getContext('2d')
      const data = props.chartData.data
      
      // 캔버스 초기화
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      
      // 차트 영역 설정
      const padding = 60
      const chartArea = {
        x: padding,
        y: padding,
        width: canvas.width - padding * 2,
        height: canvas.height - padding * 2
      }
      
      // 데이터 값 추출
      const values = data.map(d => d.value || d.count || 0)
      const labels = data.map(d => d.name || d.label || 'Unknown')
      const maxValue = Math.max(...values, 1)
      
      // 막대 그리기
      const barWidth = chartArea.width / data.length * 0.8
      const barSpacing = chartArea.width / data.length * 0.2
      
      data.forEach((item, index) => {
        const value = values[index]
        const barHeight = (value / maxValue) * chartArea.height
        const x = chartArea.x + index * (barWidth + barSpacing) + barSpacing / 2
        const y = chartArea.y + chartArea.height - barHeight
        
        // 막대 그리기
        ctx.fillStyle = colorPalette[index % colorPalette.length]
        ctx.fillRect(x, y, barWidth, barHeight)
        
        // 값 표시
        ctx.fillStyle = '#333'
        ctx.font = '12px Arial'
        ctx.textAlign = 'center'
        ctx.fillText(value.toString(), x + barWidth / 2, y - 5)
        
        // 라벨 표시
        ctx.save()
        ctx.translate(x + barWidth / 2, chartArea.y + chartArea.height + 20)
        ctx.rotate(-Math.PI / 6)
        ctx.textAlign = 'right'
        ctx.fillText(labels[index], 0, 0)
        ctx.restore()
      })
      
      // 축 그리기
      ctx.strokeStyle = '#333'
      ctx.lineWidth = 1
      ctx.beginPath()
      // X축
      ctx.moveTo(chartArea.x, chartArea.y + chartArea.height)
      ctx.lineTo(chartArea.x + chartArea.width, chartArea.y + chartArea.height)
      // Y축
      ctx.moveTo(chartArea.x, chartArea.y)
      ctx.lineTo(chartArea.x, chartArea.y + chartArea.height)
      ctx.stroke()
    }

    // 파이 차트 렌더링
    const renderPieChart = () => {
      if (!pieCanvas.value || !props.chartData?.data) return

      const canvas = pieCanvas.value
      const ctx = canvas.getContext('2d')
      const data = props.chartData.data
      
      // 캔버스 초기화
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      
      // 원 중심과 반지름
      const centerX = canvas.width / 2
      const centerY = canvas.height / 2
      const radius = Math.min(centerX, centerY) - 60
      
      // 데이터 값 추출 및 총합 계산
      const values = data.map(d => d.value || d.count || 0)
      const labels = data.map(d => d.name || d.label || 'Unknown')
      const total = values.reduce((sum, val) => sum + val, 0)
      
      // 파이 조각 그리기
      let currentAngle = -Math.PI / 2 // 12시 방향부터 시작
      
      data.forEach((item, index) => {
        const value = values[index]
        const sliceAngle = (value / total) * 2 * Math.PI
        
        // 파이 조각 그리기
        ctx.fillStyle = colorPalette[index % colorPalette.length]
        ctx.beginPath()
        ctx.moveTo(centerX, centerY)
        ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle)
        ctx.closePath()
        ctx.fill()
        
        // 경계선
        ctx.strokeStyle = '#fff'
        ctx.lineWidth = 2
        ctx.stroke()
        
        // 라벨과 퍼센트 표시
        const labelAngle = currentAngle + sliceAngle / 2
        const labelX = centerX + Math.cos(labelAngle) * (radius + 30)
        const labelY = centerY + Math.sin(labelAngle) * (radius + 30)
        
        ctx.fillStyle = '#333'
        ctx.font = '12px Arial'
        ctx.textAlign = 'center'
        const percentage = ((value / total) * 100).toFixed(1)
        ctx.fillText(`${labels[index]}`, labelX, labelY - 8)
        ctx.fillText(`${percentage}%`, labelX, labelY + 8)
        
        currentAngle += sliceAngle
      })
    }

    // 선 차트 렌더링
    const renderLineChart = () => {
      if (!lineCanvas.value || !props.chartData?.data) return

      const canvas = lineCanvas.value
      const ctx = canvas.getContext('2d')
      const data = props.chartData.data
      
      // 캔버스 초기화
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      
      // 차트 영역 설정
      const padding = 60
      const chartArea = {
        x: padding,
        y: padding,
        width: canvas.width - padding * 2,
        height: canvas.height - padding * 2
      }
      
      // 데이터 값 추출
      const values = data.map(d => d.value || d.count || 0)
      const labels = data.map(d => d.name || d.label || 'Unknown')
      const maxValue = Math.max(...values, 1)
      const minValue = Math.min(...values, 0)
      
      // 축 그리기
      ctx.strokeStyle = '#333'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(chartArea.x, chartArea.y + chartArea.height)
      ctx.lineTo(chartArea.x + chartArea.width, chartArea.y + chartArea.height)
      ctx.moveTo(chartArea.x, chartArea.y)
      ctx.lineTo(chartArea.x, chartArea.y + chartArea.height)
      ctx.stroke()
      
      // 선 그리기
      ctx.strokeStyle = colorPalette[0]
      ctx.lineWidth = 3
      ctx.beginPath()
      
      data.forEach((item, index) => {
        const value = values[index]
        const x = chartArea.x + (index / (data.length - 1)) * chartArea.width
        const y = chartArea.y + chartArea.height - ((value - minValue) / (maxValue - minValue)) * chartArea.height
        
        if (index === 0) {
          ctx.moveTo(x, y)
        } else {
          ctx.lineTo(x, y)
        }
        
        // 데이터 포인트
        ctx.fillStyle = colorPalette[0]
        ctx.beginPath()
        ctx.arc(x, y, 4, 0, 2 * Math.PI)
        ctx.fill()
      })
      
      ctx.stroke()
    }

    // 차트 렌더링 함수
    const renderChart = async () => {
      if (!props.chartData) return
      
      await nextTick()
      
      try {
        loading.value = true
        error.value = null
        
        switch (props.chartConfig.viz_type) {
          case 'dist_bar':
            renderBarChart()
            break
          case 'pie':
            renderPieChart()
            break
          case 'line':
            renderLineChart()
            break
          case 'area':
            renderLineChart() // 영역 차트는 선 차트와 비슷하게 처리
            break
          default:
            console.log('지원되지 않는 차트 타입:', props.chartConfig.viz_type)
        }
        
      } catch (err) {
        error.value = {
          title: '차트 렌더링 실패',
          message: err.message
        }
      } finally {
        loading.value = false
      }
    }

    // Superset에서 열기
    const openInSuperset = () => {
      // 실제 구현에서는 Superset URL을 구성해서 새 창으로 열기
      window.open('http://localhost:8088', '_blank')
    }

    // 차트 데이터 변경 감지
    watch(() => props.chartData, renderChart, { deep: true })
    watch(() => props.chartConfig.viz_type, renderChart)

    onMounted(() => {
      if (props.chartData) {
        renderChart()
      }
    })

    return {
      loading,
      error,
      barCanvas,
      lineCanvas,
      pieCanvas,
      areaCanvas,
      chartWidth,
      chartHeight,
      processedData,
      tableColumns,
      openInSuperset
    }
  }
})
</script>

<style scoped>
.chart-renderer {
  width: 100%;
  height: 100%;
}

.chart-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 300px;
  color: #666;
}

.chart-error {
  margin: 20px 0;
}

.chart-container {
  width: 100%;
}

.table-chart {
  overflow: auto;
}

.bar-chart, .line-chart, .pie-chart, .area-chart {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 20px;
}

.unsupported-chart {
  margin: 40px 0;
}

.chart-info {
  margin-top: 20px;
  padding: 16px;
  background: #fafafa;
  border-radius: 6px;
}

canvas {
  border: 1px solid #f0f0f0;
  border-radius: 6px;
  background: white;
}
</style>