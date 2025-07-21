<!-- vue-frontend/src/components/chart-builder/ChartPreview.vue -->
<template>
  <div>
    <a-card 
      title="5단계: 미리보기 및 저장" 
      style="margin-bottom: 24px"
    >
      <!-- 미리보기 액션 버튼 -->
      <template #extra>
        <a-space>
          <a-button 
            @click="handlePreview"
            :loading="previewLoading"
            size="large"
          >
            <template #icon>
              <EyeOutlined />
            </template>
            미리보기 생성
          </a-button>
          
          <a-button 
            v-if="chartData"
            @click="refreshPreview"
            size="large"
          >
            <template #icon>
              <ReloadOutlined />
            </template>
            새로고침
          </a-button>
        </a-space>
      </template>

      <!-- 미리보기 영역 -->
      <div style="min-height: 300px">
        <div v-if="previewLoading" style="text-align: center; padding: 80px 0">
          <a-spin size="large" />
          <p style="margin-top: 16px; color: #666">
            차트 미리보기를 생성하고 있습니다...
          </p>
        </div>

        <div v-else-if="chartData" style="padding: 20px">
          <!-- 차트 렌더러 컴포넌트 사용 -->
          <div style="margin-bottom: 24px">
            <a-tabs v-model:activeKey="activeTab" type="card">
              <a-tab-pane key="vue" tab="Vue.js 렌더링">
                <ChartRenderer
                  :chartConfig="chartConfig"
                  :chartData="chartData"
                  :width="800"
                  :height="400"
                />
              </a-tab-pane>
              
              <a-tab-pane key="info" tab="데이터 정보">
                <div style="background: #f8f9fa; padding: 24px; border-radius: 8px">
                  <a-descriptions title="차트 상세 정보" :column="2" size="small" bordered>
                    <a-descriptions-item label="차트 이름">
                      {{ chartConfig.slice_name || '이름 없음' }}
                    </a-descriptions-item>
                    <a-descriptions-item label="차트 타입">
                      {{ getChartTypeName() }}
                    </a-descriptions-item>
                    <a-descriptions-item label="데이터 행 수">
                      {{ chartData.query?.rowcount || 0 }}행
                    </a-descriptions-item>
                    <a-descriptions-item label="실행 시간">
                      {{ chartData.query?.duration || 0 }}ms
                    </a-descriptions-item>
                    <a-descriptions-item label="데이터 컬럼">
                      {{ (chartData.query?.columns || []).join(', ') || 'None' }}
                    </a-descriptions-item>
                    <a-descriptions-item label="메트릭">
                      {{ (chartData.query?.metrics || []).join(', ') }}
                    </a-descriptions-item>
                    <a-descriptions-item label="캐시 상태">
                      {{ chartData.is_cached ? '캐시됨' : '실시간' }}
                    </a-descriptions-item>
                    <a-descriptions-item label="생성 시간">
                      {{ new Date().toLocaleString() }}
                    </a-descriptions-item>
                  </a-descriptions>

                  <!-- 실제 데이터 미리보기 -->
                  <div v-if="chartData.data && chartData.data.length > 0" style="margin-top: 24px">
                    <h4>📊 데이터 미리보기 (상위 5개 레코드)</h4>
                    <a-table
                      :dataSource="previewData"
                      :columns="previewColumns"
                      :pagination="false"
                      size="small"
                      bordered
                    />
                  </div>
                </div>
              </a-tab-pane>
              
              <a-tab-pane key="raw" tab="Raw 데이터">
                <div style="background: #f5f5f5; padding: 16px; border-radius: 6px; max-height: 400px; overflow: auto">
                  <pre style="margin: 0; font-size: 12px; line-height: 1.4">{{ JSON.stringify(chartData, null, 2) }}</pre>
                </div>
              </a-tab-pane>
            </a-tabs>
          </div>

          <!-- 차트 기본 정보 요약 -->
          <div style="background: #e6f7ff; padding: 16px; border-radius: 8px; border: 1px solid #91d5ff">
            <div style="display: flex; align-items: center; margin-bottom: 12px">
              <component 
                :is="chartIcons[chartConfig.viz_type]" 
                style="font-size: 24px; color: #1890ff; margin-right: 12px" 
              />
              <h3 style="margin: 0; color: #1890ff">
                {{ getChartTypeName() }} 미리보기 완료!
              </h3>
            </div>
            
            <a-row :gutter="16">
              <a-col :span="6">
                <a-statistic title="데이터 행 수" :value="chartData.query?.rowcount || 0" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="컬럼 수" :value="(chartData.data && chartData.data.length > 0) ? Object.keys(chartData.data[0]).length : 0" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="실행 시간" :value="chartData.query?.duration || 0" suffix="ms" />
              </a-col>
              <a-col :span="6">
                <a-statistic title="캐시" :value="chartData.is_cached ? '적용' : '미적용'" />
              </a-col>
            </a-row>
            
            <div style="margin-top: 16px; padding-top: 12px; border-top: 1px solid #d9d9d9">
              <p style="margin: 0; font-size: 14px; color: #666">
                ✨ Vue.js에서 실시간으로 렌더링된 차트입니다. 
                차트를 저장하면 Apache Superset에서도 동일하게 확인할 수 있습니다.
              </p>
            </div>
          </div>
        </div>

        <div v-else style="text-align: center; padding: 80px 0">
          <a-empty description="미리보기를 생성하려면 '미리보기 생성' 버튼을 클릭하세요">
            <template #image>
              <BarChartOutlined style="font-size: 64px; color: #d9d9d9" />
            </template>
          </a-empty>
        </div>
      </div>
    </a-card>
  </div>
</template>

<script>
import { defineComponent, ref, computed } from 'vue'
import {
  EyeOutlined,
  ReloadOutlined,
  BarChartOutlined,
  LineChartOutlined,
  PieChartOutlined,
  TableOutlined,
  AreaChartOutlined,
  DotChartOutlined
} from '@ant-design/icons-vue'
import ChartRenderer from '../ChartRenderer.vue'

export default defineComponent({
  name: 'ChartPreview',
  components: {
    EyeOutlined,
    ReloadOutlined,
    BarChartOutlined,
    LineChartOutlined,
    PieChartOutlined,
    TableOutlined,
    AreaChartOutlined,
    DotChartOutlined,
    ChartRenderer
  },
  props: {
    chartConfig: {
      type: Object,
      required: true
    },
    chartData: {
      type: Object,
      default: null
    },
    previewLoading: {
      type: Boolean,
      default: false
    },
    selectedDataset: {
      type: Object,
      default: null
    }
  },
  emits: ['preview', 'save', 'back'],
  setup (props, { emit }) {
    const activeTab = ref('vue')

    const chartTypeNames = {
      table: '테이블',
      dist_bar: '막대 차트',
      line: '선 차트',
      pie: '파이 차트',
      area: '영역 차트',
      scatter: '산점도'
    }

    const chartIcons = {
      table: TableOutlined,
      dist_bar: BarChartOutlined,
      line: LineChartOutlined,
      pie: PieChartOutlined,
      area: AreaChartOutlined,
      scatter: DotChartOutlined
    }

    const getChartTypeName = () => {
      return chartTypeNames[props.chartConfig.viz_type] || props.chartConfig.viz_type
    }

    const handlePreview = () => {
      emit('preview')
    }

    const refreshPreview = () => {
      emit('preview')
    }

    // 데이터 미리보기용 처리
    const previewData = computed(() => {
      if (!props.chartData?.data || props.chartData.data.length === 0) {
        return []
      }
      
      return props.chartData.data.slice(0, 5).map((row, index) => ({
        key: index,
        ...row
      }))
    })

    const previewColumns = computed(() => {
      if (!props.chartData?.data || props.chartData.data.length === 0) {
        return []
      }
      
      const firstRow = props.chartData.data[0]
      return Object.keys(firstRow).map(key => ({
        title: key.charAt(0).toUpperCase() + key.slice(1),
        dataIndex: key,
        key: key,
        width: 120,
        ellipsis: true
      }))
    })

    return {
      activeTab,
      chartIcons,
      getChartTypeName,
      handlePreview,
      refreshPreview,
      previewData,
      previewColumns
    }
  }
})
</script>

<style scoped>
.ant-descriptions-item-label {
  font-weight: 500;
}

.ant-card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.ant-tabs-card .ant-tabs-tab {
  border-radius: 6px 6px 0 0;
}

.ant-statistic-title {
  font-size: 12px;
  color: #666;
}

.ant-statistic-content {
  font-size: 16px;
  font-weight: 600;
}

pre {
  font-family: 'Courier New', Consolas, monospace;
  color: #333;
}

/* 탭 스타일 개선 */
.ant-tabs-card > .ant-tabs-nav .ant-tabs-tab {
  background: #fafafa;
  border: 1px solid #d9d9d9;
  margin-right: 4px;
}

.ant-tabs-card > .ant-tabs-nav .ant-tabs-tab-active {
  background: white;
  border-bottom-color: white;
}

/* 반응형 스타일 */
@media (max-width: 768px) {
  .ant-col {
    margin-bottom: 16px;
  }
  
  .ant-descriptions {
    font-size: 12px;
  }
  
  .chart-renderer {
    overflow-x: auto;
  }
}
</style>