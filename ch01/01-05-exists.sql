-- EXISTS述語の使い方

CREATE TABLE Meetings
(meeting CHAR(32) NOT NULL,
 person  CHAR(32) NOT NULL,
 PRIMARY KEY (meeting, person));

INSERT INTO Meetings VALUES('第１回', '伊藤');
INSERT INTO Meetings VALUES('第１回', '水島');
INSERT INTO Meetings VALUES('第１回', '坂東');
INSERT INTO Meetings VALUES('第２回', '伊藤');
INSERT INTO Meetings VALUES('第２回', '宮田');
INSERT INTO Meetings VALUES('第３回', '坂東');
INSERT INTO Meetings VALUES('第３回', '水島');
INSERT INTO Meetings VALUES('第３回', '宮田');

-- 全員が皆勤出席だった際の集合を作成

SELECT DISTINCT M1.meeting, M2.person
FROM Meetings M1 CROSS JOIN Meetings M2;

-- 欠席者だけを求めるクエリ1(存在量化の応用)

SELECT DISTINCT M1.meeting, M2.person
FROM Meetings M1 CROSS JOIN Meetings M2
WHERE NOT EXISTS
(SELECT *
FROM Meetings M3
WHERE M1.meeting = M3.meeting
AND M2.person = M3.person);

-- 欠席者だけを求めるクエリ2(差集合の演算の利用) ※MYSQLではサポートされていない

SELECT DISTINCT M1.meeting, M2.person
FROM Meetings M1 CROSS JOIN Meetings M2
EXCEPT
SELECT meeting, person
FROM Meetings;

/* 全称量化 その１：肯定⇔二重否定の変換に慣れよう */

CREATE TABLE TestScores
(student_id INTEGER,
 subject    VARCHAR(32) ,
 score      INTEGER,
  PRIMARY KEY(student_id, subject));

INSERT INTO TestScores VALUES(100, '算数',100);
INSERT INTO TestScores VALUES(100, '国語',80);
INSERT INTO TestScores VALUES(100, '理科',80);
INSERT INTO TestScores VALUES(200, '算数',80);
INSERT INTO TestScores VALUES(200, '国語',95);
INSERT INTO TestScores VALUES(300, '算数',40);
INSERT INTO TestScores VALUES(300, '国語',90);
INSERT INTO TestScores VALUES(300, '社会',55);
INSERT INTO TestScores VALUES(400, '算数',80);

SELECT DISTINCT student_id
FROM TestScores TS1
WHERE NOT EXISTS
(SELECT *
FROM TestScores TS2
WHERE TS2.student_id = TS1.student_id
AND TS2.score < 50);

SELECT DISTINCT student_id
FROM TestScores TS1
WHERE subject IN ('算数', '国語')
AND NOT EXISTS
(SELECT *
FROM TestScores TS2
WHERE TS2.student_id = Ts1.student_id
AND 1 = 
CASE WHEN subject = '算数' AND score < 80 THEN 1
WHEN subject = '国語' AND score < 50 THEN 1
ELSE 0 END);

SELECT student_id
FROM TestScores TS1
WHERE subject IN ('算数', '国語')
AND NOT EXISTS
(SELECT *
FROM TestScores TS2
WHERE TS2.student_id = Ts1.student_id
AND 1 = 
CASE WHEN subject = '算数' AND score < 80 THEN 1
WHEN subject = '国語' AND score < 50 THEN 1
ELSE 0 END)
GROUP BY student_id
HAVING COUNT(*) = 2;

/* 全称量化 その２：集合VS 述語――凄いのはどっちだ？ */
CREATE TABLE Projects
(project_id VARCHAR(32),
 step_nbr   INTEGER ,
 status     VARCHAR(32),
  PRIMARY KEY(project_id, step_nbr));

INSERT INTO Projects VALUES('AA100', 0, '完了');
INSERT INTO Projects VALUES('AA100', 1, '待機');
INSERT INTO Projects VALUES('AA100', 2, '待機');
INSERT INTO Projects VALUES('B200',  0, '待機');
INSERT INTO Projects VALUES('B200',  1, '待機');
INSERT INTO Projects VALUES('CS300', 0, '完了');
INSERT INTO Projects VALUES('CS300', 1, '完了');
INSERT INTO Projects VALUES('CS300', 2, '待機');
INSERT INTO Projects VALUES('CS300', 3, '待機');
INSERT INTO Projects VALUES('DY400', 0, '完了');
INSERT INTO Projects VALUES('DY400', 1, '完了');
INSERT INTO Projects VALUES('DY400', 2, '完了');

-- 工程1まで完了しているプロジェクトをHAVINGで抽出

SELECT project_id
FROM Projects
GROUP BY project_id
HAVING COUNT(*) = SUM(CASE WHEN step_nbr <= 1 AND status = '完了' THEN 1
                            WHEN step_nbr > 1 AND status = '待機' THEN 1
                            ELSE 0 END);

-- 工程1まで完了しているプロジェクトをNOT EXISTSで抽出

SELECT *
FROM Projects P1
WHERE NOT EXISTS
(SELECT status
FROM Projects P2
WHERE P1.project_id = P2.project_id
AND status <>
CASE WHEN step_nbr <= 1 THEN '完了' ELSE '待機' END);

/* 列に対する量化：オール１の行を探せ */
CREATE TABLE ArrayTbl
 (keycol CHAR(1) PRIMARY KEY,
  col1  INTEGER,
  col2  INTEGER,
  col3  INTEGER,
  col4  INTEGER,
  col5  INTEGER,
  col6  INTEGER,
  col7  INTEGER,
  col8  INTEGER,
  col9  INTEGER,
  col10 INTEGER);

--オールNULL
INSERT INTO ArrayTbl VALUES('A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ArrayTbl VALUES('B', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
--オール1
INSERT INTO ArrayTbl VALUES('C', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
--少なくとも一つは9
INSERT INTO ArrayTbl VALUES('D', NULL, NULL, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ArrayTbl VALUES('E', NULL, 3, NULL, 1, 9, NULL, NULL, 9, NULL, NULL);

-- 全てが1
SELECT *
FROM ArrayTbl
WHERE 1 = ALL (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

-- 1つでも9があれば(ANY)
SELECT *
  FROM ArrayTbl
 WHERE 9 = ANY (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

-- 1つでも9があれば(IN)
SELECT *
  FROM ArrayTbl
 WHERE 9 IN (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10);

--  演習問題5-①：配列テーブル行持ちの場合

/* 5-1：配列テーブル――行持ちの場合 */
CREATE TABLE ArrayTbl2
 (`key`   CHAR(1) NOT NULL,
    i   INTEGER NOT NULL,
  val   INTEGER,
  PRIMARY KEY (`key`, i));

/* AはオールNULL、Bは一つだけ非NULL、Cはオール非NULL */
INSERT INTO ArrayTbl2 VALUES('A', 1, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 2, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 3, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 4, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 5, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 6, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 7, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 8, NULL);
INSERT INTO ArrayTbl2 VALUES('A', 9, NULL);
INSERT INTO ArrayTbl2 VALUES('A',10, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 1, 3);
INSERT INTO ArrayTbl2 VALUES('B', 2, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 3, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 4, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 5, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 6, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 7, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 8, NULL);
INSERT INTO ArrayTbl2 VALUES('B', 9, NULL);
INSERT INTO ArrayTbl2 VALUES('B',10, NULL);
INSERT INTO ArrayTbl2 VALUES('C', 1, 1);
INSERT INTO ArrayTbl2 VALUES('C', 2, 1);
INSERT INTO ArrayTbl2 VALUES('C', 3, 1);
INSERT INTO ArrayTbl2 VALUES('C', 4, 1);
INSERT INTO ArrayTbl2 VALUES('C', 5, 1);
INSERT INTO ArrayTbl2 VALUES('C', 6, 1);
INSERT INTO ArrayTbl2 VALUES('C', 7, 1);
INSERT INTO ArrayTbl2 VALUES('C', 8, 1);
INSERT INTO ArrayTbl2 VALUES('C', 9, 1);
INSERT INTO ArrayTbl2 VALUES('C',10, 1);

-- 正答

SELECT DISTINCT `key`
  FROM ArrayTbl2 A1
 WHERE NOT EXISTS
       (SELECT *
          FROM ArrayTbl2 A2
         WHERE A1.`key` = A2.`key`
           AND (A2.val <> 1 OR A2.val IS NULL));

-- 演習問題5-②：ALL述語による全称量化

-- 工程1 番まで完了のプロジェクトを選択：ALL述語による解答
SELECT *
  FROM Projects P1
 WHERE '○' = ALL
                (SELECT CASE WHEN step_nbr <= 1 
                              AND status = '完了' 
                             THEN '○'
                             WHEN step_nbr > 1 
                              AND status = '待機' 
                             THEN '○'
                        ELSE '×' END
                   FROM Projects P2
                  WHERE P1.project_id = P2. project_id);

-- 演習問題5-③：素数を求める

CREATE TABLE Digits
 (digit INTEGER PRIMARY KEY); 

INSERT INTO Digits VALUES (0);
INSERT INTO Digits VALUES (1);
INSERT INTO Digits VALUES (2);
INSERT INTO Digits VALUES (3);
INSERT INTO Digits VALUES (4);
INSERT INTO Digits VALUES (5);
INSERT INTO Digits VALUES (6);
INSERT INTO Digits VALUES (7);
INSERT INTO Digits VALUES (8);
INSERT INTO Digits VALUES (9);

DROP TABLE Numbers;
CREATE TABLE Numbers
AS
SELECT D1.digit + (D2.digit * 10) AS num
  FROM Digits D1 CROSS JOIN Digits D2
 WHERE D1.digit + (D2.digit * 10) BETWEEN 1 AND 100;

-- 答え： NOT EXISTSで全称量化を表現
SELECT num AS prime
  FROM Numbers Dividend
 WHERE num > 1
   AND NOT EXISTS
        (SELECT *
           FROM Numbers Divisor
          WHERE Divisor.num <= Dividend.num / 2
            AND Divisor.num <> 1
            AND MOD(Dividend.num, Divisor.num) = 0)
 ORDER BY prime;