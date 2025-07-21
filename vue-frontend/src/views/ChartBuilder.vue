<!-- vue-frontend/src/views/ChartBuilder.vue -->
<template>
  <div>
    <div style="margin-bottom: 24px">
      <div style="display: flex; justify-content: space-between; align-items: center">
        <div>
          <h1 style="margin: 0; font-size: 24px; font-weight: 600">
            차트 빌더
          </h1>
          <p style="margin: 8px 0 0 0; color: #666">
            Apache Superset을 사용하여 차트를 생성하고 관리합니다.
          </p>
        </div>
        <a-button @click="resetForm">
          <template #icon>
            <ReloadOutlined />
          </template>
          새로 시작
        </a-button>
      </div>
    </div>

    <a-alert
      v-if="!canCreateChart"
      message="접근 권한 없음"
      description="차트 생성 권한이 없습니다."
      type="warning"
      show-icon
    />

    <template v-else>
      <!-- 단계 표시기 -->
      <a-steps :current="currentStep" style="margin-bottom: 24px">
        <a-step
          v-for="(step, index) in steps"
          :key="index"
          :title="step.title"
          :description="step.description"
          @click="setCurrentStep(index)"
          style="cursor: pointer"
        />
      </a-steps>

      <a-alert
        v-if="datasets.length === 0"
        message="데이터셋이 필요합니다"
        description="차트를 생성하려면 먼저 데이터 소스에서 데이터셋을 생성해야 합니다."
        type="info"
        show-icon
        :action="() => h('a-button', { type: 'primary', onClick: () => $router.push('/datasources') }, '데이터 소스 관리로 이동')"
      />

      <!-- 🔥 수정된 단계별 컴포넌트 렌더링 -->
      <div v-else>
        <!-- 1단계: 데이터셋 선택 -->
        <div v-show="currentStep === 0">
          <DatasetSelection
            :datasets="datasets"
            :selectedDataset="selectedDataset"
            :loading="loading"
            @change="handleDatasetChange"
          />
        </div>

        <!-- 2단계: 차트 타입 선택 -->
        <div v-show="currentStep === 1 && selectedDataset">
          <ChartTypeSelection
            :selectedType="chartConfig.viz_type"
            @select="handleChartTypeChange"
            @next="goToNextStep"
            @back="goToPrevStep"
          />
        </div>

        <!-- 🔥 3단계: 차트 설정 (조건 완화) -->
        <div v-show="currentStep === 2 && selectedDataset && chartConfig.viz_type">
          <a-spin :spinning="columnsLoading">
            <ChartConfiguration
              :chartConfig="chartConfig"
              :datasetColumns="datasetColumns"
              :selectedDataset="selectedDataset"
              @update="updateChartConfig"
              @next="goToNextStep"
              @back="goToPrevStep"
            />
          </a-spin>
        </div>

        <!-- 4단계: 차트 정보 -->
        <div v-show="currentStep === 3 && selectedDataset && chartConfig.viz_type">
          <ChartDetails
            :chartConfig="chartConfig"
            :selectedDataset="selectedDataset"
            @update="updateChartConfig"
            @next="goToNextStep"
            @back="goToPrevStep"
          />
        </div>

        <!-- 5단계: 미리보기 및 저장 -->
        <div v-show="currentStep === 4 && selectedDataset && chartConfig.viz_type">
          <ChartPreview
            :chartConfig="chartConfig"
            :chartData="chartData"
            :previewLoading="previewLoading"
            @preview="previewChart"
            @save="saveChart"
            @back="goToPrevStep"
          />
        </div>

        <!-- 🔥 하단 네비게이션 버튼 -->
        <div v-if="datasets.length > 0" style="margin-top: 24px; text-align: center; border-top: 1px solid #f0f0f0; padding-top: 24px">
          <a-space>
            <a-button 
              v-if="currentStep > 0"
              @click="goToPrevStep"
              size="large"
            >
              <template #icon>
                <LeftOutlined />
              </template>
              이전 단계
            </a-button>
            
            <a-button 
              v-if="currentStep < steps.length - 1"
              type="primary"
              @click="goToNextStep"
              :disabled="!canGoNext"
              size="large"
            >
              다음 단계
              <template #icon>
                <RightOutlined />
              </template>
            </a-button>

            <a-button 
              v-if="currentStep === steps.length - 1"
              type="primary" 
              @click="saveChart"
              :disabled="!canSaveChart"
              size="large"
            >
              <template #icon>
                <SaveOutlined />
              </template>
              차트 저장
            </a-button>
          </a-space>
        </div>

        <!-- 🔥 디버깅 정보 (개발 환경에서만 표시) -->
        <div v-if="showDebugInfo" style="margin-top: 24px; padding: 16px; background: #f5f5f5; border-radius: 6px; font-size: 12px">
          <h4>🔧 디버깅 정보</h4>
          <p><strong>현재 단계:</strong> {{ currentStep }} / {{ steps.length - 1 }}</p>
          <p><strong>선택된 데이터셋:</strong> {{ selectedDataset?.table_name || 'None' }}</p>
          <p><strong>차트 타입:</strong> {{ chartConfig.viz_type || 'None' }}</p>
          <p><strong>데이터셋 컬럼 개수:</strong> {{ datasetColumns.length }}</p>
          <p><strong>다음 단계 가능:</strong> {{ canGoNext ? 'Yes' : 'No' }}</p>
          <p><strong>컬럼 로딩 중:</strong> {{ columnsLoading ? 'Yes' : 'No' }}</p>
          <a-button size="small" @click="showDebugInfo = false">디버깅 정보 숨기기</a-button>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { defineComponent, ref, computed, onMounted, h } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  ReloadOutlined, 
  LeftOutlined, 
  RightOutlined, 
  SaveOutlined 
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import authService from '../services/authService'
import supersetAPI from '../services/supersetAPI'
import DatasetSelection from '../components/chart-builder/DatasetSelection.vue'
import ChartTypeSelection from '../components/chart-builder/ChartTypeSelection.vue'
import ChartConfiguration from '../components/chart-builder/ChartConfiguration.vue'
import ChartDetails from '../components/chart-builder/ChartDetails.vue'
import ChartPreview from '../components/chart-builder/ChartPreview.vue'

export default defineComponent({
  name: 'ChartBuilderView',
  components: {
    ReloadOutlined,
    LeftOutlined,
    RightOutlined,
    SaveOutlined,
    DatasetSelection,
    ChartTypeSelection,
    ChartConfiguration,
    ChartDetails,
    ChartPreview
  },
  setup() {
    const router = useRouter()
    const route = useRoute()

    const currentStep = ref(0)
    const loading = ref(false)
    const columnsLoading = ref(false) // 🔥 추가: 컬럼 로딩 상태
    const datasets = ref([])
    const selectedDataset = ref(null)
    const datasetColumns = ref([])
    const datasetMetrics = ref([])
    const chartData = ref(null)
    const previewLoading = ref(false)
    const showDebugInfo = ref(process.env.NODE_ENV === 'development') // 🔥 개발 환경에서만 표시

    const chartConfig = ref({
      datasource_id: null,
      viz_type: 'table',
      slice_name: '',
      description: '',
      params: {}
    })

    const steps = [
      { title: '데이터셋', description: '데이터 선택' },
      { title: '차트 타입', description: '시각화 유형' },
      { title: '설정', description: '차트 구성' },
      { title: '정보', description: '이름 및 설명' },
      { title: '저장', description: '미리보기 및 저장' }
    ]

    const canCreateChart = computed(() => authService.canCreateChart())

    // 🔥 단계별 진행 가능 여부 검증 (조건 완화)
    const canGoNext = computed(() => {
      switch (currentStep.value) {
        case 0: // 데이터셋 선택
          return selectedDataset.value !== null
        case 1: // 차트 타입 선택
          return chartConfig.value.viz_type !== ''
        case 2: // 차트 설정 (조건 완화)
          return chartConfig.value.params?.metrics?.length > 0 || Object.keys(chartConfig.value.params || {}).length > 0
        case 3: // 차트 정보
          return chartConfig.value.slice_name?.trim() !== ''
        default:
          return false
      }
    })

    // 🔥 차트 저장 가능 여부 (조건 완화)
    const canSaveChart = computed(() => {
      return selectedDataset.value && 
             chartConfig.value.viz_type && 
             chartConfig.value.slice_name?.trim()
    })

    const loadDatasets = async () => {
      loading.value = true
      try {
        const data = await supersetAPI.getDatasets()
        datasets.value = data
      } catch (error) {
        console.error('데이터셋 로드 오류:', error)
        message.error('데이터셋을 불러오는 중 오류가 발생했습니다.')
      } finally {
        loading.value = false
      }
    }

    // 🔥 개선된 데이터셋 컬럼 로드
    const loadDatasetColumns = async (datasetId) => {
      columnsLoading.value = true
      try {
        console.log(`컬럼 로드 시작: 데이터셋 ${datasetId}`)
        
        // 컬럼 정보 로드
        const columns = await supersetAPI.getDatasetColumns(datasetId)
        datasetColumns.value = columns || []
        console.log('로드된 컬럼:', columns)
        
        // 메트릭 정보 로드 (실패해도 계속 진행)
        try {
          const metrics = await supersetAPI.getDatasetMetrics(datasetId)
          datasetMetrics.value = metrics || []
          console.log('로드된 메트릭:', metrics)
        } catch (metricError) {
          console.warn('메트릭 로드 중 오류 (무시 가능):', metricError)
          datasetMetrics.value = []
        }
        
        // 기본 차트 설정 초기화
        if (!chartConfig.value.params || Object.keys(chartConfig.value.params).length === 0) {
          chartConfig.value.params = {
            metrics: ['count'], // 기본 메트릭
            groupby: [],
            row_limit: 1000
          }
        }
        
      } catch (error) {
        console.error('컬럼 로드 오류:', error)
        message.error('데이터셋 컬럼을 불러오는 중 오류가 발생했습니다.')
        
        // 오류가 발생해도 기본 구조는 제공
        datasetColumns.value = []
        datasetMetrics.value = []
        chartConfig.value.params = {
          metrics: ['count'],
          groupby: [],
          row_limit: 1000
        }
      } finally {
        columnsLoading.value = false
      }
    }

    // 🔥 단계 직접 설정
    const setCurrentStep = (step) => {
      if (step <= currentStep.value || step === 0) {
        currentStep.value = step
      }
    }

    // 🔥 다음 단계로 이동
    const goToNextStep = () => {
      if (canGoNext.value && currentStep.value < steps.length - 1) {
        currentStep.value++
        console.log('다음 단계로 이동:', currentStep.value)
      }
    }

    // 🔥 이전 단계로 이동
    const goToPrevStep = () => {
      if (currentStep.value > 0) {
        currentStep.value--
        console.log('이전 단계로 이동:', currentStep.value)
      }
    }

    // 폼 초기화
    const resetForm = () => {
      currentStep.value = 0
      selectedDataset.value = null
      datasetColumns.value = []
      datasetMetrics.value = []
      chartData.value = null
      chartConfig.value = {
        datasource_id: null,
        viz_type: 'table',
        slice_name: '',
        description: '',
        params: {}
      }
      message.success('폼이 초기화되었습니다.')
    }

    const handleDatasetChange = async (datasetId) => {
      const dataset = datasets.value.find(d => d.id === datasetId)
      selectedDataset.value = dataset
      chartConfig.value.datasource_id = datasetId
      
      try {
        await loadDatasetColumns(datasetId)
        console.log('데이터셋 변경됨:', dataset)
      } catch (error) {
        console.error('데이터셋 컬럼 로드 오류:', error)
        message.error('데이터셋 컬럼 정보를 불러오는 중 오류가 발생했습니다.')
      }
    }

    const handleChartTypeChange = (vizType) => {
      chartConfig.value.viz_type = vizType
      console.log('차트 타입 변경됨:', vizType)
      
      // 차트 타입에 따른 기본 파라미터 설정
      const defaultParams = {
        table: { metrics: ['count'], groupby: [], row_limit: 1000 },
        bar: { metrics: ['count'], groupby: [], row_limit: 1000, color_scheme: 'bnbColors' },
        line: { metrics: ['count'], groupby: [], row_limit: 1000, color_scheme: 'bnbColors' },
        pie: { metrics: ['count'], groupby: [], row_limit: 1000, color_scheme: 'bnbColors' },
        area: { metrics: ['count'], groupby: [], row_limit: 1000, color_scheme: 'bnbColors' },
        scatter: { metrics: ['count'], groupby: [], row_limit: 1000, color_scheme: 'bnbColors' }
      }
      
      chartConfig.value.params = { 
        ...chartConfig.value.params, 
        ...(defaultParams[vizType] || defaultParams.table) 
      }
    }

    const updateChartConfig = (updates) => {
      if (typeof updates === 'object') {
        Object.assign(chartConfig.value, updates)
        if (updates.params) {
          chartConfig.value.params = { ...chartConfig.value.params, ...updates.params }
        }
      }
      console.log('차트 설정 업데이트:', chartConfig.value)
    }

    const previewChart = async () => {
      if (!selectedDataset.value || !chartConfig.value.viz_type) {
        message.warning('데이터셋과 차트 타입을 먼저 선택해주세요.')
        return
      }

      if (!chartConfig.value.params?.metrics?.length) {
        message.warning('최소 하나의 메트릭을 선택해주세요.')
        return
      }

      previewLoading.value = true
      try {
        console.log('🔍 미리보기 시작 - 차트 설정:', chartConfig.value)
        
        // 1차 시도: 정식 차트 API 사용
        try {
          console.log('1️⃣ 정식 차트 API 시도...')
          const preview = await supersetAPI.previewChart(chartConfig.value)
          chartData.value = preview
          message.success('차트 미리보기가 생성되었습니다.')
          return
        } catch (chartApiError) {
          console.warn('❌ 차트 API 실패:', chartApiError.message)
          
          // 2차 시도: SQL Lab을 통한 미리보기
          try {
            console.log('2️⃣ SQL Lab 대안 시도...')
            const sqlPreview = await supersetAPI.previewChartViaSQL(
              chartConfig.value.datasource_id, 
              chartConfig.value
            )
            chartData.value = sqlPreview
            message.success('차트 미리보기가 생성되었습니다. (SQL Lab 사용)')
            return
          } catch (sqlError) {
            console.warn('❌ SQL Lab도 실패:', sqlError.message)
            
            // 3차 시도: 간단한 모의 데이터 미리보기
            try {
              console.log('3️⃣ 모의 데이터 미리보기 시도...')
              const mockPreview = await supersetAPI.simplePreview(
                chartConfig.value.datasource_id,
                chartConfig.value
              )
              chartData.value = mockPreview
              message.success('차트 미리보기가 생성되었습니다. (테스트 모드)', 3)
              message.info('실제 데이터는 차트 저장 후 Superset에서 확인할 수 있습니다.', 5)
              return
            } catch (mockError) {
              console.error('❌ 모의 데이터도 실패:', mockError.message)
              throw chartApiError // 최초 오류를 던짐
            }
          }
        }
        
      } catch (error) {
        console.error('💥 차트 미리보기 최종 실패:', error)
        
        // 상세 오류 정보 표시
        let errorMsg = '차트 미리보기 생성 중 오류가 발생했습니다.'
        if (error.response?.status === 400) {
          errorMsg += '\n잘못된 요청입니다. 차트 설정을 확인해주세요.'
        } else if (error.response?.status === 401) {
          errorMsg += '\n인증이 만료되었습니다. 다시 로그인해주세요.'
        } else if (error.response?.status === 403) {
          errorMsg += '\n데이터 접근 권한이 없습니다.'
        } else if (error.response?.status === 404) {
          errorMsg += '\n데이터셋을 찾을 수 없습니다.'
        } else if (error.response?.status >= 500) {
          errorMsg += '\n서버 오류입니다. 잠시 후 다시 시도해주세요.'
        }
        
        message.error(errorMsg, 8)
        
        // 개발 환경에서는 더 상세한 오류 표시
        if (showDebugInfo.value) {
          console.group('🐛 개발자용 상세 오류 정보')
          console.error('HTTP 상태:', error.response?.status)
          console.error('응답 데이터:', error.response?.data)
          console.error('요청 URL:', error.config?.url)
          console.error('요청 메서드:', error.config?.method)
          console.error('요청 데이터:', error.config?.data)
          console.groupEnd()
        }
        
        // 사용자에게 차트 저장 옵션 제안
        message.info('미리보기가 실패했지만 차트를 저장하면 Superset에서 직접 확인할 수 있습니다.', 6)
        
      } finally {
        previewLoading.value = false
      }
    }

    const saveChart = async () => {
      if (!canSaveChart.value) {
        message.error('필수 정보를 모두 입력해주세요.')
        return
      }

      try {
        const payload = {
          slice_name: chartConfig.value.slice_name,
          description: chartConfig.value.description,
          datasource_id: chartConfig.value.datasource_id,
          datasource_type: 'table',
          viz_type: chartConfig.value.viz_type,
          params: JSON.stringify(chartConfig.value.params)
        }
        
        await supersetAPI.createChart(payload)
        message.success('차트가 성공적으로 생성되었습니다!')
        router.push('/charts')
      } catch (error) {
        console.error('차트 저장 오류:', error)
        message.error('차트 저장 중 오류가 발생했습니다.')
      }
    }

    // 컴포넌트 마운트 시 데이터 로드
    onMounted(() => {
      if (authService.canCreateChart()) {
        loadDatasets()
      }
    })

    return {
      h,
      currentStep,
      loading,
      columnsLoading,
      datasets,
      selectedDataset,
      datasetColumns,
      datasetMetrics,
      chartData,
      previewLoading,
      chartConfig,
      steps,
      canCreateChart,
      canGoNext,
      canSaveChart,
      showDebugInfo,
      setCurrentStep,
      goToNextStep,
      goToPrevStep,
      resetForm,
      handleDatasetChange,
      handleChartTypeChange,
      updateChartConfig,
      previewChart,
      saveChart
    }
  }
})
</script>

<style scoped>
.ant-steps {
  margin-bottom: 24px;
}

.ant-steps .ant-steps-item {
  cursor: pointer;
}

.ant-steps .ant-steps-item:hover .ant-steps-item-title {
  color: #1890ff;
}

.ant-button {
  border-radius: 6px;
}

.ant-alert {
  border-radius: 6px;
  margin-bottom: 24px;
}

/* 디버깅 정보 스타일 */
.debug-info {
  background: #f5f5f5;
  border: 1px solid #d9d9d9;
  border-radius: 6px;
  padding: 16px;
  margin-top: 24px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
}

.debug-info h4 {
  margin: 0 0 12px 0;
  color: #1890ff;
}

.debug-info p {
  margin: 4px 0;
  color: #666;
}
</style>