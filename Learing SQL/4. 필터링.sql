# 4. 필터링


-- 렌탈 날짜가 2005년 6월 14일 ~ 16일 사이에 속하는 데이터 추출
--    date(rental_date) >= '2005-06-14' AND date(rental_date) <= '2005-06-16' 과 동일
WHERE date(rental_date) BETWEEN '2005-06-14' AND '2005-06-16'


-- FA~~ 부터 FR~~ 사이의 성을 가진 고객 추출
WHERE last_name BETWEEN 'FA' AND 'FR';


-- 'PG-13', 'R', 'NC-17' 등급이 아닌 모든 영화 추출
WHERE rating NOT IN ('PG-13', 'R', 'NC-17')


# 와일드 카드 문자
# 	- : 정확히 한 문자
#	% : 개수에 상관 없이 모든 문자 (0 포함)

-- 두 번째 위치에 A 포함, 네 번째 위치에 T 포함, S로 끝나는 성을 가진 고객 추출 
WHERE last_name LIKE '_A_T%S'


-- 정규 표현식 사용: 이름이 Q 또는 Y로 시작하는 모든 고객 추출
WHERE last_name REGEXP '^[QY]'


-- 렌탈 일자가 NULL인 모든 대여 정보 추출
WHERE return_date IS NULL


-- 렌탈 일자가 존재하는 모든 대여 정보 추출
WHERE rental_date IS NOT NULL

