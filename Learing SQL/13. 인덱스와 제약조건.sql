# 13. 인덱스

## 인덱스 생성 및 제거

-- customer 테이블의 email 열에 idx_email이라는 이름의 인덱스 추가
--   쿼리 옵티마이저는 유용하다고 판단될 경우 인덱스를 자동으로 사용
ALTER TABLE customer
ADD INDEX idx_email (email);


-- 고유 인덱스 생성 (행이 삽입되거나 인덱스 열이 수정될 때 마다 다른 행에 동일한 값이 있는지 확인)
ALTER TABLE customer
ADD UNIQUE idx_email (email);
-- 이미 존재하는 이메일 주소로 새 고객 정보를 추가하면 오류 발생
INSERT INTO customer
	(store_id, first_name, last_name, address_id, active)
VALUES
	(1, 'ALAN', 'KAHN', 'ALAN.KAHN@sakilacustomer.org', 394, 1);


-- 다중 열 인덱스: 두 열을 함께 사용해서 인덱스 생성 (열의 순서 중요)
--   성과 이름, 성만 검색하는 쿼리에 유용하지만 이름만 검색하는 쿼리에는 유용하지 않음 (전화번호부와 유사)
ALTER TABLE customer
ADD INDEX idx_full_name (last_name, first_name);


-- customer 테이블의 모든 인덱스 반환
SHOW INDEX FROM customer;


-- 테이블 생성시 인덱스 함께 생성
CREATE TABLE customer (
	customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    store_id 	TINYINT  UNSIGNED NOT NULL,
    PRIMARY KEY	(customer_id), -- Primary key 열에 PRIMARY라는 이름으로 인덱스를 자동으로 생성
    KEY idx_fk_store_id (store_id)
);


-- 인덱스 제거
ALTER TABLE customer
DROP INDEX idx_email;


## 인덱스 유형

### 1. B-트리 인덱스

-- 디폴트 인덱스
-- 잎 노드(실제 값과 위치 정보 가짐)와 가지 노드(트리 탐색에 이용)를 통해 원하는 값 찾음

-- 예시
--                   [ A - M | N - Z ]
--                    /              \
--                   /                \
--      [ A-C | D-F | G-I | J-M ]     [ N-P | Q-S | T-V | W-Z ]
--         /     |        |     \        /      |       |     \
--        /      |        |      \      /       |       |      \
--  [Barker  [Fleming  [Gooding   [Jameson   [Parker   [Roberts  [Tucker   [Ziegler]
--   Blake]   Fowler]   Grossman   Markham    Portman]   Smith]   Tulman
--                     Hawthorne]   Mason]                       Tyler]


### 2. 비트맵 인덱스

-- 소수의 값만 허용하는 열에 효과적 

--   ex) customer.active 열은 0, 1 값만 가짐
--   0에 대한 비트맵과 1에 대한 비트맵을 유지
--   모든 비활성 고객을 검색하는 쿼리에서 0 비트맵을 통해 원하는 행을 빠르게 검색 


### 3. 텍스트 인덱스

-- 문서가 저장된 경우 해당 문서에서 단어나 구문을 빠르게 검색할 수 있도록 지원


## 인덱스 사용 방법

-- EXPLAIN: 쿼리 실행 계획 확인해 어떤 인덱스 사용했는지 확인
EXPLAIN
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name LIKE 'S%' AND last_name LIKE 'P%'; -- idx_full_name 인덱스 사용


## 인덱스의 단점 

-- 인덱스는 특수한 유형의 테이블 
-- 테이블에서 행을 추가하거나 삭제할 때마다 해당 테이블의 모든 인덱스를 수정해야 함 
-- 그러므로 인덱스가 많을수록 속도가 느려짐 


## 제약조건

-- 제약조건 유형
--   1. 기본 키 제약조건: 테이블 내에서 고유성을 보장하는 열 식별 
--   2. 외래 키 제약조건: 다른 테이블의 기본 키 열에 있는 값만 포함하도록 하나 이상의 열 제한
--   3. 고유 제약조건: 테이블 내에서 고유한 값을 포함하도록 하나 이상의 열 제한
--   4. 체크 제약조건: 열에 허용되는 값 제한

CREATE TABLE customer (
	customer_id	SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    store_id	TINYINT	 UNSIGNED NOT NULL,
    addree_id	SMALLINT UNSIGNED NOT NULL,
    -- 기본 키 제약조건
    PRIMARY KEY (customer_id),
    -- 인덱스 생성
    KEY idx_fk_store_id (store_id),
    KEY idx_fk_address_id (address_id),
    -- 외래 키 제약조건
    --   ON DELETE RESTRICT: 자식 테이블(customer)에서 참조되는 부모 테이블(address)에서 행을 삭제하면 오류 발생 
    --   ON UPDATE CASCADE: 부모 테이블(address)의 기본 키 값에 대한 변경 사항을 자식 테이블(customer)로 전파
    CONSTRAINT fk_customer_address FOREIGN KEY (address_id)
		REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_customer_store FOREIGN KEY (store_id)
		REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- ON DELETE RESTRICT 제약 조건에 의해 오류 발생 (customer 테이블에 address_id = 123인 고객 존재)
DELETE FROM address WHERE address_id = 123;


-- ON UPDATE CASCADE 제약 조건에 의해 customer 테이블에 있는 address_id = 123이 9999로 변경됨
UPDATE address
SET address_id = 9999
WHERE address_id = 123;