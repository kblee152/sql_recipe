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


-- 7-4 그룹 내부의 순서 정의(ORDER BY)
SELECT
    product_id,
    score,

    -- 점수 순서로 유일한 순위를 붙임
    ROW_NUMBER() OVER(ORDER BY score DESC) AS row,

    -- 같은 순위를 허용해서 순위를 붙임
    RANK() OVER(ORDER BY score DESC) AS rank,

    -- 같은 순위가 있을 때 같은 순위 다음에 있는 순위를 건너 뛰고 순위를 붙임
    DENSE_RANK() OVER(ORDER BY score DESC) AS dense_rank,

    
    -- 현재 행보다 앞에 있는 행의 값 추출
    LAG(product_id) OVER(ORDER BY score DESC) AS lag1,
    LAG(Product_id, 2) OVER(ORDER BY score DESC) AS lag2,

    -- 현재 행보다 뒤에 있는 행의 값 추출
    LEAD(product_id) OVER(ORDER BY score DESC) AS lead1,
    LEAD(product_id, 2) OVER(ORDER BY score DESC) AS lead2

FROM popular_products
ORDER BY row;

-- 7-5 ORDER BY 구문과 집약 함수를 조합해서 계산

-- 7-6 윈도 프레임 지정별 상품 ID를 집약하는 쿼리

-- 7-7 PARTITION BY와 ORDER BY 조합
SELECT
    category,
    product_id,
    score,

    -- 카테고리별로 점수 순서로 정렬하고 유일한 순위를 붙임
    ROW_NUMBER()
        OVER(PARTITION BY category ORDER BY score DESC)
    AS row,

    -- 카테고리별로 같은 순위를 허가하고 순위를 붙임
    RANK()
        OVER(PARTITION BY category ORDER BY score DESC)
    AS rank,

    -- 카테고리별로 같은 순위가 있을 때
    -- 같은 순위 다음에 있는 순위를 건너 뛰고 순위를 붙임
    DENSE_RANK()
        OVER(PARTITION BY category ORDER BY score DESC)
    AS dense_rank
FROM popular_products
ORDER BY category, row;

-- 7-8 각 카테고리의 상위 n개 추출하기
SELECT *
FROM
    -- 서브 쿼리 내부에서 순위 계산하기
    ( SELECT
        category,
        product_id,
        score,
        -- 카테고리별로 점수 순서로 유일한 순위를 붙임
        ROW_NUMBER()
            OVER(PARTITION BY category ORDER BY score DESC)
        AS rank
      FROM popular_products
    ) AS popular_products_with_rank
-- 외부 쿼리에서 순위 활용해 압축하기
WHERE rank <= 2
ORDER BY category, rank;

-- 7-9 각 카테고리의 최상위 상품 추출
SELECT DISTINCT
    category,
    -- 카테고리별로 최상품 상품 ID 추출
    FIRST_VALUE(product_id)
        OVER(PARTITION BY category ORDER BY score DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    AS product_id
FROM popular_products;


-- 7-10 행으로 지정된 지표 값을 열로 변환하는 쿼리
SELECT
    dt,
    MAX(CASE WHEN indicator = 'impressions' THEN val END) AS impressions
    MAX(CASE WHEN indicator = 'ssessions' THEN val END) AS sessions 
    MAX(CASe WHEN indicator = 'users' THEN val END) AS users
FROM daily_kpi
GROUP BY dt 
ORDER BY dt;


-- 7-11 행을 집약해서 쉼표로 구분된 문자열로 변환하기
SELECT
    purchase_id,

    -- MySQL
    GROUP_CONCAT(product_id) AS product_ids

    -- 상품 ID를 배열에 집약하고 쉼표로 구분된 문자열로 변환하기
    -- PostgreSQL, BigQuery
    string_agg(product_id, ',') AS product_ids

    -- Redshift의 경우는 listagg
    listagg(product_id, ',') AS product_ids

    -- Hive, SparkSQL의 경우 collect_list와 concat_ws
    concat_ws(',', collect_list(product_id)) AS product_ids

    SUM(price) AS amount
FROM purchase_detail_log
GROUP BY purchase_id
ORDER BY purchase_id

-- 7-12 일련 번호를 가진 피벗 테이블을 사용해 행으로 변환하는 쿼리
SELECT 
    q.year,
    CASE
        WHEN p.idx = 1 THEN 'q1'
        WHEN p.idx = 2 THEN 'q2'
        WHEN p.idx = 3 THEN 'q3'
        WHEN p.idx = 4 THEN 'q4'
    END AS quarter,

    CASE
        WHEN p.idx = 1 THEN q.q1
        WHEN p.idx = 2 THEN q.q2
        WHEN p.idx = 3 THEN q.q3
        WHEN p.idx = 4 THEN q.q4
    END AS sales 
FROM
    quarterly_sales AS q 
    CROSS JOIN
    (         SELECT 1 AS idx
    UNION ALL SELECT 2 AS idx
    UNION ALL SELECT 3 AS idx
    UNION ALL SELECT 4 AS idx
    ) AS p 
;