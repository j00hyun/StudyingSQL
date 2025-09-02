# 16. 분석 함수

## 데이터 윈도우

-- 분기당 판매값의 최댓값과 전체 기간에 대한 최댓값을 표시
SELECT quarter(payment_date) quarter,
	   monthname(payment_date) month_nm,
       sum(amount) mounthly_sales,
       -- over 절이 비어 있으므로 윈도우에 전체 결과셋이 포함
       max(sum(amount)) over() max_overall_sales,
       -- over 절 내 partiton by 절로 인해 윈도우에 같은 분기 내의 행만 포함
       max(sum(amount)) over (partition by quarter(payment_date)) max_qrtr_sales
FROM payment
WHERE year(payment_date) = 2005
GROUP BY quarter(payment_date), monthname(payment_date);


## 순위

-- row_number(): 동점과 관계없이 각 행애 고유한 순위를 임의로 지정
-- 				 (ex. 4등이 2명이어도 각각 임의로 4등과 5등 부여)
-- rank(): 동점일 경우 동일한 순위를 지정, 동점 이후 순위를 건너뜀
-- 		   (ex. 4등이 2명일 경우 5등 없이 바로 6등으로 이동)
-- dense_rank(): 동점일 경우 동일한 순위를 지정, 동점 이후 순위 그대로 유지
--  			 (ex. 4등이 2명이어도 다음 순위는 5등)

-- 고객별 총 영화 대여 수로 순위 매김
SELECT customer_id, count(*) num_rentals,
	   row_number() over (order by count(*) desc) row_number_rnk,
       rank() over (order by count(*) desc) rank_rnk,
       dense_rank() over (order by count(*) desc) dense_rank_rnk
FROM rental
GROUP BY customer_id
ORDER BY 2 desc;


-- 고객의 영화 대여 수를 월별로 쪼개 월별로 순위 매김
SELECT customer_id,
	   monthname(rental_date) rental_month,
       count(*) num_rentals,
       rank() over (partition by monthname(rental_date)
					order by count(*) desc) rank_rnk
FROM rental
GROUP BY customer_id, monthname(rental_date)
ORDER BY 2, 3 desc;


-- 매월 영화 대여 수 상위 5위의 고객 출력
--   분석 함수는 SELECT 절에서만 사용 가능하므로 필터링 또는 그룹화를 위해 쿼리를 중첩해야 함
SELECT customer_id, rental_month, num_rentals, rank_rnk ranking
FROM 
	(SELECT customer_id,
			monthname(rental_date) rental_month,
            count(*) num_rentals,
            rank() over (partition by monthname(rental_date)
					     order by count(*) desc) rank_rnk
     FROM rental
     GROUP BY customer_id, monthname(rental_date)
	) cust_rankings
WHERE rank_rnk <= 5
ORDER BY rental_month, num_rentals desc, rank_rnk;


## 리포팅 함수

-- 집계 함수인 min, max, avg, sum, count를 over 절과 함께 사용

-- 지불금액이 10달러 이상인 모든 행에 대해 월별 및 전체 총계를 생성
SELECT monthname(payment_date) payment_month,
	   amount,
       sum(amount)
			over (partition by monthname(payment_date)) monthly_total, -- 월별 총계
	   sum(amount) over () grand_total -- 전체 총계
FROM payment
WHERE amount >= 10
ORDER BY 1;


-- 매월 총 지불액의 백분율 계산
SELECT monthname(payment_date) payment_month,
	   sum(amount) month_total,
       -- amount 열을 합산하여 매월 총 지불액을 계산한 다음, 분모로 사용할 월별 총액을 합산하여 매월 총 지급액의 백분율을 계산
       round(sum(amount) / sum(sum(amount)) over() * 100, 2) pct_of_total
FROM payment
GROUP BY monthname(payment_date);


-- 월 총계가 최대, 최소, 중간에 있는지 여부를 판별하기 위해 CASE 표현식 사용
SELECT monthname(payment_date) payment_month,
	   sum(amount) month_total,
       CASE sum(amount)
			WHEN max(sum(amount)) over () THEN 'Highest'
            WHEN min(sum(amount)) over () THEN 'Lowest'
			ELSE 'Middle'
	   END descriptor
FROM payment
GROUP BY monthname(payment_date);


### 윈도우 프레임

-- 데이터 윈도우에 포함할 행을 더 세밀하게 제어

-- 매주 지불액을 합산하여 롤링 합계 계산
--   rows unbounded preceding: 데이터 윈도우를 결과셋의 시작 부분부터 현재 행까지로 정의
SELECT yearweek(payment_date) payment_week,
	   sum(amount) week_total,
       sum(sum(amount))
			over (order by yearweek(payment_date)
				  rows unbounded preceding) rolling_sum
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;


-- 총 지불액의 3주 롤링 평균을 계산
--   rows between 1 preceding and 1 following: 데이터 윈도우를 현재 행, 이전 행, 다음 행으로 구성
--   첫번째 행과 마지막 행은 2개의 행으로 구성 (첫번째 행은 이전 행이 없고 마지막 행은 다음 행이 없기 때문)
SELECT yearweek(payment_date) payment_week,
	   sum(amount) week_total,
       avg(sum(amount))
			over (order by yearweek(payment_date)
				  rows between 1 preceding and 1 following) rolling_3wk_avg
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;


-- 총 지불액의 일주일 롤링 평균 계산 
--   range: 범위로 윈도우 구성 (ex. 2005/8/16을 계산한다면 이전 3일(8/13 - 15)의 행이 없으므로 8/16, 17, 18, 19의 값만 포함됨)
--   rows: 행으로 윈도우 구성 (ex. 이전 3일의 행이 없으므로 10, 11, 12, 16, 17, 18, 19의 값을 포함)
SELECT date(payment_date), sum(amount),
	   avg(sum(amount))
			over (order by date(payment_date)
				  range between interval 3 day preceding
							and interval 3 day following) 7_day_avg
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-01'
GROUP BY date(payment_date)
ORDER BY 1;


### lag() 함수와 lead() 함수

-- lag(, 1): 결과셋에서 이전 행의 열 값을 검색 
-- lead(, 1): 결과셋에서 다음 행의 열 값을 검색
SELECT yearweek(payment_date) payment_week,
	   sum(amount) week_total,
       lag(sum(amount), 1)
			over (order by yearweek(payment_date)) prev_wk_tot,
	   lead(sum(amount), 1)
			over (order by yearweek(payment_date)) next_wk_tot
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;


-- 이전 주와의 백분율 차이 생성
SELECT yearweek(payment_date) payment_week,
	   sum(amount) week_total,
       round((sum(amount) - lag(sum(amount), 1) over (order by yearweek(payment_date)))
			/ lag(sum(amount), 1) over (order by yearweek(payment_date))
            * 100, 1) pct_diff
FROM payment
GROUP BY yearweek(payment_date)
ORDER BY 1;


### group_concat() 함수

-- 영화 제목별로 행을 그룹화하고 정확히 3명의 배우가 나오는 영화만 포함
-- group_concat(): 각 영화에 등장하는 모든 배우의 성을 알파벳 순으로 단일 문자열로 피벗
SELECT f.title,
	   group_concat(a.last_name order by a.last_name separator ', ') actors
FROM actor a
	INNER JOIN film_actor fa
    ON a.actor_id = fa.actor_id
    INNER JOIN film f
    ON fa.film_id = f.film_id
GROUP BY f.title
HAVING count(*) = 3;