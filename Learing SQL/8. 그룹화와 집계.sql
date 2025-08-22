# 8. 그룹화와 집계


# 그룹화의 개념
-- 대여 수가 많은 고객부터 각 고객이 대여한 영화 수 반환 (40번 이상 대여한 고객들만)
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
HAVING count(*) >= 40; -- WHERE 절은 집계 함수를 참조할 수 없음 (WHERE 절은 GROUP BY 절보다 먼저 실행)


# 집계 함수
SELECT MAX(amount) max_amt, -- 최댓값
	   MIN(amount) min_amt, -- 최솟값
       AVG(amount) avg_amt, -- 평균값 
       SUM(amount) tot_amt, -- 총합
       COUNT(*)	   num_payments -- 전체 레코드 수
FROM payment;


-- DISTINCT: 고유한 값 계산
SELECT COUNT(customer_id) num_rows, -- 테이블의 모든 행 수 계산
	   COUNT(DISTINCT customer_id) num_customers -- 고유한 값을 가지는 customer_id 수만 계산
FROM payment;


-- 표현식을 사용해 영화를 대여한 최대 일수 계산
SELECT MAX(datediff(return_date, rental_date))
FROM rental;


-- NULL 처리 방법
CREATE TABLE number_tbl (val SMALLINT);
INSERT INTO number_tbl VALUES (1);
INSERT INTO number_tbl VALUES (3);
INSERT INTO number_tbl VALUES (5);
INSERT INTO number_tbl VALUES (NULL);

SELECT COUNT(*) num_rows, -- 4 (NULL 포함한 모든 행 계산)
	   COUNT(val) num_vals, -- 3 (NULL 포함 안함)
       SUM(val) total, -- 9 (NULL 무시)
       MAX(val) max_val, -- 5 (NULL 무시)
       AVG(val) avg_val -- 3 (NULL 무시)
FROM number_tbl;


# 그룹 생성


-- 각 배우가 출연한 영화 등급에 따른 총 영화수
SELECT fa.actor_id, f.rating, count(*)
FROM film_actor fa
	INNER JOIN film f
    ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating -- 2개 이상 열 그룹화
ORDER BY 1, 2;


-- 표현식으로 생성한 값을 기반으로 그룹화
-- 연도별 대여 수 반환
SELECT EXTRACT(YEAR FROM rental_date) year,
	   COUNT(*) how_many
FROM rental
GROUP BY EXTRACT(YEAR FROM rental_date);


-- WITH ROLLUP: GROUP BY 결과로 출력된 항목들의 합계 계산
-- 			    GROUP BY 절의 열 순서에 따라 WITH ROLLUP 결과 달라짐

-- 모든 행의 개수 + GROUP BY actor_id (배우 별 총합) + GROUP BY actor_id, rating
SELECT fa.actor_id, f.rating, count(*)
FROM film_actor fa
	INNER JOIN film f
    ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating WITH ROLLUP
ORDER BY 1, 2;

-- 모든 행의 개수 + GROUP BY rating (등급 별 총합) + GROUP BY rating, actor_id
SELECT f.rating, fa.actor_id, count(*)
FROM film_actor fa
	INNER JOIN film f
    ON fa.film_id = f.film_id
GROUP BY f.rating, fa.actor_id WITH ROLLUP
ORDER BY 1, 2;


# 그룹 필터조건
SELECT fa.actor_id, f.rating, count(*)
FROM film_actor fa
	INNER JOIN film f
    ON fa.film_id = f.film_id
WHERE f.rating IN ('G', 'PG') -- GROUP BY 절이 실행되기전 적용
GROUP BY fa.actor_id, f.rating
HAVING count(*) > 9; -- GROUP BY 절이 실행된 후 적용