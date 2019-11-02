 -- 7-1 테이블 전체의 특징량 계산(COUNT, SUM, MAX, MIN)
 SELECT 
    COUNT(*) AS total_count,
    COUNT(DISTINCT user_id) AS user_count,
    COUNT(DISTINCT product_id) AS product_count,
    SUM(score) AS sum,
    AVG(score) AS avg,
    MAX(score) AS max,
    MIN(score) AS min
FROM review;

-- 7-2 그루핑한 데이터의 특징량 계산
SELECT
    user_id,
    COUNT(*) AS total_count,
    COUNT(DISTINCT product_id) AS product_count,
    SUM(score) AS sum,
    AVG(score) AS avg,
    MAX(score) AS max,
    MIN(score) AS min
FROM review
GROUP BY user_id;

-- 7-3 집약 함수를 적용한 값과 집약 전의 값을 동시에 다루기
SELECT
    user_id,
    product_id,
    -- 개별 평균 리뷰 점수
    score,
    -- 전체 평균 리뷰 점수
    AVG(score) OVER() AS avg_score,
    -- 사용자의 평균 리뷰 점수
    AVG(score) OVER(PARTITION BY user_id) AS user_avg_score
    -- 개별 리뷰 점수와 사용자 평균 리뷰 점수의 차이
    score - AVG(score) OVER(PARTITION BY user_id) AS user_avg_score_diff
FROM 
    review;


