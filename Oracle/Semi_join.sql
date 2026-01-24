-- Semi Join: 겉으로 쿼리에 드러나는 조인이 아닌 내부으로 수행 원리에 의해 생겨나는 조인
-- 특징 1. 서브쿼리가 옵티마이저에 의해서 조인으로 풀린다.
--     2. 조인으로 풀린 서브쿼리 집합은 후행처리가 된다. (Inner 로 처리)
--     3. Outer 테이블에서 Inner 테이블로 조인을 시도했을 때 하나의 로우가 조인에 성공하면 진행을 멈추고 Outer 테이블의 다음 로우를 계속 처리하는 방식이다.

CREATE TABLE PRACTICE.IDOL_GROUP (

    COMPANY         VARCHAR2(50),
    GROUP_NAME      VARCHAR2(30),
    DEBUT_YEAR      NUMBER(4),
    DEBUT_ALBUM     VARCHAR2(50),
    GENDER          VARCHAR2(10)
    
);

INSERT INTO PRACTICE.IDOL_GROUP VALUES ('티오피미디어', '업텐션', 2015, '일급비밀', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('스타크루이엔티', '핫샷', 2014, 'Take A shot', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('브랜뉴뮤직', 'AB6IX', 2019, 'B:Complete', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('플레디스', '뉴이스트', 2012, 'FACE', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('플레이엠엔터테인먼트', '빅톤', 2016, 'Voice To New World', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('YG엔터테인먼트', '아이콘', 2015, 'Welcom Back', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('큐브엔터테인먼트', '펜타콘', 2016, 'Gorilla', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('FNC엔터테인먼트', '엔플라잉', 2015, '기가 막혀', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('JYP엔터테인먼트', 'ITZY', 2019, 'IT''z Different', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('MLD엔터테인먼트', '모모랜드', 2016, 'Welcome to MOMOLAND', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('글로벌에이치미디어', '라붐', 2014, 'PETIT MACARON', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('판타지오', '위키미키', 2017, 'WEME', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('블록베리크리에이티브', '이달의 소녀', 2018, '+ +', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('큐브엔터테인먼트', 'CLC', 2015, '첫사랑', 'girl');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('SM엔터테인먼트', 'NCT', 2016, 'NCT 2018 EMPATHY', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('플레디스', '세븐틴', 2016, '17 캐럿', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('빅히트 엔터테인먼트', 'BTS', 2016, '17 캐럿', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('JYP 엔터테인먼트', '트와이스', 2016, '17 캐럿', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('판타지오', '아스트로', 2016, '17 캐럿', 'boy');
INSERT INTO PRACTICE.IDOL_GROUP VALUES ('큐브 엔터테인먼트', '(여자)아이들', 2016, '17 캐럿', 'boy');


ALTER SESSION SET STATISTICS_LEVEL = ALL;

SELECT * FROM PRACTICE.IDOL_GROUP;

SELECT * FROM PRACTICE.IDOL_MEMBER;

-- OUTER TABLE: IDOL_GROUP, INNER TABLE: IDOL_MEMBER 
SELECT COMPANY, GROUP_NAME
  FROM PRACTICE.IDOL_GROUP A
 WHERE EXISTS (SELECT '1' -- EXISTS 절에서는 해당하는 row가 있는지 없는지만 체크를 하면 되므로 임의의 값을 SELECT
                 FROM PRACTICE.IDOL_MEMBER B 
                WHERE A.GROUP_NAME = B.GROUP_NAME
                  AND B.BIRTHDAY LIKE '1997%');
               
-- 힌트를 사용해 SEMI JOIN 을 강제로 사용하지 않도록 함
SELECT COMPANY, GROUP_NAME
  FROM PRACTICE.IDOL_GROUP A
 WHERE EXISTS (SELECT /*+ NO_UNNEST */'1'
                 FROM PRACTICE.IDOL_MEMBER B 
                WHERE A.GROUP_NAME = B.GROUP_NAME
                  AND B.BIRTHDAY LIKE '1997%');
            
-- ROWNUM <= 1 을 사용해 SEMI JOIN 을 강제로 사용하지 않도록 함       
SELECT COMPANY, GROUP_NAME
  FROM PRACTICE.IDOL_GROUP A
 WHERE EXISTS (SELECT '1'
                 FROM PRACTICE.IDOL_MEMBER B 
                WHERE A.GROUP_NAME = B.GROUP_NAME
                  AND B.BIRTHDAY LIKE '1997%'
                  AND ROWNUM <= 1);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));