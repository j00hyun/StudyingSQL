# 7. 데이터 생성, 조작과 변환


# 문자열
-- CHAR: 고정 길이 문자열 (지정된 크기보다 문자열이 작으면 나머지 공간을 공백으로 채움) - 최대 255자
-- VARCHAR: 가변 길이 문자열 - 최대 65535자
-- TEXT: 매우 큰 가변 길이 문자열 (tinytext, text, mediumtext, longtext) - 최대 4기가바이트
CREATE TABLE string_tbl (
	char_fld	CHAR(30),
    vchar_fld	VARCHAR(30),
    text_fld	TEXT
);


## 문자열 생성
INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This is char data',
		'This is varchar data',
        'This is text data');
        
        
-- ' 또는 "을 포함하는 문자열을 삽입할 경우에는 '를 바로 앞에 붙임
UPDATE string_tbl
SET text_fld = 'This string didn''t work, but it does now';
SELECT text_fld FROM string_tbl; -- This string didn't work, but it does now


-- QUOTE(): 문자열 내의 ' 또는 " 앞에 \ 추가하여 출력 
SELECT QUOTE(text_fld) FROM string_tbl; -- This string didn\'t work, but it does now


-- CHAR(): ASCII 캐릭터셋의 255자 사용 가능
SELECT CHAR(97, 98, 99, 100, 101, 102, 103); -- abcdefg


-- ASCII(): 특정 문자에 대한 ASCII 값 반환
SELECT ASCII('a'); -- 97


## 문자열 조작
INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This string is 28 characters',
		'This string is 28 characters',
        'This string is 28 characters');
        
        
-- LENGTH(): 문자열의 문자 길이 반환
SELECT LENGTH(char_fld) char_length, -- 28 (자동으로 뒤의 공백 제거해 길이 계산)
	   LENGTH(vchar_fld) varchar_length, -- 28
       LENGTH(text_fld) text_length -- 28
FROM string_tbl;


-- POSITION(): 문자열 내에서 부분 문자열의 위치 찾기 (인덱스 1부터 시작)
-- 			   부분 문자열을 찾을 수 없는 경우 0 반환
SELECT POSITION('characters' IN vchar_fld) -- 19
FROM string_tbl;


-- LOCATE(): 부분 문자열을 특정 위치의 문자부터 검색 (검색의 시작 위치를 3번째 매개변수로 선택적 허용)
SELECT LOCATE('is', vchar_fld, 5) -- 13
FROM string_tbl;


-- STRCMP(): 두 개의 문자열을 인수로 받고 다음 중 하나 반환
-- 			 -1: 정렬 순서에서 첫 번째 문자열이 두 번째 문자열 앞에 오는 경우
--       	 0: 문자열이 동일한 경우
--  		 1: 정렬 순서에서 첫 번쨰 문자열이 두 번째 문자열 뒤에 오는 경우
SELECT STRCMP('12345', '12345') 12345_12345, -- 0
	   STRCMP('abcd', 'xyz') abcd_xyz, -- -1
       STRCMP('abcd', 'QRSTUV') abcd_QRSTUV, -- -1
       STRCMP('qrstuv', 'QRSTUV') qrstuv_QRSTUV, -- 0: 대소문자 구분 안함
       STRCMP('12345', 'xyz') 12345_xyz, -- -1
       STRCMP('xyz', 'qrstuv') xyz_qrstuv; -- 1


-- LIKE, REGEXP: 문자열 비교해 1(참), 0(거짓) 산출
-- 이름이 'y'로 끝나면 1 반환, 그렇지 않으면 0 반환
SELECT name, name LIKE '%y' ends_in_y
FROM category;

SELECT name, name REGEXP 'y$' ends_in_y
FROM category;


-- CONCAT(): 여러 문자열을 합쳐 긴 문자열 생성
--           인수로 숫자와 날짜가 들어오면 자동으로 문자열로 변환
-- ex) MARY SMITH has been a customer since 2006-02-14
SELECT CONCAT(first_name, ' ', last_name, 
			  ' has been a customer since ', date(create_date)) cust_narrative
FROM customer;


-- INSERT(): 문자열 중간에 문자열을 추가하거나 대체 (원래 문자열, 시작 위치, 대체할 문자 개수, 대체 문자열)
--           추가: 3번째 인수 값이 0
--           대체: 3번째 인수가 0보다 클 경우
SELECT INSERT('goodbye world', 9, 0, 'cruel ') string; -- 추가: goodbye cruel world

SELECT INSERT('goodbye world', 1, 7, 'hello') string; -- 대체: hello world


-- SUBSTRING(): 문자열에서 부분 문자열 추출
-- 문자열의 9번째 위치에서 5개의 문자 추출 
SELECT SUBSTRING('goodbye cruel world', 9, 5); -- cruel


# 숫자 데이터
-- 부동 소수점 자료형
--  1. float(3, 1), double(3, 1): 총 3자리 (소수 왼쪽 2자리, 소수 오른쪽 1자리)


## 산술 함수
-- MOD(): 나머지 계산
SELECT MOD(10, 4); -- 2
SELECT MOD(22.75, 5); -- 2.75


-- POW(): 거듭 제곱
SELECT POW(2, 8); -- 256


-- AVG(): 평균 계산 (GROUP BY와 함께 사용 가능)
SELECT AVG(num) -- 20
FROM (
	SELECT 10 AS num
	UNION ALL
	SELECT 20
	UNION ALL
	SELECT 30
) AS t;


## 숫자 자릿수 관리


-- CEIL(): 가장 가까운 정수로 올림
-- FLOOR(): 가장 가까운 정수로 내림
SELECT CEIL(72.445), FLOOR(72.445); -- 73, 72


-- ROUND(): 반올림
SELECT ROUND(72.49999), ROUND(72.5), ROUND(72.50001); -- 72, 73, 73
-- 두 번째 인수를 사용해 소수점 1, 2, 3자리로 반올림
SELECT ROUND(72.0909, 1), ROUND(72.0909, 2), ROUND(72.0909, 3); -- 72.1, 72.09, 72.091
-- 두 번째 인수에 음수값을 넣을 수 있음 (소수점 왼쪽에 있는 숫자로 반올림)
SELECT ROUND(17, -1); -- 20


-- TRUNCATE(): 소수점 오른쪽 자리수를 지정해 버림
SELECT TRUNCATE(72.0909, 1), TRUNCATE(72.0909, 2), TRUNCATE(72.0909, 3); -- 72.0, 72.09, 72.090
-- 두 번째 인수에 음수값을 넣을 수 있음
SELECT TRUNCATE(17, -1); -- 10


## Signed 데이터 처리


-- SIGN(): 음수면 -1, 0이면 0, 양수면 1 반환
SELECT SIGN(785.22), SIGN(0), SIGN(-324.22); -- 1, 0, -1


-- ABS(): 절대값
SELECT ABS(785.22), ABS(0), ABS(-324.22); -- 785.22, 0, 324.22


# 시간 데이터
-- 자료형
--  1. date: YYYY-MM-DD (ex. 2019-09-17)
--  2. datetime: YYYY-MM-DD HH:MI:SS (ex. 2019-09-17 15:30:00)
--  3. timestamp: YYYY-MM-DD HH:MI:SS (ex. 2019-09-17 15:30:00)
-- 				  (datetime과 차이점: 테이블에 행이 추가되거나 수정될 때 자동으로 현재 날짜/시간으로 채워짐)
--  4. time: HHH:MI:SS (ex. 300:30:00)


## 시간 데이터 생성
-- 자료형의 구성 요소와 동일한 문자열을 제공하면 서버가 자동으로 변환
UPDATE rental
SET return_date = '2019-09-17 15:30:00' -- 자동으로 datetime으로 파싱
WHERE rental_id = 99999;


-- CAST(): 문자열을 시간 데이터로 변환
SELECT CAST('2019-09-17 15:30:00' AS DATETIME); -- 2019-09-17 15:30:00
SELECT CAST('2019-09-17 15:30:00' AS DATE); -- 2019-09-17
SELECT CAST('2019-09-17 15:30:00' AS TIME); -- 15:30:00


-- STR_TO_DATE(): 다양한 형식의 문자열을 시간 자료형으로 변환
--                두 번째 인자에 첫 번째 인자의 날짜 구성 요소 표시
-- 			      문자열의 내용에 따라 알아서 datetime, date, time 중 하나로 변환
SELECT STR_TO_DATE('September 17, 2019', '%M %d, %Y'); -- 2019-09-17


-- 현재 날짜/시간을 문자열로 반환
SELECT CURRENT_DATE(); -- 2025-08-20
SELECT CURRENT_TIME(); -- 01:39:14
SELECT CURRENT_TIMESTAMP(); -- 2025-08-20 01:39:14


## 시간 데이터 조작 


-- DATE_ADD(): 지정된 날짜에 일정 기간을 더해 다른 날짜 생성
SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY); -- 현재 날짜에 5일 더하기 (2025-08-25)
SELECT DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL '3:27:11' HOUR_SECOND); -- 현재 시간에 3시간 27분 11초 더하기 (2025-08-20 05:10:54)
SELECT DATE_ADD(CURRENT_DATE(), INTERVAL '9-11' YEAR_MONTH); -- 현재 날짜에 9년 11개월 더하기 (2035-07-20)


-- DATE_SUB(): 지정된 날짜에 일정 기간 빼서 다른 날짜 생성
SELECT DATE_SUB(CURRENT_DATE(), INTERVAL 5 DAY); -- 현재 날짜에 5일 빼기 (2025-08-15)


-- LAST_DAY(): 해당 월의 마지막 날 반환
SELECT LAST_DAY('2019-09-17'); -- 2019-09-30


-- DAYNAME(): 특정 날짜에 해당하는 요일 반환
SELECT DAYNAME('2019-09-18'); -- Wednesday


-- EXTRACT(): 원하는 날짜 요소 반환
SELECT EXTRACT(YEAR FROM '2019-09-18 22:19:05'); -- 2019


-- DATEDIFF(): 두 날짜 사이의 전체 일 수 계산
SELECT DATEDIFF('2019-09-03', '2019-06-21'); -- 74
SELECT DATEDIFF('2019-09-03 23:59:59', '2019-06-21 00:00:01'); -- 74 (시간은 무시하고 계산)
SELECT DATEDIFF('2019-06-21', '2019-09-03'); -- -74 (이전 날짜를 먼저 지정하면 음수 반환)


# 변환 함수


-- CAST(): 데이터를 한 유형에서 다른 유형으로 변환
SELECT CAST('1456328' AS SIGNED INTEGER); -- 1456328 (문자열 -> 정수)
