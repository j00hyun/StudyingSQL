-- 해당 타입이 있는지 확인
SUM(type = 'InSchool') > 0 -- 비교식이 TRUE = 1, FALSE = 0으로 계산됨
SUM(CASE WHEN type = 'InSchool' THEN 1 ELSE 0 END) -- 위와 동일

  
-- 특정 날짜에 표기된 만큼 빼거나 더한 날짜 반환
DATE_ADD('2020-02-10', INTERVAL 30 DAY) -- 2020-03-11
DATE_SUB('2020-02-10', INTERVAL 30 DAY) -- 2020-01-11

  
-- 날짜에서 특정 부분만 추출
MONTH('2020-02-10') -- 2
DATE_FORMAT('2018-12-18', '%Y-%m'); -- 2018-12


-- DATE_FORMAT 대신 범위 비교가 인덱스를 타서 더 좋음
WHERE DATE_FORMAT(c.call_date, '%Y-%m') = '2020-04' -- 안좋은 예
WHERE c.call_date >= '2020-04-01' AND c.call_date < '2020-05-01' -- 더 좋음


-- 두 시간 사이의 간격 계산
TIMESTAMPDIFF(SECOND, '2019-09-03 23:00:00', '2019-09-03 23:00:10') -- 10 (초 단위)
TIMESTAMPDIFF(MINUTE, '2019-09-03 23:00:00', '2019-09-03 23:20:10') -- 20 (분 단위)
TIMESTAMPDIFF(HOUR, '2019-09-03 20:00:00', '2019-09-03 23:20:10') -- 3 (시간 단위)
