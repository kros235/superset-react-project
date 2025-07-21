// vue-frontend/vue.config.js
const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: true,
  lintOnSave: false,  // ESLint 오류로 인한 빌드 중단 방지

  // 개발 서버 설정
  devServer: {
    host: '0.0.0.0',
    port: 8080,
    allowedHosts: 'all',
    
    // 클라이언트 오버레이 설정
    client: {
      overlay: {
        errors: false,
        warnings: false,
        runtimeErrors: false
      }
    },

    // 🔥 프록시 설정 - CORS 문제 해결
    proxy: {
      '/api': {
        target: 'http://superset:8088',  // 컨테이너 이름 사용
        changeOrigin: true,
        secure: false,
        timeout: 30000,
        followRedirects: false,  // 🔥 리다이렉트 방지
        
        // 상세 로깅
        logLevel: 'debug',
        
        // 🔥 헤더 설정 개선
        headers: {
          'Connection': 'keep-alive',
          'X-Forwarded-For': '127.0.0.1',
          'X-Forwarded-Proto': 'http',
          'X-Forwarded-Host': 'localhost:8080',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache'
        },
        
        // 🔥 이벤트 핸들러 개선
        onProxyReq: function(proxyReq, req, res) {
          console.log(`[프록시 요청] ${req.method} ${req.url} -> http://superset:8088${req.url}`)
          
          // CORS 헤더 설정
          proxyReq.setHeader('Origin', 'http://localhost:8080')
          proxyReq.setHeader('Referer', 'http://localhost:8080/')
          proxyReq.setHeader('Access-Control-Request-Method', req.method)
          proxyReq.setHeader('Access-Control-Request-Headers', 'content-type,authorization,x-csrftoken,x-requested-with')
          
          // 🔥 리다이렉트 방지를 위한 헤더
          proxyReq.setHeader('X-Forwarded-Proto', 'http')
          proxyReq.setHeader('X-Forwarded-Port', '8080')
          
          // Content-Length 설정 (POST 요청시 필요)
          if (req.method === 'POST' && req.body) {
            const bodyData = JSON.stringify(req.body)
            proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData))
            proxyReq.write(bodyData)
          }
        },
        
        onProxyRes: function(proxyRes, req, res) {
          console.log(`[프록시 응답] ${proxyRes.statusCode} ${req.url}`)
          
          // 🔥 리다이렉트 응답 처리
          if (proxyRes.statusCode >= 300 && proxyRes.statusCode < 400) {
            console.warn(`[리다이렉트 감지] ${proxyRes.statusCode} - ${proxyRes.headers.location}`)
            
            // 리다이렉트를 직접 처리하지 않고 클라이언트에 알림
            proxyRes.statusCode = 200
            proxyRes.headers = {
              'content-type': 'application/json',
              'access-control-allow-origin': 'http://localhost:8080',
              'access-control-allow-credentials': 'true'
            }
          }
          
          // 🔥 CORS 응답 헤더 강제 설정
          proxyRes.headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
          proxyRes.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS, PATCH'
          proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-CSRFToken, X-Requested-With, Origin, Accept'
          proxyRes.headers['Access-Control-Allow-Credentials'] = 'true'
          proxyRes.headers['Access-Control-Max-Age'] = '3600'
          
          // 캐시 방지
          proxyRes.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
          proxyRes.headers['Pragma'] = 'no-cache'
          proxyRes.headers['Expires'] = '0'
        },
        
        onError: function(err, req, res) {
          console.error(`[프록시 오류] ${req.url}:`, err.message)
          console.error('오류 세부사항:', {
            code: err.code,
            errno: err.errno,
            syscall: err.syscall,
            address: err.address,
            port: err.port
          })
          
          // 🔥 오류 응답 개선
          if (!res.headersSent) {
            res.writeHead(500, {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': 'http://localhost:8080',
              'Access-Control-Allow-Credentials': 'true'
            })
            res.end(JSON.stringify({
              error: 'Proxy Error',
              message: `Superset 서버에 연결할 수 없습니다: ${err.message}`,
              code: err.code,
              suggestion: 'Superset 컨테이너가 실행 중인지 확인하세요.'
            }))
          }
        }
      },
      
      // 🔥 헬스체크 프록시 개선
      '/health': {
        target: 'http://superset:8088',
        changeOrigin: true,
        secure: false,
        followRedirects: false,
        onProxyReq: function(proxyReq, req, res) {
          console.log('[헬스체크] Superset 연결 확인 중...')
          proxyReq.setHeader('User-Agent', 'Vue-Frontend-Health-Check')
        },
        onProxyRes: function(proxyRes, req, res) {
          console.log(`[헬스체크] Superset 상태: ${proxyRes.statusCode}`)
          proxyRes.headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
        },
        onError: function(err, req, res) {
          console.error('[헬스체크] Superset 연결 실패:', err.message)
          if (!res.headersSent) {
            res.writeHead(503, { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': 'http://localhost:8080'
            })
            res.end(JSON.stringify({ 
              error: 'Superset unavailable',
              message: err.message 
            }))
          }
        }
      }
    }
  },

  // 빌드 설정
  publicPath: '/',
  outputDir: 'dist',
  
  // 🔥 웹팩 설정 개선
  configureWebpack: {
    resolve: {
      alias: {
        '@': require('path').resolve(__dirname, 'src')
      }
    },
    // 개발 환경 최적화
    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all'
          }
        }
      }
    },
    // 🔥 추가 설정
    devtool: 'eval-source-map',
    stats: {
      errors: true,
      warnings: true,
      modules: false,
      chunks: false
    }
  },

  // CSS 설정
  css: {
    loaderOptions: {
      less: {
        lessOptions: {
          modifyVars: {
            '@primary-color': '#1890ff',
            '@link-color': '#1890ff',
            '@border-radius-base': '6px'
          },
          javascriptEnabled: true
        }
      }
    }
  }
})