# 11. 조건식 


## 1. 검색된 case 표현식

-- CASE
-- 	 WHEN C1 THEN E1
-- 	 ...
--   WHEN CN THEN CN
-- 	 ELSE ED (생략 가능)
-- END

-- CASE
-- 	WHEN category.name IN ('Children', 'Family', 'Sports', 'Animation')
-- 		THEN 'All ages'
-- 	WHEN category.name = 'Horror'
-- 		THEN 'Adult'
-- 	WHEN category.name IN ('Music', 'Games')
-- 		THEN 'Teens'
-- 	Else 'Others'
-- END


-- 활성 고객에 대해서만 대여 횟수 반환, 비활성 고객은 0 반환
SELECT c.first_name, c.last_name,
	CASE
		WHEN active = 0 THEN 0
        ELSE
			-- CASE 표현식에 상관 서브쿼리 사용
			(SELECT count(*)
             FROM rental r
             WHERE r.customer_id = c.customer_id)
	END num_rentals
FROM customer c;


## 2. 단순 case 표현식

-- 검색된 case 표현식이 더 유연하므로 검색된 case 표현식 쓰는 것 권장 

-- CASE V0
--   WHEN V1 THEN E1
--   ...
--   WHEN VN THEN EN
--   ELSE ED (생략 가능)
-- END

-- CASE category.name
-- 	WHEN 'Children' THEN 'All Ages'
--     WHEN 'Family' THEN 'All Ages'
--     WHEN 'Sports' THEN 'All Ages'
--     WHEN 'Animation' THEN 'All Ages'
--     WHEN 'Horror' THEN 'Adult'
--     WHEN 'Music' THEN 'Teens'
--     WHEN 'Games' THEN 'Teens'
-- 	ELSE 'Other'
-- END


## case 표현식의 예


### 결과셋 반환

-- 2005년 5월 ~ 8월까지 각 월 당 대여 수를 3개의 열에 반환
SELECT
	SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1
			 ELSE 0 END) May_rentals,
	SUM(CASE WHEN monthname(rental_date) = 'June' THEN 1
			 ELSE 0 END) June_rentals,
	SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1
			 ELSE 0 END) July_rentals
FROM rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01';


### 존재 여부 확인

-- 성 또는 이름이 'S'로 시작하는 배우들이 각각 G, PG, NC-17 등급 영화에 출연한 적 있는지 여부 반환
SELECT a.first_name, a.last_name,
	CASE
		WHEN EXISTS (SELECT 1
					 FROM film_actor fa
						INNER JOIN film f
						ON fa.film_id = f.film_id
					 WHERE fa.actor_id = a.actor_id AND f.rating = 'G') THEN 'Y'
		ELSE 'N'
	END g_actor,
    CASE
		WHEN EXISTS (SELECT 1
					 FROM film_actor fa
						INNER JOIN film f
						ON fa.film_id = f.film_id
					 WHERE fa.actor_id = a.actor_id AND f.rating = 'PG') THEN 'Y'
		ELSE 'N'
	END pg_actor,
    CASE
		WHEN EXISTS (SELECT 1
					 FROM film_actor fa
						INNER JOIN film f
						ON fa.film_id = f.film_id
					 WHERE fa.actor_id = a.actor_id AND f.rating = 'NC-17') THEN 'Y'
		ELSE 'N'
	END nc17_actor
FROM actor a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';


-- 각 영화의 재고 수를 계산해 'Out Of Stock', 'Scarce', 'Available', 'Common' 중 하나를 반환
SELECT f.title,
	CASE (SELECT count(*)
		  FROM inventory i
          WHERE i.film_id = f.film_id)
		WHEN 0 THEN 'Out Of Stock'
        WHEN 1 THEN 'Scarce'
        WHEN 2 THEN 'Scarce'
        WHEN 3 THEN 'Available'
        WHEN 4 THEN 'Available'
        ELSE 'Common'
	END film_availability
FROM film f;


### 0으로 나누기 오류

SELECT 100 / 0; # NULL 반환

-- 각 고객의 평균 지불액 계산
--   신규 고객은 아직 영화를 대여하지 않았을 수 있으므로, 분모가 0이 되지 않도록 CASE 표현식 사용
--   신규 고객인 경우 avg_payment 열에 0을 반환
SELECT c.first_name, c.last_name,
	   sum(p.amount) tot_payment_amt,
       count(p.amount) num_payments,
       sum(p.amount) /
		  CASE WHEN count(p.amount) = 0 THEN 1
			   ELSE count(p.amount)
		  END avg_payment
FROM customer c
	LEFT OUTER JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name;


### 조건부 업데이트

-- 활성 회원 중 지난 90일 동안 영화를 대여하지 않은 고객들의 active 열을 0으로 설정
--   서브쿼리에서 반환한 숫자가 90 이상이면 고객을 비활성 상태로 설정
UPDATE customer
SET active =
	CASE 
		WHEN 90 <= (SELECT datediff(now(), max(rental_date))
					FROM rental r
                    WHERE r.customer_id = customer.customer_id)
			THEN 0
		ELSE 1
	END
WHERE active = 1;


### NULL 값 처리

-- null이 결과 값에 표시되지 않도록 'Unknown' 문자로 대체
SELECT c.first_name, c.last_name,
	CASE
		WHEN a.address IS NULL THEN 'Unknown'
        ELSE a.address
	END address,
    CASE
		WHEN ct.city IS NULL THEN 'Unknown'
        ELSE ct.city
	END city,
    CASE
		WHEN cn.country IS NULL THEN 'Unknown'
        ELSE cn.country
	END country
FROM customer c
	LEFT OUTER JOIN address a
    ON c.address_id = a.address_id
    LEFT OUTER JOIN city ct
    ON a.city_id = ct.city_id
    LEFT OUTER JOIN country cn
    ON ct.country_id = cn.country_id;