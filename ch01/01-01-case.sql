-- CASE式の基本

CREATE TABLE PopTbl
(pref_name VARCHAR(32) PRIMARY KEY,
 population INTEGER NOT NULL);

INSERT INTO PopTbl VALUES('徳島', 100);
INSERT INTO PopTbl VALUES('香川', 200);
INSERT INTO PopTbl VALUES('愛媛', 150);
INSERT INTO PopTbl VALUES('高知', 200);
INSERT INTO PopTbl VALUES('福岡', 300);
INSERT INTO PopTbl VALUES('佐賀', 100);
INSERT INTO PopTbl VALUES('長崎', 200);
INSERT INTO PopTbl VALUES('東京', 400);
INSERT INTO PopTbl VALUES('群馬', 50);

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

CREATE TABLE PopTbl2
(pref_name VARCHAR(32),
 sex CHAR(1) NOT NULL,
 population INTEGER NOT NULL,
    PRIMARY KEY(pref_name, sex));

INSERT INTO PopTbl2 VALUES('徳島', '1',	60 );
INSERT INTO PopTbl2 VALUES('徳島', '2',	40 );
INSERT INTO PopTbl2 VALUES('香川', '1',	100);
INSERT INTO PopTbl2 VALUES('香川', '2',	100);
INSERT INTO PopTbl2 VALUES('愛媛', '1',	100);
INSERT INTO PopTbl2 VALUES('愛媛', '2',	50 );
INSERT INTO PopTbl2 VALUES('高知', '1',	100);
INSERT INTO PopTbl2 VALUES('高知', '2',	100);
INSERT INTO PopTbl2 VALUES('福岡', '1',	100);
INSERT INTO PopTbl2 VALUES('福岡', '2',	200);
INSERT INTO PopTbl2 VALUES('佐賀', '1',	20 );
INSERT INTO PopTbl2 VALUES('佐賀', '2',	80 );
INSERT INTO PopTbl2 VALUES('長崎', '1',	125);
INSERT INTO PopTbl2 VALUES('長崎', '2',	125);
INSERT INTO PopTbl2 VALUES('東京', '1',	250);
INSERT INTO PopTbl2 VALUES('東京', '2',	150);

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

-- 条件を分岐したUPDATE

CREATE TABLE salary_table
(name VARCHAR(32) PRIMARY KEY,
 salary INTEGER NOT NULL);

INSERT INTO salary_table VALUES ('相田', 300000);
INSERT INTO salary_table VALUES ('神崎', 270000);
INSERT INTO salary_table VALUES ('木村', 220000);
INSERT INTO salary_table VALUES ('斉藤', 290000);

UPDATE salary_table
    SET salary = CASE WHEN salary >= 300000
                      THEN salary * 0.9
                      WHEN salary >= 250000 AND salary < 280000
                      THEN salary * 1.2
                 ELSE salary END;

-- キーの入れ替え

CREATE TABLE SomeTable
(p_key CHAR(1) PRIMARY KEY,
 col_1 INTEGER NOT NULL, 
 col_2 CHAR(2) NOT NULL);

INSERT INTO SomeTable VALUES('a', 1, 'あ');
INSERT INTO SomeTable VALUES('b', 2, 'い');
INSERT INTO SomeTable VALUES('c', 3, 'う');

-- 通常の入れ替え（３回のSQL実行）

UPDATE SomeTable
    SET p_key = 'd'
  WHERE p_key = 'a';

UPDATE SomeTable
    SET p_key = 'a'
  WHERE p_key = 'b';

UPDATE SomeTable
    SET p_key = 'b'
  WHERE p_key = 'd';

-- 効率的な入れ替え

UPDATE SomeTable
  SET p_key = CASE WHEN p_key = 'a'
                   THEN 'b'
                   WHEN p_key = 'b'
                   THEN 'a'
              ELSE p_key END
  WHERE p_key IN ('a', 'b');

/* テーブル同士のマッチング */
CREATE TABLE CourseMaster
(course_id   INTEGER PRIMARY KEY,
 course_name VARCHAR(32) NOT NULL);

INSERT INTO CourseMaster VALUES(1, '経理入門');
INSERT INTO CourseMaster VALUES(2, '財務知識');
INSERT INTO CourseMaster VALUES(3, '簿記検定');
INSERT INTO CourseMaster VALUES(4, '税理士');

CREATE TABLE OpenCourses
(month       INTEGER ,
 course_id   INTEGER ,
    PRIMARY KEY(month, course_id));

INSERT INTO OpenCourses VALUES(201806, 1);
INSERT INTO OpenCourses VALUES(201806, 3);
INSERT INTO OpenCourses VALUES(201806, 4);
INSERT INTO OpenCourses VALUES(201807, 4);
INSERT INTO OpenCourses VALUES(201808, 2);
INSERT INTO OpenCourses VALUES(201808, 4);

-- テーブルのマッチング:IN述語の利用

SELECT course_name,
        CASE WHEN course_id IN
                    (SELECT course_id FROM OpenCourses
                      WHERE month = 201806) THEN 'O'
             ELSE 'X' END AS "6月",
        CASE WHEN course_id IN
                    (SELECT course_id FROM OpenCourses
                      WHERE month = 201807) THEN 'O'
             ELSE 'X' END AS "7月",
        CASE WHEN course_id IN
                    (SELECT course_id FROM OpenCourses
                      WHERE month = 201808) THEN 'O'
             ELSE 'X' END AS "8月"
FROM CourseMaster;

-- テーブルのマッチング:IN述語の利用

SELECT CM.course_name,
      CASE WHEN EXISTS
                  (SELECT course_id FROM OpenCourses OC
                   WHERE month = 201806
                      AND OC.course_id = CM.course_id) THEN 'O'
           ELSE 'X' END AS "6月",
      CASE WHEN EXISTS
                  (SELECT course_id FROM OpenCourses OC
                   WHERE month = 201807
                      AND OC.course_id = CM.course_id) THEN 'O'
           ELSE 'X' END AS "7月",
      CASE WHEN EXISTS
                  (SELECT course_id FROM OpenCourses OC
                   WHERE month = 201808
                      AND OC.course_id = CM.course_id) THEN 'O'
           ELSE 'X' END AS "8月"
FROM CourseMaster CM

/* CASE式の中で集約関数を使う */
CREATE TABLE StudentClub
(std_id  INTEGER,
 club_id INTEGER,
 club_name VARCHAR(32),
 main_club_flg CHAR(1),
 PRIMARY KEY (std_id, club_id));

INSERT INTO StudentClub VALUES(100, 1, '野球',        'Y');
INSERT INTO StudentClub VALUES(100, 2, '吹奏楽',      'N');
INSERT INTO StudentClub VALUES(200, 2, '吹奏楽',      'N');
INSERT INTO StudentClub VALUES(200, 3, 'バドミントン','Y');
INSERT INTO StudentClub VALUES(200, 4, 'サッカー',    'N');
INSERT INTO StudentClub VALUES(300, 4, 'サッカー',    'N');
INSERT INTO StudentClub VALUES(400, 5, '水泳',        'N');
INSERT INTO StudentClub VALUES(500, 6, '囲碁',        'N');

-- 条件1: 1つのクラブに専念している学生を選択

SELECT std_id, MAX(club_id) AS main_club
FROM StudentClub
GROUP BY std_id
HAVING COUNT(*) = 1;

-- 条件2: クラブを掛け持ちしている学生を選択

SELECT std_id, club_id AS main_club
FROM StudentClub
WHERE main_club_flg = 'Y';

-- 効率的なSQL

SELECT std_id,
      CASE WHEN COUNT(*) = 1
          THEN MAX(club_id)
      ELSE MAX(CASE WHEN main_club_flg = 'Y'
                          THEN club_id
                    ELSE NULL END) END AS main_club
FROM StudentClub
GROUP BY std_id;

-- 演習問題1-1

CREATE TABLE Greatests
(`key` VARCHAR(32) PRIMARY KEY,
 x   INTEGER ,
 y   INTEGER ,
 z   INTEGER);

INSERT INTO Greatests
VALUES
('A', 1, 2, 3),
('B', 5, 5, 2),
('C', 4, 7, 1),
('D', 3, 3, 8);

SELECT `key`,
CASE WHEN x > y THEN x ELSE y END AS 'Greatest'
FROM Greatests;

SELECT `key`,
       CASE WHEN CASE WHEN x < y THEN y ELSE x END < z
                      THEN z
                      ELSE CASE WHEN x < y THEN y ELSE x END
        END AS greatest
FROM Greatests;

-- 演習問題1-2

CREATE TABLE PopTbl2
(pref_name VARCHAR(32),
 sex CHAR(1) NOT NULL,
 population INTEGER NOT NULL,
    PRIMARY KEY(pref_name, sex));

INSERT INTO PopTbl2 VALUES('徳島', '1',	60 );
INSERT INTO PopTbl2 VALUES('徳島', '2',	40 );
INSERT INTO PopTbl2 VALUES('香川', '1',	100);
INSERT INTO PopTbl2 VALUES('香川', '2',	100);
INSERT INTO PopTbl2 VALUES('愛媛', '1',	100);
INSERT INTO PopTbl2 VALUES('愛媛', '2',	50 );
INSERT INTO PopTbl2 VALUES('高知', '1',	100);
INSERT INTO PopTbl2 VALUES('高知', '2',	100);
INSERT INTO PopTbl2 VALUES('福岡', '1',	100);
INSERT INTO PopTbl2 VALUES('福岡', '2',	200);
INSERT INTO PopTbl2 VALUES('佐賀', '1',	20 );
INSERT INTO PopTbl2 VALUES('佐賀', '2',	80 );
INSERT INTO PopTbl2 VALUES('長崎', '1',	125);
INSERT INTO PopTbl2 VALUES('長崎', '2',	125);
INSERT INTO PopTbl2 VALUES('東京', '1',	250);
INSERT INTO PopTbl2 VALUES('東京', '2',	150);

SELECT sex,
       SUM(population) AS total,
       SUM(CASE WHEN pref_name = '徳島' 
                THEN population ELSE 0 END) AS tokushima,
       SUM(CASE WHEN pref_name = '香川' 
                THEN population ELSE 0 END) AS kagawa,
       SUM(CASE WHEN pref_name = '愛媛' 
                THEN population ELSE 0 END) AS ehime,
       SUM(CASE WHEN pref_name = '高知' 
                THEN population ELSE 0 END) AS kouchi,
       SUM(CASE WHEN pref_name IN ('徳島', '香川', '愛媛', '高知')
                THEN population ELSE 0 END) AS saikei
  FROM PopTbl2
 GROUP BY sex;

-- 演習問題1-3

SELECT `key`
  FROM Greatests
ORDER BY CASE `key`
          WHEN 'B' THEN 1
          WHEN 'A' THEN 2
          WHEN 'D' THEN 3
          WHEN 'C' THEN 4
          ELSE NULL END;