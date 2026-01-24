CREATE TABLE 무한도전 (
    "NAME"      VARCHAR2(30),
    "JOB"       VARCHAR2(30)
);

INSERT INTO 무한도전 VALUES ('유재석', '개그맨');
INSERT INTO 무한도전 VALUES ('박명수', '개그맨');
INSERT INTO 무한도전 VALUES ('정준하', '가수');
INSERT INTO 무한도전 VALUES ('노홍철', '개그맨');
INSERT INTO 무한도전 VALUES ('정형돈', '개그맨');
INSERT INTO 무한도전 VALUES ('하하', '가수');

CREATE TABLE 런닝맨 (
    "NAME"      VARCHAR2(30),
    "JOB"       VARCHAR2(30)
);

INSERT INTO 런닝맨 VALUES ('유재석', '개그맨');
INSERT INTO 런닝맨 VALUES ('지석진', '개그맨');
INSERT INTO 런닝맨 VALUES ('김종국', '가수');
INSERT INTO 런닝맨 VALUES ('전소민', '배우');
INSERT INTO 런닝맨 VALUES ('송지효', '배우');
INSERT INTO 런닝맨 VALUES ('이광수', '배우');
INSERT INTO 런닝맨 VALUES ('하하', '가수');
INSERT INTO 런닝맨 VALUES ('양세찬', '개그맨');

SELECT * FROM 무한도전;
SELECT * FROM 런닝맨;

-- 런닝맨과 무한도전에 모두 출연하는 사람들이 출력됨
-- 실행과정: 런닝맨에서 유재석 데이터를 가져와 무한도전에서 유재석이 있는지 확인 -> 다음 데이터 확인 반복
SELECT * FROM 런닝맨 A WHERE EXISTS (SELECT 'X' FROM 무한도전 B WHERE A.NAME = B.NAME);

-- 런닝맨 출연진들 중에 무한도전 출연진이 아닌 사람들이 출력됨
SELECT * FROM 런닝맨 A WHERE NOT EXISTS (SELECT 1 FROM 무한도전 B WHERE A.NAME = B.NAME);
