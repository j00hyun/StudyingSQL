-- 1. Where 절에 쓰이는 중첩 서브쿼리

SELECT * FROM HR.EMPLOYEES;
SELECT * FROM HR.DEPARTMENTS;
 
-- loation id가 1800인 부서에서 일하는 employee들 출력
-- 단일 행 서브쿼리: 1개의 결과만 출력하는 서브쿼리
SELECT * FROM HR.EMPLOYEES A
 WHERE A.DEPARTMENT_ID = (SELECT B.DEPARTMENT_ID
                            FROM HR.DEPARTMENTS B
                           WHERE B.LOCATION_ID = 1800);

-- 에러: 단일 행 서브쿼리가 아니기 때문에 =로 처리할 수 없음                           
SELECT * FROM HR.EMPLOYEES A
 WHERE A.DEPARTMENT_ID = (SELECT B.DEPARTMENT_ID
                            FROM HR.DEPARTMENTS B
                           WHERE B.LOCATION_ID = 1700);
                           
-- 단일 행 서브쿼리가 아닌 경우에는 IN을 사용
SELECT * FROM HR.EMPLOYEES A
 WHERE A.DEPARTMENT_ID IN (SELECT B.DEPARTMENT_ID
                            FROM HR.DEPARTMENTS B
                           WHERE B.LOCATION_ID = 1700);

-- JOIN을 이용한 위와 같은 쿼리                  
SELECT *
  FROM HR.EMPLOYEES A,
       HR.DEPARTMENTS B
 WHERE A.DEPARTMENT_ID = B.DEPARTMENT_ID
   AND B.LOCATION_ID = 1700;
   
-- 실행 계획 보기
ALTER SESSION SET STATISTICS_LEVEL = ALL;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null, null, 'ALLSTATS LAST'));

-- 힌트 이용해 강제로 서브쿼리를 타게 만듦 (비추천)
SELECT * FROM HR.EMPLOYEES A
 WHERE A.DEPARTMENT_ID IN (SELECT /*+NO_UNNEST*/
                                 B.DEPARTMENT_ID
                            FROM HR.DEPARTMENTS B
                           WHERE B.LOCATION_ID = 1700);
                       
-- 급여가 가장 높은 사람이랑 가장 적은 사람 정보 출력 
-- 비효율적: 서브 쿼리의 테이블과 메인 쿼리의 테이블이 동일
SELECT A.EMPLOYEE_ID,
       A.FIRST_NAME,
       A.LAST_NAME,
       A.SALARY
  FROM HR.EMPLOYEES A
 WHERE A.SALARY = (SELECT MIN(SALARY) FROM HR.EMPLOYEES)
    OR A.SALARY = (SELECT MAX(SALARY) FROM HR.EMPLOYEES);

-- 위와 같은 쿼리지만 훨씬 효율적
-- 위는 같은 테이블을 3번 접근하지만 밑의 쿼리는 1번만 접근하기 때문
SELECT B.EMPLOYEE_ID,
       B.FIRST_NAME,
       B.LAST_NAME,
       B  .SALARY
  FROM (
            SELECT A.EMPLOYEE_ID,
                   A.FIRST_NAME,
                   A.LAST_NAME,
                   A.SALARY,
                   ROW_NUMBER() OVER(ORDER BY SALARY) MINSAL,
                   ROW_NUMBER() OVER(ORDER BY SALARY DESC) MAXSAL
              FROM HR.EMPLOYEES A
        ) B
  WHERE B.MINSAL = 1 OR B.MAXSAL = 1;
  
-- 2. Scala 서브쿼리

-- 실행 계획: EMPLOYEES 테이블을 풀 스캔 후 DEPARTMENT_ID를 가지고 DEPARTMENTS 테이블에서 PK 인덱스 스캔 진행 
SELECT FIRST_NAME,
       LAST_NAME,
       SALARY,
       (SELECT B.DEPARTMENT_NAME -- 1개의 값만 리턴 가능 (SELECT B.DEPARTMENT_NAME, B.LOCATION_ID 불가)
          FROM HR.DEPARTMENTS B 
         WHERE B.DEPARTMENT_ID = A.DEPARTMENT_ID
           AND ROWNUM = 1) AS DEPT_NM -- ROWNUM = 1 : B에서 DEPARTMENT_ID가 PK가 아닌 경우 오류 발생 가능 -> 1개의 로우만 가져오도록 함
  FROM HR.EMPLOYEES A
 WHERE SALARY > 5000;
 
-- 캐싱 기능 존재
--      스칼라 서브쿼리의 입력값 (DEPARTMENT_ID), 출력값 (DEPARTMENT_NAME) 캐쉬에 저장 (ex. 60: IT, 100: Finance)
--      다음 쿼리가 입력값에 대한 출력값을 요청한다면 쿼리를 수행하지 않고 출력값 리턴
--      지금처럼 DEPARTMENT의 DISTINCT 수가 적다면 캐싱 기능이 큰 효과를 발휘

-- 3. Inline 뷰

--      따로 OBJECT를 생성하지 않는 일회성 VIEW
--      장점: 필요한 데이터만 INLINE VIEW로 생성 후 JOIN하여 속도 개선 가능 

-- 부서별 평균 급여
SELECT A.DEPARTMENT_NAME,
       B.AVG_SAL
  FROM HR.DEPARTMENTS A,
       (SELECT /*+NO_MERGE*/ -- 힌트 사용해 강제로 인라인 뷰 사용 (GROUP BY 후 JOIN)
               DEPARTMENT_ID,
               ROUND(AVG(SALARY), 2) AVG_SAL
          FROM HR.EMPLOYEES
        GROUP BY DEPARTMENT_ID) B
 WHERE A.DEPARTMENT_ID = B.DEPARTMENT_ID;

SELECT A.DEPARTMENT_NAME,
       B.AVG_SAL
  FROM HR.DEPARTMENTS A,
       (SELECT /*+MERGE*/ -- 힌트 사용해 강제로 인라인 뷰 사용하지 않도록 함 (JOIN 후 GROUP BY)
               DEPARTMENT_ID,
               ROUND(AVG(SALARY), 2) AVG_SAL
          FROM HR.EMPLOYEES
        GROUP BY DEPARTMENT_ID) B
 WHERE A.DEPARTMENT_ID = B.DEPARTMENT_ID;
 
 -- 월별 입사한 사람 수
SELECT SUM(M1), SUM(M2), SUM(M3), SUM(M4), SUM(M5), SUM(M6), 
       SUM(M7), SUM(M8), SUM(M9), SUM(M10), SUM(M11), SUM(M12)
  FROM (
        SELECT DECODE(TO_CHAR(HIRE_DATE, 'MM'), '01', COUNT(*), 0) "M1",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '02', COUNT(*), 0) "M2",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '03', COUNT(*), 0) "M3",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '04', COUNT(*), 0) "M4",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '05', COUNT(*), 0) "M5",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '06', COUNT(*), 0) "M6",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '07', COUNT(*), 0) "M7",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '08', COUNT(*), 0) "M8",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '09', COUNT(*), 0) "M9",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '10', COUNT(*), 0) "M10",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '11', COUNT(*), 0) "M11",
               DECODE(TO_CHAR(HIRE_DATE, 'MM'), '12', COUNT(*), 0) "M12"
          FROM HR.EMPLOYEES
        GROUP BY TO_CHAR(HIRE_DATE, 'MM')
  );
        