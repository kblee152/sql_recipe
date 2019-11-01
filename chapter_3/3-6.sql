-- 6-1 문자열 연결하기
SELECT
    user_id,
    CONCAT(pref_name, city_name) AS pref_city
FROM 
    mst_user_location;

-- 6-2 분기별 매출 증감 판정하기
SELECT
    year,
    q1,
    q2,
    -- Q1, Q2 매출 변화 평가
    CASE
        WHEN q1 < q2 THEN '+'
        WHEN q1 = q2 THEN ' '
        ELSE '-'
    END AS judge_q1_q2,
    -- Q1, Q2 매출액 차이 계산
    q2 -q1 AS diff_q2_q1,
    -- Q1, Q2 매출 변화를 1, 0, -1로 표현
    SIGN(q2-q1) AS sign_q2_q1
FROM 
    quarterly_sales
ORDER BY
    year;

-- 6-3 연간 최대/최소 4분기 매출 찾기
SELECT
    year, 
    -- Q1-Q4 최대 매출 구하기
    greatest(q1, q2, q3, q4) AS greatest_sales,
    -- Q1-Q4 최소 매출 구하기
    least(q1, q2, q3, q4) AS least_sales
FROM 
    quarterly_sales
ORDER BY 
    year;

-- 6-4 연간 평균 4분기 매출 계산(단순연산)
SELECT
    year,
    (q1 + q2 + q3 + q4) / 4 AS average
FROM 
    quarterly_sales
ORDER BY
    YEAR;

-- 6-5 연간 평균 4분기 매출 계산(COALESCE)
SELECT
    year,
    (COALESCE(q1, 0) + COALESCE(q2, 0) + COALESCE(q3, 0) + COALESCE(q4, 0)) / 4
    AS average
FROM 
    quarterly_sales
ORDER BY
    year;

-- 6-6 연간 평균 4분기 매출 계산(SIGN을 이용한 NULL 제외)
SELECT
    year,
    (COALESCE(q1, 0) + COALESCE(q2, 0) + COALESCE(q3, 0) + COALESCE(q4, 0)) /
    (SIGN(COALESCE(q1, 0)) + SIGN(COALESCE(q2, 0)) + SIGN(COALESCE(q3, 0)) + SIGN(COALESCE(q4, 0)))
    AS average
FROM
    quarterly_sales
ORDER BY
    year;

-- 6-7 2개의 값 비율 계산(CTR 계산, 정수형 자료 나누기)
SELECT
    dt,
    ad_id,
    -- PostgreSQL의 경우 정수를 나누면 소수점이 잘리므로 명시적으로 자료형 변환
    -- CAST(clicks AS double precision) AS ctr,
    clicks / impressions AS ctr,
    -- 실수를 상수로 앞에 두고 계산하면 암묵적으로 자료형 변환이 일어남
    100.0 * clicks / impressions AS ctr_as_percent
FROM
    advertising_stats
WHERE
    dt = '2017-04-01'
ORDER BY
    dt, ad_id;

-- 6-8 2개의 값 비율 계산(CTR 계산, 0으로 나누는 경우 회피)
SELECT
    dt,
    ad_id,
    -- CASE 식으로 분모가 0일 경우 분기
    CASE
        WHEN impressions > 0 THEN 100.0 * clicks / impressions
        END AS ctr_as_percent_by_case
    
    -- 분모가 0일 경우 NULL로 변환하는 경우
    100.0 * clicks / NULLIF(impressions, 0) AS ctr_as_percent_by_null
FROM
    advertising_stats
ORDER BY
    dt, ad_id;
