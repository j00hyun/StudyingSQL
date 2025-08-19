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