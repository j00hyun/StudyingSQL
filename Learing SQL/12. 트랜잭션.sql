# 12. 트랜잭션

-- 여러 SQL 문을 함께 그룹화해서 모든 구문이 성공하거나 성공하지 않도록 하는 장치

-- 모든 과정이 성공하면 commit 명령어를 실행
-- 예상치 못한 일이 발생하면 rollback 명령어를 실행해서 트랜잭션이 시작된 이후의 모든 변경 사항을 취소
-- savepoint를 설정하면, 롤백 시 모든 작업을 취소하지 않고 트랜잭션 내의 특정 위치로 롤백


START TRANSACTION;

UPDATE product
SET date_retired = CURRENT_TIMESTAMP()
WHERE product_cd = 'XYZ';

SAVEPOINT before_close_accounts;

UPDATE account
SET status = 'CLOSED', close_date = CURRENT_TIMESTAMP(),
	last_activity_date = CURRENT_TIMESTAMP()
WHERE product_cd = 'XYZ';

-- 이 롤백문은 항상 실행되며, 결과적으로 XYZ 제품은 폐기되지만 계좌는 그대로 존재하게 됨
ROLLBACK TO SAVEPOINT before_close_accounts;
COMMIT; -- 절대 실행되지 않는 코드