CREATE TABLE LIKE_TEST (
 
 	NAME	VARCHAR2(20)
 
);
 
INSERT INTO LIKE_TEST VALUES ('정미나');
INSERT INTO LIKE_TEST VALUES ('정지훈');
INSERT INTO LIKE_TEST VALUES ('정재형');
INSERT INTO LIKE_TEST VALUES ('정려원');
INSERT INTO LIKE_TEST VALUES ('정형돈');
INSERT INTO LIKE_TEST VALUES ('장나라');
INSERT INTO LIKE_TEST VALUES ('안영미');
INSERT INTO LIKE_TEST VALUES ('정연'); 
INSERT INTO LIKE_TEST VALUES ('미연');
INSERT INTO LIKE_TEST VALUES ('나나');
INSERT INTO LIKE_TEST VALUES ('크리스탈');
INSERT INTO LIKE_TEST VALUES ('간미연');
 
SELECT * FROM LIKE_TEST;
 
-- % : 글자 0개 이상
SELECT * FROM LIKE_TEST WHERE NAME LIKE '정%'; -- 정으로 시작하는 이름

SELECT * FROM LIKE_TEST WHERE NAME LIKE '%나'; -- 나로 끝나는 이름

SELECT * FROM LIKE_TEST WHERE NAME LIKE '%미%'; -- 미가 포함되는 이름

-- _ : 글자 1개
SELECT * FROM LIKE_TEST WHERE NAME LIKE '정__'; -- 정OO

SELECT * FROM LIKE_TEST WHERE NAME LIKE '정_'; -- 정O

SELECT * FROM LIKE_TEST WHERE NAME LIKE '_나'; -- O나

SELECT * FROM LIKE_TEST WHERE NAME LIKE '__나'; -- OO나

SELECT * FROM LIKE_TEST WHERE NAME LIKE '_미_'; -- O미O

SELECT * FROM LIKE_TEST WHERE NAME LIKE '%리__'; -- 리가 끝에서 3번째에 위치

 





