-- CASE式の基本

-- 便利だが、冗長な書き方

-- その１

SELECT CASE pref_name
            WHEN '徳島' THEN '四国'
            WHEN '香川' THEN '四国'
            WHEN '愛媛' THEN '四国'
            WHEN '高知' THEN '四国'
            WHEN '福岡' THEN '九州'
            WHEN '福岡' THEN '九州'
            WHEN '佐賀' THEN '九州'
            WHEN '長崎' THEN '九州'
       ELSE 'その他' END AS district,
       SUM(population)
  FROM PopTbl
GROUP BY CASE pref_name
            WHEN '徳島' THEN '四国'
            WHEN '香川' THEN '四国'
            WHEN '愛媛' THEN '四国'
            WHEN '高知' THEN '四国'
            WHEN '福岡' THEN '九州'
            WHEN '福岡' THEN '九州'
            WHEN '佐賀' THEN '九州'
            WHEN '長崎' THEN '九州'
         ELSE 'その他' END;

-- その２

SELECT CASE WHEN population < 100 THEN '01'
            WHEN population >= 100 AND population < 200 THEN '02'
            WHEN population >= 200 AND population < 300 THEN '03'
            WHEN population >= 300 THEN '04'
       ELSE NULL END AS pop_class,
       COUNT(*) AS cnt
    FROM PopTbl
GROUP BY CASE WHEN population < 100 THEN '01'
            WHEN population >= 100 AND population < 200 THEN '02'
            WHEN population >= 200 AND population < 300 THEN '03'
            WHEN population >= 300 THEN '04'
         ELSE NULL END;

-- CASE式を一箇所にまとめる（SELECT句で別名をつかてGROUPBYで参照）

SELECT CASE pref_name
            WHEN '徳島' THEN '四国'
            WHEN '香川' THEN '四国'
            WHEN '愛媛' THEN '四国'
            WHEN '高知' THEN '四国'
            WHEN '福岡' THEN '九州'
            WHEN '福岡' THEN '九州'
            WHEN '佐賀' THEN '九州'
            WHEN '長崎' THEN '九州'
       ELSE 'その他' END AS district,
       SUM(population)
  FROM PopTbl
GROUP BY district;


-- 異なる条件の集計を１つのSQLで行う

-- 普通は以下のように２回SQLを発行する

SELECT pref_name,
       population
    FROM PopTbl2
  WHERE sex = '1';

SELECT pref_name,
       population
    FROM PopTbl2
  WHERE sex = '2';

-- CASE式で一括で取得

SELECT pref_name,
      SUM( CASE WHEN sex = '1' THEN population ELSE 0 END) AS cnt_m,
      SUM( CASE WHEN sex = '2' THEN population ELSE 0 END) AS cnt_f
    FROM PopTbl2
  GROUP BY pref_name;


-- CASEとCHECKと組み合わせ

CREATE TABLE TestSal
( sex CHAR(1),
  salary INTEGER,
    CONSTRAINT check_salary CHECK
    ( CASE WHEN sex = '2'
          THEN CASE WHEN salary <= 20000
                    THEN 1 ELSE 0 END
          ELSE 1 END = 1));