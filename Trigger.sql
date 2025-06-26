CREATE TABLE PRACTICE.TRIGGER_TEST (
    ID          NUMBER,
    COL1        VARCHAR2(10),
    COL2        VARCHAR2(10)
);

CREATE TABLE PRACTICE.TRIGGER_TEST_HISTORY (
    ID          NUMBER,
    COL1        VARCHAR2(10),
    COL2        VARCHAR2(10),
    INSERT_DATE DATE
);

-- 트리거를 생성할 테이블
SELECT * FROM PRACTICE.TRIGGER_TEST;

-- 생성된 트리거가 변경할 테이블
SELECT * FROM PRACTICE.TRIGGER_TEST_HISTORY;

-- TRIGGER_TEST 오른쪽 클릭 > Trigger > Create > Timing: After, 모든 이벤트 선택 > 스크립트에 입력 후 컴파일
CREATE OR REPLACE TRIGGER TRIGGER1 
AFTER DELETE OR INSERT OR UPDATE ON PRACTICE.TRIGGER_TEST 
FOR EACH ROW
BEGIN
  -- 데이터 INSERT 시 해당 데이터 값과 현재 시간 HISTORY 테이블에 저장
  IF INSERTING THEN
    INSERT INTO TRIGGER_TEST_HISTORY VALUES (:NEW.ID, :NEW.COL1, :NEW.COL2, SYSDATE);
  END IF;
  
  -- 데이터 UPDATE 시 실행
  IF UPDATING THEN
    -- :OLD.ID : 변경 전 ID 값
  END IF;
  
  -- 데이터 DELETE 시 실행
  IF DELETING THEN
    --
  END IF;
END;

-- 트리거가 잘 작동하는지 테스트 (해당 데이터가 HISTORY 테이블에도 저장됨)
INSERT INTO PRACTICE.TRIGGER_TEST VALUES (1, 'AAA', 'BBB');

-- 트리거는 겉으로 잘 드러나지 않기 때문에 유지보수가 힘드므로 비즈니스 로직에 작성하는 것은 비추 (ex. 고객이 물건을 사면 트리거로 재고 테이블에 해당 물건의 재고를 삭감)
-- 히스토리 이력을 위해 트리거로 작성하는 것이 바람직함
