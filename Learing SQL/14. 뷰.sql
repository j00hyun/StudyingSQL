# 14. 뷰

-- 테이블과 달리 뷰는 데이터 스토리지가 포함되지 않으므로 디스크 공간을 차지하지 않음 


## 뷰를 사용하는 이유

### 1. 데이터 보안

-- 테이블에 있는 개인정보를 사용자에게 숨기기 위해 테이블을 비공개로 유지한 후 중요한 열을 숨긴 뷰를 생성
-- 사용자는 뷰를 통해 사용자 정보에 엑세스 가능

-- customer 테이블 대신 이메일 주소를 부분적으로 숨긴 customer_vw 뷰 정의
CREATE VIEW  customer_vw
	(customer_id,
     first_name,
     last_name,
     email
	)
AS
SELECT
	customer_id,
    first_name,
    last_name,
    -- 처음 두 문자를 *****로 연결한 다음 이메일 주소의 마지막 네 문자와 연결 (ex. MA*****.org)
    concat(substr(email, 1, 2), '*****', substr(email, -4)) email
FROM customer
-- 비활성 고객은 뷰에 포함시키지 않음
WHERE active = 1;


### 2. 데이터 집계

-- 데이터를 사전 집계해 뷰로 저장
-- 사용자가 보기에 사전 집계 데이터가 데이터베이스에 존재하는 것으로 생각

-- 영화 카테고리별 총 판매량 반환
CREATE VIEW sales_by_film_category
AS
SELECT
	c.name AS category,
    SUM(p.amount) AS total_sales
FROM payment AS p
	INNER JOIN rental AS r ON p.rental.id = r.rental_id
    INNER JOIN inventroy AS i ON r.inventory_id = i.inventory_id
    INNER JOIN film AS f ON i.film_id = f.film_id
    INNER JOIN film_category AS fc ON f.film_id = fc.film_id
    INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;


### 3. 복잡성 숨기기

-- 최종 사용자를 복잡성으로부터 보호

-- 영화 카테고리, 영화 출연 배우의 수, 총 재고 수, 영화 대여 횟수 반환
--   사용자는 필요한 데이터를 수집하기 위해 6개의 테이블을 탐색하는 대신 다음 뷰 사용
--   스칼라 서브쿼리 사용 이유: 사용자가 이 뷰를 사용할 때, category_name, num_actors, inventory_cnt, num_rentals 열을 참조하지 않으면 각 서브쿼리가 실행되지 않음
CREATE VIEW film_stats
AS
SELECT f.film_id, f.title, f.description, f.rating,
	(SELECT c.name
	 FROM category c
		INNER JOIN film_category fc
        ON c.category_id = fc.category_id
	 WHERE fc.film_id = f.film_id
	) category_name,
	(SELECT count(*)
     FROM film_actor fa
     WHERE fa.film_id = f.film_id
	) num_actors,
    (SELECT count(*)
     FROM inventory i
     WHERE i.film_id = f.film_id
	) inventory_cnt,
    (SELECT count(*)
     FROM inventory i
		INNER JOIN rental r
        ON i.inventory_id = r.inventory_id
	 WHERE i.film_id = f.film_id
	) num_rentals
FROM film f;


### 4. 분할 데이터의 조인

-- 설계 시 성능을 높이고자 큰 테이블을 여러 조각으로 나누는데, 이 테이블을 조인해 사용자에게 노출

-- 과거 결제 테이블과 현재 결제 테이블을 조인해 모든 결제 데이터가 단일 테이블에 저장된 것처럼 보이도록 함
CREATE VIEW payment_all
	(payment_id,
     customer_id,
     staff_id,
     rental_id,
     amount,
     payment_date,
     last_update
	)
AS
-- 최근 6개월보다 더 과거의 모든 데이터
SELECT payment_id, customer_id, staff_id, rental_id,
	   amount, payment_date, last_update
FROM payment_historic
UNION ALL
-- 최근 6개월의 데이터
SELECT payment_id, customer_id, staff_id, rental_id,
	   amount, payment_date, last_update
FROM payment_current;


## 갱신 가능한 뷰

-- 뷰에 update 또는 insert 문을 사용하여 기본 테이블 수정 가능

### 단순한 뷰 업데이트 

-- 뷰 생성
CREATE VIEW customer_vw
	(customer_id,
     first_name,
     last_name,
     email
	)
AS
SELECT
	customer_id,
    first_name,
    last_name,
    concat(substr(email, 1, 2), '*****', substr(email, -4)) email
FROM customer;

-- 뷰를 사용하여 customer 테이블의 손님 성 변환
UPDATE customer_vw
SET last_name = 'SMITH-ALLEN'
WHERE customer_id = 1;

-- SMITH-ALLEN 출력
SELECT first_name
FROM customer
WHERE customer_id = 1;

-- 에러: email 열은 표현식에서 파생되므로 수정 불가
UPDATE customer_vw
SET email = 'MARY.SMITH-ALLEN@sakilacustomer.org'
WHERE customer_id = 1;

-- 에러: 표현식에서 파생되는 열이 구문에 포함되지 않더라도 데이터 삽입은 불가
INSERT INTO customer_vw
	(customer_id, first_name, last_name)
VALUES (99999, 'ROBERT', 'SIMPSON');


### 복잡한 뷰 업데이트

-- 뷰 생성
CREATE VIEW customer_details
AS
SELECT c.customer_id,
	   c.store_id,
       c.first_name,
       c.last_name,
       c.address_id,
       c.active,
       c.create_date,
       a.address,
       ct.city,
       cn.country,
       a.postal_code
FROM customer c
	INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
    INNER JOIN country cn
    ON ct.country_id = cn.country_id;
    
-- 뷰를 사용하여 customer 테이블에 있는 데이터 업데이트
UPDATE customer_details
SET last_name = 'SMITH-ALLEN', active = 0
WHERE customer_id = 1;

-- 뷰를 사용하여 address 테이블에 있는 데이터 업데이트
UPDATE customer_details
SET address = '999 Mockingbird Lane'
WHERE customer_id = 1;

-- 에러: 하나의 구문으로 두 테이블의 열을 한꺼번에 업데이트할 수 없음
UPDATE customer_details
SET last_name = 'SMITH-ALLEN',
	active = 0,
    address = '999 Mockingbird Lane'
WHERE customer_id = 1;

-- customer 테이블의 열만 채우는 명령문 정상적으로 동작
INSERT INTO customer_details
	(customer_id, store_id, first_name, last_name,
     address_id, active, create_date)
VALUES (9998, 1, 'BRIAN', 'SALAZAR', 5, 1, now());

-- 에러: 서로 다른 두 테이블의 열들을 포함하는 INSERT문은 에러 반환
INSERT INTO customer_details
	(customer_id, store_id, first_name, last_name,
     address_id, active, create_date, address)
VALUES (9999, 2, 'THOMAS', 'BISHOP', 7, 1, now(), '999 Mockingbird Lane');