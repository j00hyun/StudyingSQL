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

-- 3. Inline 뷰
