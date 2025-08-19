# 5. 다중 테이블 쿼리


# 데카르트 곱 (교차 조인, cross join)
-- 모든 순열 (고객 599명 X 주소 603개 = 361197) 생성
SELECT c.first_name, c.last_name, a.address
FROM customer c JOIN address a;


# 내부 조인 (inner join)
-- customer.address_id 열이 999인데 address.address_id 열의 값이 999인 행이 없다면 해당 고객 행은 결과셋에서 제외
SELECT c.first_name, c.last_name, a.address
FROM customer c INNER JOIN address a
ON c.address_id = a.address_id;

-- 위와 동일한 조인 쿼리 (하지만 위의 방법이 더 명확)
SELECT c.first_name, c.last_name, a.address
FROM customer c, address a
WHERE c.address_id = a.address_id;

-- 3개 테이블 조인 (테이블 순서 관계 없이 항상 동일한 결과 출력)
-- 또한, 옵티마이저가 최적의 조인 순서 결정
SELECT c.first_name, c.last_name, ct.city
FROM customer c
	INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id;

-- 항상 특정 순서로 조인되어야 할 경우, STRAIGHT_JOIN 키워드 사용
-- city: 드라이빙 테이블 / address, customer: 조인 테이블
SELECT STRAIGHT_JOIN c.first_name, c.last_name, ct.city
FROM city ct
	INNER JOIN address a
    ON a.city_id = ct.city_id
    INNER JOIN customer c
    ON c.address_id = a.address_id;
    

# 서브쿼리 사용
-- 캘리포니아에 거주하는 모든 고객 반환
SELECT c.first_name, c.last_name, addr.address, addr.city
FROM customer c
	INNER JOIN 
		-- 캘리포니아에 속하는 모든 address 반환
		(SELECT a.address_id, a.address, ct.city
		FROM address a
			INNER JOIN city ct
			ON a.city_id = ct.city_id
		WHERE a.district = 'California'
		) addr
	ON c.address_id = addr.address_id;
    

# 테이블 재사용
-- Cate Mcqueen과 Cuba Birch가 동시에 출연한 영화 제목 출력
SELECT f.title
FROM film f
	INNER JOIN film_actor fa1
    ON f.film_id = fa1.film_id
    INNER JOIN actor a1
    ON fa1.actor_id = a1.actor_id
    INNER JOIN film_actor fa2
    ON f.film_id = fa2.film_id
    INNER JOIN actor a2
    ON fa2.actor_id = a2.actor_id
WHERE (a1.first_name = 'CATE' AND a1.last_name = 'MCQUEEN')
	AND (a2.first_name = 'CUBA' AND a2.last_name = 'BIRCH');
    
-- 예시
-- 영화 - 배우1 - 배우2
-- A   - a    - a
-- A   - a    - b
-- A   - a    - c
-- A   - b    - a
-- A   - b    - b
-- A   - b    - c
-- A   - c    - a
-- A   - c    - b
-- A   - c    - c
-- 1   * 3    * 3 = 총 9개


# 셀프 조인
-- film 테이블에 해당 영화의 전편(프리퀄)을 나타내는 prequel_film_id 열이 포함되어 있다 가정
-- 전편이 있는 모든 영화 제목과 전편 제목 나열
SELECT f.title, f_prnt.title prequel
FROM film f
	INNER JOIN film f_prnt
    ON f_prnt.film_id = f.prequel_film_id
WHERE f.prequel_film_id IS NOT NULL;