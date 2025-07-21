-- database/init/01-create-sample-database.sql
-- MariaDB 초기 설정 및 샘플 데이터베이스 생성

-- 1. 샘플 대시보드용 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS sample_dashboard 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 2. 샘플 데이터베이스 사용
USE sample_dashboard;

-- 3. 사용자 테이블 생성
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    department VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    position VARCHAR(50) NOT NULL,
    status ENUM('active', 'inactive', 'on_leave') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 4. 판매 데이터 테이블 생성
CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    salesperson VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_type ENUM('new', 'returning', 'premium') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. 웹 트래픽 테이블 생성
CREATE TABLE web_traffic (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visit_date DATE NOT NULL,
    unique_visitors INT NOT NULL,
    page_views INT NOT NULL,
    bounce_rate DECIMAL(5,2) NOT NULL,
    session_duration INT NOT NULL, -- 초 단위
    traffic_source VARCHAR(50) NOT NULL,
    device_type ENUM('desktop', 'mobile', 'tablet') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. 고객 만족도 테이블 생성
CREATE TABLE customer_satisfaction (
    id INT AUTO_INCREMENT PRIMARY KEY,
    survey_date DATE NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    category VARCHAR(50) NOT NULL,
    feedback TEXT,
    customer_age_group ENUM('18-25', '26-35', '36-45', '46-55', '56+') NOT NULL,
    response_time_hours INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 인덱스 생성 (성능 최적화)
CREATE INDEX idx_users_department ON users(department);
CREATE INDEX idx_users_join_date ON users(join_date);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_region ON sales(region);
CREATE INDEX idx_web_traffic_date ON web_traffic(visit_date);
CREATE INDEX idx_web_traffic_source ON web_traffic(traffic_source);
CREATE INDEX idx_satisfaction_date ON customer_satisfaction(survey_date);
CREATE INDEX idx_satisfaction_category ON customer_satisfaction(category);

-- 8. 사용자 테이블 샘플 데이터 삽입 (30개)
INSERT INTO users (name, email, department, join_date, salary, position, status) VALUES
('김철수', 'kim.cs@company.com', 'IT', '2022-01-15', 4500000, 'Senior Developer', 'active'),
('이영희', 'lee.yh@company.com', 'HR', '2021-03-20', 3800000, 'HR Manager', 'active'),
('박민수', 'park.ms@company.com', 'Finance', '2023-05-10', 4200000, 'Financial Analyst', 'active'),
('최지원', 'choi.jw@company.com', 'Marketing', '2022-08-05', 3900000, 'Marketing Specialist', 'active'),
('정우진', 'jung.wj@company.com', 'IT', '2021-11-12', 5200000, 'Tech Lead', 'active'),
('한서연', 'han.sy@company.com', 'Sales', '2023-02-28', 4100000, 'Sales Manager', 'active'),
('임도현', 'lim.dh@company.com', 'IT', '2022-06-18', 4000000, 'Full Stack Developer', 'active'),
('송미라', 'song.mr@company.com', 'HR', '2021-09-30', 3600000, 'Recruiter', 'active'),
('윤태희', 'yoon.th@company.com', 'Finance', '2023-01-22', 3700000, 'Accountant', 'active'),
('강민호', 'kang.mh@company.com', 'Marketing', '2022-04-14', 4300000, 'Product Manager', 'active'),
('조수빈', 'jo.sb@company.com', 'IT', '2023-07-01', 3500000, 'Junior Developer', 'active'),
('서현우', 'seo.hw@company.com', 'Sales', '2021-12-08', 4600000, 'Regional Director', 'active'),
('노은지', 'noh.ej@company.com', 'HR', '2022-10-25', 3400000, 'HR Assistant', 'active'),
('문재원', 'moon.jw@company.com', 'Finance', '2023-03-16', 3900000, 'Budget Analyst', 'active'),
('배정현', 'bae.jh@company.com', 'Marketing', '2021-07-19', 4400000, 'Marketing Director', 'active'),
('신동엽', 'shin.dy@company.com', 'IT', '2022-12-03', 4700000, 'DevOps Engineer', 'active'),
('오가영', 'oh.gy@company.com', 'Sales', '2023-04-11', 3800000, 'Sales Representative', 'active'),
('황민정', 'hwang.mj@company.com', 'HR', '2021-05-27', 4100000, 'Training Manager', 'active'),
('전상훈', 'jeon.sh@company.com', 'Finance', '2022-09-14', 4000000, 'Financial Controller', 'active'),
('김나영', 'kim.ny@company.com', 'Marketing', '2023-06-08', 3600000, 'Content Specialist', 'active'),
('이준호', 'lee.jh@company.com', 'IT', '2021-08-31', 5000000, 'System Architect', 'active'),
('박소영', 'park.sy@company.com', 'Sales', '2022-02-17', 3900000, 'Account Manager', 'active'),
('최동현', 'choi.dh@company.com', 'HR', '2023-08-23', 3300000, 'HR Coordinator', 'active'),
('정민아', 'jung.ma@company.com', 'Finance', '2021-10-06', 4300000, 'Senior Accountant', 'active'),
('한지우', 'han.jw@company.com', 'Marketing', '2022-11-29', 4200000, 'Brand Manager', 'active'),
('임수현', 'lim.sh@company.com', 'IT', '2023-09-12', 3700000, 'QA Engineer', 'active'),
('송재민', 'song.jm@company.com', 'Sales', '2021-06-21', 4500000, 'Sales Director', 'active'),
('윤서진', 'yoon.sj@company.com', 'HR', '2022-07-04', 3500000, 'Benefits Administrator', 'active'),
('강태윤', 'kang.ty@company.com', 'Finance', '2023-10-15', 3800000, 'Tax Specialist', 'active'),
('조민서', 'jo.ms@company.com', 'Marketing', '2021-04-13', 4600000, 'Digital Marketing Manager', 'active');

-- 9. 판매 데이터 샘플 삽입 (30개)
INSERT INTO sales (sale_date, product_name, quantity, unit_price, total_amount, salesperson, region, customer_type) VALUES
('2024-01-05', 'Laptop Pro 16', 15, 2500000.00, 37500000.00, '한서연', 'Seoul', 'premium'),
('2024-01-08', 'Smartphone Elite', 25, 1200000.00, 30000000.00, '서현우', 'Busan', 'returning'),
('2024-01-12', 'Tablet Max', 20, 800000.00, 16000000.00, '오가영', 'Daegu', 'new'),
('2024-01-15', 'Desktop Workstation', 8, 3000000.00, 24000000.00, '박소영', 'Seoul', 'premium'),
('2024-01-18', 'Wireless Earbuds', 50, 300000.00, 15000000.00, '송재민', 'Incheon', 'returning'),
('2024-01-22', 'Smart Watch', 30, 500000.00, 15000000.00, '한서연', 'Seoul', 'new'),
('2024-01-25', 'Gaming Monitor', 12, 700000.00, 8400000.00, '서현우', 'Busan', 'premium'),
('2024-01-28', 'Mechanical Keyboard', 40, 200000.00, 8000000.00, '오가영', 'Daegu', 'returning'),
('2024-02-02', 'Webcam HD', 35, 150000.00, 5250000.00, '박소영', 'Seoul', 'new'),
('2024-02-05', 'External SSD', 22, 400000.00, 8800000.00, '송재민', 'Incheon', 'premium'),
('2024-02-08', 'Laptop Air 14', 18, 1800000.00, 32400000.00, '한서연', 'Seoul', 'returning'),
('2024-02-12', 'Smartphone Basic', 45, 600000.00, 27000000.00, '서현우', 'Busan', 'new'),
('2024-02-15', 'Tablet Mini', 28, 500000.00, 14000000.00, '오가영', 'Daegu', 'premium'),
('2024-02-18', 'All-in-One PC', 10, 2200000.00, 22000000.00, '박소영', 'Seoul', 'returning'),
('2024-02-22', 'Bluetooth Speaker', 60, 250000.00, 15000000.00, '송재민', 'Incheon', 'new'),
('2024-02-25', 'Fitness Tracker', 35, 180000.00, 6300000.00, '한서연', 'Seoul', 'premium'),
('2024-02-28', 'Gaming Headset', 25, 350000.00, 8750000.00, '서현우', 'Busan', 'returning'),
('2024-03-04', 'USB-C Hub', 55, 120000.00, 6600000.00, '오가영', 'Daegu', 'new'),
('2024-03-07', 'Portable Charger', 70, 80000.00, 5600000.00, '박소영', 'Seoul', 'premium'),
('2024-03-11', 'Wireless Mouse', 45, 100000.00, 4500000.00, '송재민', 'Incheon', 'returning'),
('2024-03-14', 'Laptop Business', 12, 2000000.00, 24000000.00, '한서연', 'Seoul', 'new'),
('2024-03-18', 'Smartphone Pro', 20, 1500000.00, 30000000.00, '서현우', 'Busan', 'premium'),
('2024-03-21', 'Tablet Pro', 15, 1200000.00, 18000000.00, '오가영', 'Daegu', 'returning'),
('2024-03-25', 'Mini PC', 25, 800000.00, 20000000.00, '박소영', 'Seoul', 'new'),
('2024-03-28', 'Smart Home Hub', 30, 400000.00, 12000000.00, '송재민', 'Incheon', 'premium'),
('2024-04-01', 'VR Headset', 8, 1000000.00, 8000000.00, '한서연', 'Seoul', 'returning'),
('2024-04-04', 'Action Camera', 18, 600000.00, 10800000.00, '서현우', 'Busan', 'new'),
('2024-04-08', 'Drone Mini', 10, 1500000.00, 15000000.00, '오가영', 'Daegu', 'premium'),
('2024-04-11', 'Smart Scale', 40, 120000.00, 4800000.00, '박소영', 'Seoul', 'returning'),
('2024-04-15', 'Robot Vacuum', 15, 800000.00, 12000000.00, '송재민', 'Incheon', 'new');

-- 10. 웹 트래픽 샘플 데이터 삽입 (30개)
INSERT INTO web_traffic (visit_date, unique_visitors, page_views, bounce_rate, session_duration, traffic_source, device_type) VALUES
('2024-01-01', 12500, 45000, 35.2, 180, 'organic', 'desktop'),
('2024-01-02', 11800, 42300, 38.1, 165, 'social', 'mobile'),
('2024-01-03', 13200, 48600, 32.8, 195, 'direct', 'desktop'),
('2024-01-04', 10900, 38700, 41.5, 142, 'paid', 'mobile'),
('2024-01-05', 14500, 52200, 29.3, 210, 'organic', 'desktop'),
('2024-01-06', 9800, 35100, 44.2, 128, 'email', 'tablet'),
('2024-01-07', 15600, 56400, 27.9, 225, 'social', 'mobile'),
('2024-01-08', 12100, 43600, 36.7, 172, 'direct', 'desktop'),
('2024-01-09', 11300, 40700, 39.8, 158, 'paid', 'mobile'),
('2024-01-10', 13800, 49700, 31.4, 188, 'organic', 'desktop'),
('2024-01-11', 10200, 36800, 42.6, 135, 'referral', 'tablet'),
('2024-01-12', 14900, 53600, 28.7, 218, 'social', 'mobile'),
('2024-01-13', 12600, 45400, 34.9, 185, 'direct', 'desktop'),
('2024-01-14', 11700, 42100, 37.3, 162, 'paid', 'mobile'),
('2024-01-15', 15200, 54800, 26.8, 232, 'organic', 'desktop'),
('2024-01-16', 9600, 34600, 45.1, 125, 'email', 'tablet'),
('2024-01-17', 16100, 58000, 25.4, 245, 'social', 'mobile'),
('2024-01-18', 13400, 48200, 33.6, 192, 'direct', 'desktop'),
('2024-01-19', 12000, 43200, 38.9, 168, 'paid', 'mobile'),
('2024-01-20', 14700, 52900, 30.1, 205, 'organic', 'desktop'),
('2024-01-21', 10800, 38900, 40.7, 148, 'referral', 'tablet'),
('2024-01-22', 15800, 56900, 27.2, 238, 'social', 'mobile'),
('2024-01-23', 13100, 47200, 35.5, 178, 'direct', 'desktop'),
('2024-01-24', 11900, 42800, 37.8, 165, 'paid', 'mobile'),
('2024-01-25', 14300, 51500, 31.9, 198, 'organic', 'desktop'),
('2024-01-26', 10500, 37800, 43.3, 138, 'email', 'tablet'),
('2024-01-27', 16500, 59400, 24.6, 252, 'social', 'mobile'),
('2024-01-28', 13700, 49300, 32.7, 188, 'direct', 'desktop'),
('2024-01-29', 12400, 44600, 36.2, 175, 'paid', 'mobile'),
('2024-01-30', 15000, 54000, 29.5, 215, 'organic', 'desktop');

-- 11. 고객 만족도 샘플 데이터 삽입 (30개)
INSERT INTO customer_satisfaction (survey_date, rating, category, feedback, customer_age_group, response_time_hours) VALUES
('2024-01-03', 5, 'Product Quality', '제품 품질이 매우 우수합니다. 추천하고 싶어요!', '26-35', 2),
('2024-01-05', 4, 'Customer Service', '친절한 서비스였지만 응답이 조금 느렸어요.', '36-45', 24),
('2024-01-08', 3, 'Delivery', '배송이 예상보다 늦었습니다.', '18-25', 48),
('2024-01-10', 5, 'Website UX', '웹사이트가 사용하기 편리해요!', '26-35', 1),
('2024-01-12', 2, 'Product Quality', '제품에 결함이 있었습니다.', '46-55', 72),
('2024-01-15', 4, 'Customer Service', '문제를 잘 해결해주셨어요.', '36-45', 6),
('2024-01-18', 5, 'Delivery', '빠른 배송 감사합니다!', '26-35', 3),
('2024-01-20', 3, 'Website UX', '일부 기능이 복잡해요.', '56+', 36),
('2024-01-22', 4, 'Product Quality', '전반적으로 만족스럽습니다.', '18-25', 12),
('2024-01-25', 5, 'Customer Service', '완벽한 서비스였어요!', '36-45', 1),
('2024-01-28', 2, 'Delivery', '포장 상태가 좋지 않았어요.', '46-55', 96),
('2024-01-30', 4, 'Website UX', '검색 기능이 유용해요.', '26-35', 4),
('2024-02-02', 5, 'Product Quality', '기대 이상의 품질이에요!', '36-45', 2),
('2024-02-05', 3, 'Customer Service', '상담원이 불친절했어요.', '18-25', 48),
('2024-02-08', 4, 'Delivery', '배송 추적이 정확해요.', '26-35', 8),
('2024-02-10', 5, 'Website UX', '모바일 앱이 훌륭해요!', '36-45', 1),
('2024-02-12', 2, 'Product Quality', '광고와 다른 제품이었어요.', '56+', 120),
('2024-02-15', 4, 'Customer Service', '빠른 응답 감사해요.', '26-35', 3),
('2024-02-18', 5, 'Delivery', '예정 시간보다 빨리 도착!', '18-25', 1),
('2024-02-20', 3, 'Website UX', '결제 과정이 복잡해요.', '46-55', 24),
('2024-02-22', 4, 'Product Quality', '가격 대비 좋은 품질이에요.', '36-45', 6),
('2024-02-25', 5, 'Customer Service', '문제 해결이 빨랐어요!', '26-35', 2),
('2024-02-28', 3, 'Delivery', '배송 지연 안내가 없었어요.', '18-25', 72),
('2024-03-02', 4, 'Website UX', '장바구니 기능이 편리해요.', '36-45', 5),
('2024-03-05', 5, 'Product Quality', '최고의 제품입니다!', '26-35', 1),
('2024-03-08', 2, 'Customer Service', '교환 정책이 불합리해요.', '56+', 168),
('2024-03-10', 4, 'Delivery', '포장이 안전했어요.', '46-55', 12),
('2024-03-12', 5, 'Website UX', '사용자 경험이 최고에요!', '18-25', 2),
('2024-03-15', 3, 'Product Quality', '설명서가 부족해요.', '36-45', 36),
('2024-03-18', 4, 'Customer Service', '친절하고 전문적이었어요.', '26-35', 4);

-- 12. 데이터 확인 쿼리들 (주석으로 제공)
/*
-- 테이블별 데이터 수 확인
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'sales' as table_name, COUNT(*) as count FROM sales
UNION ALL
SELECT 'web_traffic' as table_name, COUNT(*) as count FROM web_traffic
UNION ALL
SELECT 'customer_satisfaction' as table_name, COUNT(*) as count FROM customer_satisfaction;

-- 부서별 직원 수 (대시보드용)
SELECT department, COUNT(*) as employee_count, AVG(salary) as avg_salary
FROM users 
GROUP BY department;

-- 월별 매출 현황 (대시보드용)
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') as month,
    COUNT(*) as total_sales,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM sales 
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month;

-- 일별 웹 트래픽 (대시보드용)
SELECT 
    visit_date,
    unique_visitors,
    page_views,
    bounce_rate,
    session_duration,
    traffic_source
FROM web_traffic 
ORDER BY visit_date;

-- 카테고리별 고객 만족도 (대시보드용)
SELECT 
    category,
    AVG(rating) as avg_rating,
    COUNT(*) as response_count,
    AVG(response_time_hours) as avg_response_time
FROM customer_satisfaction 
GROUP BY category;
*/

-- 13. 완료 메시지
SELECT 'Sample database setup completed successfully!' as status;