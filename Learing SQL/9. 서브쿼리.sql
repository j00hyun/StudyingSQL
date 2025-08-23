# 9. 서브쿼리
-- 다른 SQL 구문(포함 구문, containing statement)에 포함된 쿼리
-- 포함 구문 실행이 완료되면 서브쿼리가 반환한 데이터는 폐기됨


# 서브쿼리의 유형

## 1. 비상관(noncorrelated) 서브쿼리

-- 단독으로 실행될 수 있으며 포함 구문에서 아무것도 참조하지 않음

### 1.1 단일 열을 가진 단일 행 (스칼라 서브쿼리)

-- 일반적인 연산자 (=, <>, <, >, <=, >=) 사용
-- 인도에 없는 모든 도시 반환
SELECT city_id, city
FROM city
WHERE country_id <>
	(SELECT country_id FROM country WHERE country = 'India');
    
    
### 1.2 단일 열을 가진 다중 행

#### IN, NOT IN 연산자 사용 

-- 캐나다 또는 멕시코에 있는 모든 도시 반환
SELECT city_id, city
FROM city
WHERE country_id IN
	(SELECT country_id
     FROM country
     WHERE country IN ('Canada', 'Mexico'));

-- 캐나다 또는 멕시코에 없는 모든 도시 반환
SELECT city_id, city
FROM city
WHERE country_id NOT IN
	(SELECT country_id
     FROM country
     WHERE country IN ('Canada', 'Mexico'));
     

#### ALL 연산자 사용

-- 무료 영화를 대여한 적이 없는 모든 고객 반환
SELECT first_name, last_name
FROM customer
WHERE customer_id <> ALL
	(SELECT customer_id
     FROM payment
     WHERE amount = 0);

-- NOT IN 연산자를 사용해 동일한 결과 생성 가능 (더 직관적)
SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN
	(SELECT customer_id
     FROM payment
     WHERE amount = 0);
     
-- 주의: NOT IN 또는 <> ALL 을 사용할 경우 NULL 값이 포함되면 결과를 반환하지 않음
SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN (122, 452, NULL);

-- 총 영화 대여 횟수가 북미 고객의 대여 횟수를 초과하는 모든 고객 반환
-- 한마디로, 북미 고객 중 최다 대여자보다 더 많이 빌린 고객 반환
SELECT customer_id, count(*)
FROM rental
GROUP BY customer_id
HAVING count(*) > ALL
	-- 북미의 모든 고객 별 총 영화 대여 횟수 반환
	(SELECT count(*)
	 FROM rental r
		INNER JOIN customer c
		ON r.customer_id = c.customer_id
		INNER JOIN address a
		ON c.address_id = a.address_id
		INNER JOIN city ct
		ON a.city_id = ct.city_id
		INNER JOIN country co
		ON ct.country_id = co.country_id
	 WHERE co.country IN ('United States', 'Mexico', 'Canada')
	 GROUP BY r.customer_id
	);
    

#### ANY 연산자 사용

-- 이 세 국가 총 영화 대여료보다 어느 한 곳에서라도 더 많은 대여료를 지불한 개인 고객 반환
-- 한마디로, 볼리비아, 파롸과이, 칠레 중 가장 영화 대여료가 작은 나라보다 더 많은 대여료를 지불한 개인 고객 반환
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
HAVING sum(amount) > ANY
	-- 볼리비아, 파라과이, 칠레의 총 영화 대여료 반환
	(SELECT sum(p.amount)
	 FROM payment p
		INNER JOIN customer c
		ON p.customer_id = c.customer_id
		INNER JOIN address a
		ON c.address_id = a.address_id
		INNER JOIN city ct
		ON a.city_id = ct.city_id
		INNER JOIN country co
		ON ct.country_id = co.country_id
	 WHERE co.country IN ('Bolivia', 'Paraguay', 'Chile')
	 GROUP BY co.country
	);
   
   
### 1.3 다중 열 서브쿼리

-- 성이 Monroe인 모든 배우와 그들이 출연한 PG 등급의 모든 영화 반환
-- 서브쿼리에서 반환한 조합들 중 실제 film_actor 테이블에 존재하는 조합만 반환
SELECT actor_id, film_id
FROM film_actor
WHERE (actor_id, film_id) IN
	-- 성이 'MONROE'인 배우들과 'PG'등급의 영화들의 모든 조합 반환
	(SELECT a.actor_id, f.film_id
	 FROM actor a
		CROSS JOIN film f
	 WHERE a.last_name = 'MONROE' AND f.rating = 'PG');


## 2. 상관(correlated) 서브쿼리
-- 포함 구문이 서브쿼리의 하나 이상의 열을 참조하며 의존적
-- 포함 구문이 실행되기 전 서브쿼리가 실행되는 것이 아니라, 각 후보 행(최종 결과에 포함될 수 있는 행)에 대해 한 번씩 실행됨

-- 20편의 영화를 대여한 고객들 반환
SELECT c.first_name, c.last_name
FROM customer c
WHERE 20 =
	-- customer 테이블의 599명의 고객에 대해 한 번씩 서브쿼리를 실행
    -- 서브쿼리가 20을 반환하면 필터조건이 충족되어 해당 행은 결과셋에 추가됨
	(SELECT count(*) 
	 FROM rental r
	 WHERE r.customer_id = c.customer_id); -- 서브쿼리와 포함쿼리를 이어줌
     
     
-- 영화 대여 총 지불액이 180 ~ 240 달러 사이의 모든 고객 반환
SELECT c.first_name, c.last_name
FROM customer c
WHERE
	-- 599번 실행되며 실행될 때마다 지정된 고객의 총 계좌 잔액을 반환
	(SELECT sum(p.amount)
     FROM payment p
     WHERE p.customer_id = c.customer_id)
	BETWEEN 180 AND 240;
    
    
-- EXISTS: 상관 서브쿼리로 조건을 작성할 때 가장 일반적으로 사용됨
-- 	2005년 5월 25일 이전에 영화를 대여한 적이 있는 고객 반환
SELECT c.first_name, c.last_name
FROM customer c
WHERE EXISTS -- 서브쿼리가 하나 이상의 행을 반환했는지 여부만 확인
	(SELECT 1 -- 서브쿼리가 반환한 실제 데이터가 뭔지는 영향이 없음
     FROM rental r
     WHERE r.customer_id = c.customer_id
		AND date(r.rental_date) < '2005-05-25');
        

-- NOT EXISTS
-- 	R 등급 영화에 출연한 적이 없는 배우 반환
SELECT a.first_name, a.last_name
FROM actor a
WHERE NOT EXISTS -- 서브쿼리가 아무런 행도 반환하지 않는지 확인
	(SELECT 1
     FROM film_actor fa
		INNER JOIN film f
        ON f.film_id = fa.film_id
	 WHERE fa.actor_id = a.actor_id -- 서브쿼리와 포함쿼리를 이어줌
		AND f.rating = 'R');
        
        
-- UPDATE 문에서 사용되는 상관 서브쿼리
-- 	customer 테이블의 모든 고객의 last_update 열을 최신 대여 날짜로 수정
UPDATE customer c
SET c.last_update =
	(SELECT max(r.rental_date)
     FROM rental r
     WHERE r.customer_id = c.customer_id)
-- 아래 WHERE절이 없다면 한번도 대여한 적이 없는 고객은 last_update 열이 NULL로 설정됨
WHERE EXISTS -- 고객이 한번이라도 대여한 기록이 있는지 확인
	(SELECT 1
     FROM rental r
     WHERE r.customer_id = c.customer_id);
     

-- DELETE 문에서 사용되는 상관 서브쿼리
-- 	지난 1년 동안 영화를 대여하지 않은 고객을 삭제
DELETE FROM customer
WHERE 365 < ALL
	(SELECT datediff(now(), r.rental_date) day_since_last_rental
     FROM rental r
     WHERE r.customer_id = customer.customer_id);
     

# 서브쿼리를 사용하는 경우

## 데이터 소스로서의 서브쿼리
-- 	FROM 절에 서브쿼리를 포함
-- 	비상관 서브쿼리만 가능

-- 고객의 이름과 영화 대여 횟수, 총 지불액을 반환
SELECT c.first_name, c.last_name,
	   pymnt.num_rentals, pymnt.tot_payments
FROM customer c
	INNER JOIN
		(SELECT customer_id,
				count(*) num_rentals, sum(amount) tot_payments
         FROM payment
         GROUP BY customer_id
		) pymnt
	ON c.customer_id = pymnt.customer_id;
    
    
-- 새 그룹 정의를 사용해 데이터 그룹화
-- 영화 대여에 지불한 금액을 기준으로 고객을 그룹화
SELECT pymnt_grps.name, count(*) num_customers
FROM
	-- 1번째 서브쿼리: 각 고객에 대한 총 영화 대여 횟수와 총 지불액 반환
	(SELECT customer_id,
		    count(*) num_rentals, sum(amount) tot_payments
     FROM payment
     GROUP BY customer_id
	) pymnt
	INNER JOIN
		-- 2번째 서브쿼리: 3개의 고객 그룹 생성
		(SELECT 'Small Fry' name, 0 low_limit, 74.99 high_limit
         UNION ALL
         SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit
         UNION ALL
         SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit
		) pymnt_grps
	ON pymnt.tot_payments
		BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit -- 각 고객이 3 그룹 중 맞는 그룹에 조인 됨
GROUP BY pymnt_grps.name;
        

-- 태스크 지향 서브쿼리
-- 	payment, customer, address, city 테이블을 모두 조인 후 first_name, last_name, city로 그룹화 하는 것 보다
-- 	서브쿼리를 사용해 payment 테이블만 그룹화 하는게 훨씬 보기 좋고 성능이 빠름
SELECT c.first_name, c.last_name, ct.city,
	   pymnt.tot_payments, pymnt.tot_rentals
FROM
	(SELECT customer_id,
		    count(*) tot_rentals, sum(amount) tot_payments
     FROM payment
     GROUP BY customer_id
	) pymnt
    INNER JOIN customer c
    ON pymnt.customer_id = c.customer_id
    INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id;
    

-- 공통 테이블 표현식 (CTE)
-- 	후속 쿼리에서 사용하기 위해 쿼리 결과를 임시적으로 저장하는데에 유용
-- 	성이 S로 시작하는 배우가 출연하는 PG 등급 영화 대여로 발생한 총 수익 반환
WITH actors_s AS -- 서브쿼리 1: 성이 S로 시작하는 모든 배우 반환
	(SELECT actor_id, first_name, last_name
     FROM actor
     WHERE last_name LIKE 'S%'
	),
actors_s_pg AS -- 서브쿼리 2: 서브쿼리 1과 조인해 성이 S로 시작하는 배우들과 출연한 PG 등급 영화 반환
	(SELECT s.actor_id, s.first_name, s.last_name,
		    f.film_id, f.title
     FROM actors_s s
		INNER JOIN film_actor fa
        ON s.actor_id = fa.actor_id
        INNER JOIN film f
        ON f.film_id = fa.film_id
	 WHERE f.rating = 'PG'
	),
actors_s_pg_revenue AS -- 서브쿼리 3: 서브쿼리 2와 조인해 성이 S로 시작하는 배우들이 출연한 PG 등급 영화의 각 대여마다 지불된 금액 반환
	(SELECT spg.first_name, spg.last_name, p.amount
     FROM actors_s_pg spg
		INNER JOIN inventory i
        ON i.film_id = spg.film_id
        INNER JOIN rental r
        ON i.inventory_id = r.inventory_id
        INNER JOIN payment p
        ON r.rental_id = p.rental_id
	) -- WITH 절 끝
SELECT spg_rev.first_name, spg_rev.last_name,
	   sum(spg_rev.amount) tot_revenue
FROM actors_s_pg_revenue spg_rev
GROUP BY spg_rev.first_name, spg_rev.last_name
ORDER BY 3 desc;


## 표현식 생성기로서의 서브쿼리

-- 스칼라 서브쿼리를 SELECT절에 사용
-- 	customer, address, city 테이블을 payment 테이블에 조인하는 대신, 
-- 	상관 스칼라 서브쿼리를 SELECT 절에 사용해 이름, 도시 조회
SELECT
	(SELECT c.first_name
     FROM customer c
     WHERE c.customer_id = p.customer_id
	) first_name,
    (SELECT c.last_name
     FROM customer c
     WHERE c.customer_id = p.customer_id
	) last_name,
    (SELECT ct.city
     FROM customer c
		INNER JOIN address a
        ON c.address_id = a.address_id
        INNER JOIN city ct
        ON a.city_id = ct.city_id
	 WHERE c.customer_id = p.customer_id
	) city,
    sum(p.amount) tot_payments,
    count(*) tot_rentals
FROM payment p
GROUP BY p.customer_id;


-- 스칼라 서브쿼리를 ORDER BY절에 사용
-- 	출연한 영화 수를 기준으로 배우 정렬해 반환
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
ORDER BY
	(SELECT count(*)
     FROM film_actor fa
     WHERE fa.actor_id = a.actor_id) DESC;
     
-- 스칼라 서브쿼리를 INSERT절에 사용
-- 	film_actor 테이블에 새 행을 생성해야 하는데 배우의 이름과 영화 제목만 알고 있을 경우
INSERT INTO film_actor (actor_id, film_id, last_update)
VALUES (
	(SELECT actor_id
     FROM actor
     WHERE first_name = 'JENNIFER' AND last_name = 'DAVIS'),
	(SELECT film_id
     FROM film
     WHERE title = 'ACE GOLDFINGER'),
	now()
);