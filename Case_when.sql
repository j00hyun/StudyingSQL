SELECT * FROM PRACTICE.IDOL_GROUP;

SELECT GROUP_NAME,
       -- CASE WHEN 조건 문 형식 1
       CASE GENDER WHEN 'boy' THEN '남' 
                   WHEN 'girl' THEN '여' 
                   ELSE '혼성' 
                   END GENDER_KO,
       -- CASE WHEN 조건 문 형식 2
       CASE WHEN GENDER = 'boy' THEN '남'
            WHEN GENDER = 'girl' THEN '여'
            ELSE '혼성'
       END GENDER_KO2,
       -- DECODE 문 (조건문이 간단할 때 사용)
       DECODE(GENDER, 'boy', '남', 'girl', '여', '혼성') GENDER_KO3
  FROM PRACTICE.IDOL_GROUP;