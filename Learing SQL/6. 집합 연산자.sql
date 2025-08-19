# 6. 집합 연산자


# 두 데이터셋에 대한 집합 연산을 수행할 때의 규칙
-- 1. 두 데이터셋 모두 같은 수의 열을 가져야 함
-- 2. 두 데이터셋의 각 열의 자료형은 서로 동일해야 함 (또는 서버가 서로 변환할 수 있어야 함)


# union 연산자 (합집합)
-- union: 중복 제거
-- union all: 중복 제거 안함

-- union: 이니셜이 JD인 사람의 이름 반환 (5개 반환)
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION ALL
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

-- union all: 이니셜이 JD인 사람의 이름 반환 (중복 제거 후 4개 반환)
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';


# intersect 연산자 (교집합), except 연산자 (차집합)은 MySQL에 존재하지 않음


# 복합 쿼리의 결과 정렬
--  두 쿼리에서 열의 이름이 다르다면, 첫 번째 쿼리의 열 이름으로 정렬해야 함 
SELECT a.first_name fname, a.last_name lname
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
UNION ALL
SELECT c.first_name, c.last_name
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
ORDER BY lname, fname;