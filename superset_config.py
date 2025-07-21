# superset_config.py
import os
from datetime import timedelta
from flask_cors import CORS
from flask import request, make_response

# 기본 설정
ROW_LIMIT = 5000
SUPERSET_WEBSERVER_PORT = 8088
SUPERSET_WEBSERVER_TIMEOUT = 60

# 시크릿 키 (32바이트 이상 필수)
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'your_secret_key_here_must_be_at_least_32_bytes_long_for_security')

# JWT 설정
JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)  # 24시간
JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=7)   # 7일
GUEST_TOKEN_JWT_SECRET = os.environ.get('SUPERSET_JWT_SECRET', 'super_secret_jwt_key_that_is_at_least_32_bytes_long_for_async_queries')

# 데이터베이스 설정
SQLALCHEMY_DATABASE_URI = os.environ.get(
    'SQLALCHEMY_DATABASE_URI',
    'mysql+pymysql://superset:superset123@mariadb:3306/sample_dashboard'
)

# Redis 설정
REDIS_HOST = os.environ.get('REDIS_HOST', 'redis')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))

# 캐시 설정
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 1,
    'CACHE_REDIS_URL': f'redis://{REDIS_HOST}:{REDIS_PORT}/1'
}

# 🔥 CORS 설정 - 리다이렉트 문제 해결
ENABLE_CORS = True

# 🔥 개발 환경을 위한 매우 관대한 CORS 설정
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': [
        'X-CSRFToken', 'Content-Type', 'Origin', 'Authorization',
        'Accept', 'Accept-Language', 'DNT', 'Cache-Control',
        'X-Mx-ReqToken', 'Keep-Alive', 'User-Agent',
        'X-Requested-With', 'If-Modified-Since', 'X-Forwarded-For',
        'X-Forwarded-Proto', 'X-Forwarded-Host', 'Accept-Encoding',
        'Connection', 'Host', 'Pragma', 'Referer'
    ],
    'methods': ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH', 'HEAD'],
    'origins': [
        'http://localhost:8080',
        'http://127.0.0.1:8080', 
        'http://0.0.0.0:8080',
        'http://vue-frontend:8080',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://host.docker.internal:8080',
        '*'  # 개발 환경에서만 모든 origin 허용
    ],
    'expose_headers': ['Content-Range', 'X-Content-Range'],
    'max_age': 21600,  # 6시간
    'send_wildcard': False,
    'vary_header': True
}

# 🔥 CSRF 설정 - 개발 환경에서 더 유연하게
WTF_CSRF_ENABLED = False  # 개발 환경에서 CSRF 완전 비활성화
WTF_CSRF_EXEMPT_LIST = [
    'superset.views.api.*',  # 모든 API 엔드포인트 CSRF 면제
    'superset.views.core.*'
]
WTF_CSRF_TIME_LIMIT = None
WTF_CSRF_SSL_STRICT = False

# 🔥 세션 설정
PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
SESSION_COOKIE_HTTPONLY = False  # 개발 환경에서 false
SESSION_COOKIE_SECURE = False    # 개발 환경에서 false
SESSION_COOKIE_SAMESITE = None   # 개발 환경에서 None

# 🔥 보안 헤더 설정 - 개발 환경에서 완화
TALISMAN_ENABLED = False
TALISMAN_CONFIG = {
    'force_https': False,
    'strict_transport_security': False,
    'content_security_policy': False
}

# 🔥 리다이렉트 문제 해결을 위한 설정
PREFERRED_URL_SCHEME = 'http'  # 개발 환경에서 http 사용
APPLICATION_ROOT = '/'
SEND_FILE_MAX_AGE_DEFAULT = 0

# Public Role 설정 (게스트 접근용)
PUBLIC_ROLE_LIKE_GAMMA = True
AUTH_ROLE_PUBLIC = 'Public'

# 자동 사용자 등록 설정
AUTH_USER_REGISTRATION = False
AUTH_USER_REGISTRATION_ROLE = "Public"

# Feature flags
FEATURE_FLAGS = {
    'ENABLE_TEMPLATE_PROCESSING': True,
    'DASHBOARD_NATIVE_FILTERS': True,
    'DASHBOARD_CROSS_FILTERS': True,
    'GLOBAL_ASYNC_QUERIES': True,
    'VERSIONED_EXPORT': True,
    'EMBEDDED_SUPERSET': True,
    'DASHBOARD_RBAC': True,
    'ROW_LEVEL_SECURITY': True
}

# 비동기 쿼리 설정
GLOBAL_ASYNC_QUERIES_TRANSPORT = "polling"
GLOBAL_ASYNC_QUERIES_POLLING_DELAY = 500
GLOBAL_ASYNC_QUERIES_JWT_SECRET = GUEST_TOKEN_JWT_SECRET

# Redis 결과 백엔드
RESULTS_BACKEND = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 86400,
    'CACHE_KEY_PREFIX': 'superset_results_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 0,
}

# SQL Lab 설정
SQLLAB_CTAS_NO_LIMIT = True

# 로깅 설정
ENABLE_TIME_ROTATE = True
LOG_LEVEL = 'DEBUG'
LOG_FORMAT = '%(asctime)s:%(levelname)s:%(name)s:%(message)s'

# 웹서버 설정
WEBDRIVER_BASEURL = "http://superset:8088/"
WEBDRIVER_BASEURL_USER_FRIENDLY = "http://localhost:8088/"

# API 설정
API_PAGE_SIZE = 20

# 차트 및 대시보드 설정
SUPERSET_WEBSERVER_DOMAINS = None
ENABLE_PROXY_FIX = True

# 업로드 설정
CSV_TO_HIVE_UPLOAD_S3_BUCKET = None
UPLOAD_FOLDER = '/tmp/'
IMG_UPLOAD_FOLDER = '/tmp/'
IMG_UPLOAD_URL = '/static/uploads/'

# 이메일 설정 (선택사항)
SMTP_HOST = None
SMTP_STARTTLS = True
SMTP_SSL = False
SMTP_USER = None
SMTP_PORT = 25
SMTP_PASSWORD = None
SMTP_MAIL_FROM = None

# 알림 설정
ENABLE_ALERTS = False

# 데이터베이스 연결 풀 설정
SQLALCHEMY_ENGINE_OPTIONS = {
    'pool_size': 10,
    'pool_timeout': 20,
    'pool_recycle': -1,
    'max_overflow': 0,
    'pool_pre_ping': True
}

# 🔥 Flask 앱 초기화 후 CORS 수동 설정
def FLASK_APP_MUTATOR(app):
    """Flask 앱 초기화 후 추가 설정"""
    from flask_cors import CORS
    
    # 기존 CORS 설정 제거 후 새로 적용
    CORS(app, 
         origins=['*'],  # 모든 origin 허용 (개발 환경)
         allow_headers=['*'],  # 모든 헤더 허용
         methods=['*'],  # 모든 메서드 허용
         supports_credentials=True,
         send_wildcard=False)
    
    # 수동으로 모든 라우트에 CORS 헤더 추가
    @app.after_request
    def after_request(response):
        origin = request.headers.get('Origin')
        if origin:
            response.headers['Access-Control-Allow-Origin'] = origin
        else:
            response.headers['Access-Control-Allow-Origin'] = '*'
        
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS, PATCH'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-CSRFToken, X-Requested-With, Origin, Accept'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Max-Age'] = '3600'
        
        return response
    
    # OPTIONS 요청 처리
    @app.before_request
    def handle_preflight():
        if request.method == "OPTIONS":
            response = make_response()
            origin = request.headers.get('Origin')
            if origin:
                response.headers['Access-Control-Allow-Origin'] = origin
            else:
                response.headers['Access-Control-Allow-Origin'] = '*'
            response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS, PATCH'
            response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-CSRFToken, X-Requested-With, Origin, Accept'
            response.headers['Access-Control-Allow-Credentials'] = 'true'
            return response

# 개발 환경에서만 적용될 추가 설정들
if os.environ.get('FLASK_ENV') == 'development':
    # 개발 환경에서는 보안 제한을 완화
    print("🔧 개발 환경 모드: 보안 설정 완화")

print("✅ Superset 설정 로드 완료")
print(f"📊 데이터베이스 URI: {SQLALCHEMY_DATABASE_URI}")
print(f"🔄 Redis 호스트: {REDIS_HOST}:{REDIS_PORT}")
print(f"🌐 CORS 활성화: {ENABLE_CORS}")
print(f"🔒 CSRF 활성화: {WTF_CSRF_ENABLED}")