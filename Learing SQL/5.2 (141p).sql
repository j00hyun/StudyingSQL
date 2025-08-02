-- 5.2 테이블 재사용 (141p)

-- Cate Mcqueen과 Cuba Birch가 출연한 영화 제목 출력
SELECT f.title
  FROM film f
INNER JOIN film_actor fa
    ON f.film_id = fa.film_id
INNER JOIN actor a
    ON fa.actor_id = a.actor_id
 WHERE ((a.first_name = 'CATE' AND a.last_name = 'MCQUEEN')
    OR (a.first_name = 'CUBA' AND a.last_name = 'BIRCH'));

-- Cate Mcqueen과 Cuba Birch가 동시에 출연한 영화 제목 출력
SELECT f.title
  FROM film f
INNER JOIN film_actor fa1
    ON f.film_id = fa1.film_id
INNER JOIN actor a1
    ON fa1.actor_id = a1.actor_id
INNER JOIN film_actor fa2
    ON f.film_id = fa2.film_id
INNER JOIN actor a2
    ON fa2.actor_id = a2.actor_id
 WHERE ((a1.first_name = 'CATE' AND a1.last_name = 'MCQUEEN')
   AND (a2.first_name = 'CUBA' AND a2.last_name = 'BIRCH'));
   
-- 영화 - 배우1 - 배우2
-- A   - a    - a
-- A   - a    - b
-- A   - a    - c
-- A   - b    - a
-- A   - b    - b
-- A   - b    - c
-- A   - c    - a
-- A   - c    - b
-- A   - c    - c
-- 1   * 3    * 3 = 총 9개
