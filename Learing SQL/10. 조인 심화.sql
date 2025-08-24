# 10. 조인 심화


## 외부 조인

-- film 테이블에 있는 1000개의 영화 중 42편은 inventory 테이블에 없음에도 1000개의 영화가 모두 반환됨
--   ex) film_id가 14인 영화는 num_copies = 0
SELECT f.film_id, f.title, count(i.inventory_id) num_copies
FROM film f
	LEFT OUTER JOIN inventory i
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;


-- RIGHT OUTER JOIN을 사용하여 위와 동일한 결과 반환
SELECT f.film_id, f.title, count(i.inventory_id) num_copies
FROM inventory i
	RIGHT OUTER JOIN film f
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;


-- 3방향 외부 조인: 한 테이블을 다른 두 테이블과 외부 조인
SELECT f.film_id, f.title, i.inventory_id, r.rental_date
FROM film f
	LEFT OUTER JOIN inventory i
    ON f.film_id = i.film_id
    LEFT OUTER JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE f.film_id BETWEEN 13 AND 15;


## 교차 조인

-- 데카르트 곱 생성 (16개 category 행 X 6개 language 행 반환)
SELECT c.name category_name, l.name language_name
FROM category c
	CROSS JOIN language l;
    
    
-- 2005년의 일별 영화 대여 횟수 반환
SELECT days.dt, COUNT(r.rental_id) num_rentals
FROM rental r
	RIGHT OUTER JOIN -- 외부 조인을 통해 영화 대여 횟수가 0인 날짜도 모두 반환
		-- 교차 조인을 이용해 2005년의 모든 날짜 반환
		(SELECT DATE_ADD('2005-01-01',
				INTERVAL (ones.num + tens.num + hundreds.num) DAY) dt
		FROM
			(SELECT 0 num UNION ALL
			 SELECT 1 num UNION ALL
			 SELECT 2 num UNION ALL
			 SELECT 3 num UNION ALL
			 SELECT 4 num UNION ALL
			 SELECT 5 num UNION ALL
			 SELECT 6 num UNION ALL
			 SELECT 7 num UNION ALL
			 SELECT 8 num UNION ALL
			 SELECT 9 num) ones
			CROSS JOIN
				(SELECT 0 num UNION ALL
				 SELECT 10 num UNION ALL
				 SELECT 20 num UNION ALL
				 SELECT 30 num UNION ALL
				 SELECT 40 num UNION ALL
				 SELECT 50 num UNION ALL
				 SELECT 60 num UNION ALL
				 SELECT 70 num UNION ALL
				 SELECT 80 num UNION ALL
				 SELECT 90 num) tens
			CROSS JOIN 
				(SELECT 0 num UNION ALL
				 SELECT 100 num UNION ALL
				 SELECT 200 num UNION ALL
				 SELECT 300 num) hundreds
		-- 0 ~ 399까지 수를 2005년 1월 1일에 더한 후 2006년을 넘지 않는 날짜들만 필터링
		WHERE DATE_ADD('2005-01-01',
			  INTERVAL (ones.num + tens.num + hundreds.num) DAY) < '2006-01-01'
		) days
	ON days.dt = date(r.rental_date)
GROUP BY days.dt
ORDER BY 1;