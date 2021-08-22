-- 外部結合で行列変換(1)

CREATE TABLE Courses
(name   VARCHAR(32), 
 course VARCHAR(32), 
 PRIMARY KEY(name, course));

INSERT INTO Courses VALUES('赤井', 'SQL入門');
INSERT INTO Courses VALUES('赤井', 'UNIX基礎');
INSERT INTO Courses VALUES('鈴木', 'SQL入門');
INSERT INTO Courses VALUES('工藤', 'SQL入門');
INSERT INTO Courses VALUES('工藤', 'Java中級');
INSERT INTO Courses VALUES('吉田', 'UNIX基礎');
INSERT INTO Courses VALUES('渡辺', 'SQL入門');

-- クロス表を求める水平展開: その１ 外部結合の利用
SELECT C0.name,
CASE WHEN C1.name IS NOT NULL THEN '◯' ELSE NULL END AS 'SQL入門',
CASE WHEN C2.name IS NOT NULL THEN '◯' ELSE NULL END AS 'UNIX基礎',
CASE WHEN C3.name IS NOT NULL THEN '◯' ELSE NULL END AS 'Java中級'
FROM (
  SELECT DISTINCT name FROM Courses
) C0
LEFT OUTER JOIN (
  SELECT name FROM Courses WHERE course = 'SQL入門'
) C1 ON C0.name = C1.name
LEFT OUTER JOIN (
  SELECT name FROM Courses WHERE course = 'UNIX基礎'
) C2 ON C0.name = C2.name
LEFT OUTER JOIN (
  SELECT name FROM Courses WHERE course = 'Java中級'
) C3 ON C0.name = C3.name;

-- クロス表を求める水平展開: その２ スカラサブクエリの利用
SELECT C0.name,(
  SELECT '◯'
  FROM Courses C1
  WHERE course = 'SQL入門'
  AND C1.name = C0.name
) AS "SQL入門",(
  SELECT '◯'
  FROM Courses C2
  WHERE course = 'UNIX基礎'
  AND C2.name = C0.name
) AS "UNIX基礎",(
  SELECT '◯'
  FROM Courses C3
  WHERE course = 'Java中級'
  AND C3.name = C0.name
) AS "Java中級"
FROM (
  SELECT DISTINCT name FROM Courses
) C0;

-- クロス表を求める水平展開: その3 CASE式を入れ子にする
SELECT name,
CASE WHEN SUM(
  CASE WHEN course = 'SQL入門' THEN 1 ELSE NULL END
) = 1 THEN '◯' ELSE NULL END AS "SQL入門",
CASE WHEN SUM(
  CASE WHEN course = 'UNIX基礎' THEN 1 ELSE NULL END
) = 1 THEN '◯' ELSE NULL END AS "UNIX基礎",
CASE WHEN SUM(
  CASE WHEN course = 'Java中級' THEN 1 ELSE NULL END
) = 1 THEN '◯' ELSE NULL END AS "Java中級"
FROM Courses
GROUP BY name;

-- 外部結合で行列変換(2)

CREATE TABLE Personnel
 (employee   varchar(32), 
  child_1    varchar(32), 
  child_2    varchar(32), 
  child_3    varchar(32), 
  PRIMARY KEY(employee));

INSERT INTO Personnel VALUES('赤井', '一郎', '二郎', '三郎');
INSERT INTO Personnel VALUES('工藤', '春子', '夏子', NULL);
INSERT INTO Personnel VALUES('鈴木', '夏子', NULL,   NULL);
INSERT INTO Personnel VALUES('吉田', NULL,   NULL,   NULL);

-- 列から行への変換：UNION ALLの利用
SELECT employee, child_1 AS child FROM Personnel
UNION ALL
SELECT employee, child_2 AS child FROM Personnel
UNION ALL
SELECT employee, child_3 AS child FROM Personnel;

-- 子どもの一覧を保持するビュー
CREATE VIEW Children(child)
AS SELECT child_1 FROM Personnel
UNION
SELECT child_2 FROM Personnel
UNION
SELECT child_3 FROM Personnel;

-- 社員の子供リストを得るSQL
SELECT EMP.employee, Children.child
FROM Personnel EMP
LEFT OUTER JOIN Children
ON Children.child IN (EMP.child_1, EMP.child_2, EMP.child_3);

-- クロス表で入れ子の表側を作る

CREATE TABLE TblSex
(sex_cd   char(1), 
 sex varchar(5), 
 PRIMARY KEY(sex_cd));

CREATE TABLE TblAge 
(age_class char(1), 
 age_range varchar(30), 
 PRIMARY KEY(age_class));

CREATE TABLE TblPop 
(pref_name  varchar(30), 
 age_class  char(1), 
 sex_cd     char(1), 
 population integer, 
 PRIMARY KEY(pref_name, age_class,sex_cd));

INSERT INTO TblSex (sex_cd, sex ) VALUES('m',	'男');
INSERT INTO TblSex (sex_cd, sex ) VALUES('f',	'女');

INSERT INTO TblAge (age_class, age_range ) VALUES('1',	'21〜30歳');
INSERT INTO TblAge (age_class, age_range ) VALUES('2',	'31〜40歳');
INSERT INTO TblAge (age_class, age_range ) VALUES('3',	'41〜50歳');

INSERT INTO TblPop VALUES('秋田', '1', 'm', 400 );
INSERT INTO TblPop VALUES('秋田', '3', 'm', 1000 );
INSERT INTO TblPop VALUES('秋田', '1', 'f', 800 );
INSERT INTO TblPop VALUES('秋田', '3', 'f', 1000 );
INSERT INTO TblPop VALUES('青森', '1', 'm', 700 );
INSERT INTO TblPop VALUES('青森', '1', 'f', 500 );
INSERT INTO TblPop VALUES('青森', '3', 'f', 800 );
INSERT INTO TblPop VALUES('東京', '1', 'm', 900 );
INSERT INTO TblPop VALUES('東京', '1', 'f', 1500 );
INSERT INTO TblPop VALUES('東京', '3', 'f', 1200 );
INSERT INTO TblPop VALUES('千葉', '1', 'm', 900 );
INSERT INTO TblPop VALUES('千葉', '1', 'f', 1000 );
INSERT INTO TblPop VALUES('千葉', '3', 'f', 900 );

-- 外部結合で入れ子の表側を作る：間違ったSQL
SELECT
MASTER1.age_class AS age_class,
MASTER2.sex_cd AS sex_cd,
DATA.pop_tohoku AS pop_tohoku,
DATA.pop_kanto AS pop_kanto
FROM (
  SELECT age_class, sex_cd,
  SUM(
    CASE WHEN pref_name IN ('青森', '秋田') THEN population ELSE NULL END
  ) AS pop_tohoku,
  SUM(
    CASE WHEN pref_name IN ('東京', '千葉') THEN population ELSE NULL END
  ) AS pop_kanto
  FROM TblPop
  GROUP BY age_class, sex_cd
) DATA
RIGHT OUTER JOIN TblAge MASTER1
ON MASTER1.age_class = DATA.age_class
RIGHT OUTER JOIN TblSex MASTER2
ON MASTER2.sex_cd = DATA.sex_cd;

-- 最初の外部結合で止めた場合：年齢階級「２」も結果に現れる
SELECT
MASTER1.age_class AS age_class,
DATA.sex_cd AS sex_cd,
DATA.pop_tohoku AS pop_tohoku,
DATA.pop_kanto AS pop_kanto
FROM (
  SELECT age_class, sex_cd,
  SUM(
    CASE WHEN pref_name IN ('青森', '秋田')
    THEN population ELSE NULL END
  ) AS pop_tohoku,
  SUM(
    CASE WHEN pref_name IN ('東京', '千葉')
    THEN population ELSE NULL END
  ) AS pop_kanto
  FROM TblPop
  GROUP BY 
)

-- 外部結合で入れ子の表側を作る：正しいSQL
SELECT
MASTER.age_class AS age_class,
MASTER.sex_cd AS sex_cd,
DATA.pop_tohoku AS pop_tohoku,
DATA.pop_kanto AS pop_kanto
FROM (
  SELECT age_class, sex_cd
  FROM TblAge CROSS JOIN TblSex
) MASTER
LEFT OUTER JOIN (
  SELECT age_class, sex_cd,
  SUM(
    CASE WHEN pref_name IN ('青森', '秋田')
    THEN population ELSE NULL END
  ) AS pop_tohoku,
  SUM(
    CASE WHEN pref_name IN ('東京', '千葉')
    THEN population ELSE NULL END
  ) AS pop_kanto
  FROM TblPop
  GROUP BY age_class, sex_cd
) DATA
ON MASTER.age_class = DATA.age_class
AND MASTER.sex_cd = DATA.sex_cd;

-- 掛け算としての結合

CREATE TABLE Items
 (item_no INTEGER PRIMARY KEY,
  item    VARCHAR(32) NOT NULL);

INSERT INTO Items VALUES(10, 'FD');
INSERT INTO Items VALUES(20, 'CD-R');
INSERT INTO Items VALUES(30, 'MO');
INSERT INTO Items VALUES(40, 'DVD');

CREATE TABLE SalesHistory
 (sale_date DATE NOT NULL,
  item_no   INTEGER NOT NULL,
  quantity  INTEGER NOT NULL,
  PRIMARY KEY(sale_date, item_no));

INSERT INTO SalesHistory VALUES('2018-10-01',  10,  4);
INSERT INTO SalesHistory VALUES('2018-10-01',  20, 10);
INSERT INTO SalesHistory VALUES('2018-10-01',  30,  3);
INSERT INTO SalesHistory VALUES('2018-10-03',  10, 32);
INSERT INTO SalesHistory VALUES('2018-10-03',  30, 12);
INSERT INTO SalesHistory VALUES('2018-10-04',  20, 22);
INSERT INTO SalesHistory VALUES('2018-10-04',  30,  7);

-- 答え：その１　結合の前に集約することで１対１の関係を作る
SELECT I.item_no, SH.total_qty
FROM Items I LEFT OUTER JOIN (
  SELECT item_no, SUM(quantity) AS total_qty
  FROM SalesHistory
  GROUP BY item_no
) SH
ON I.item_no = SH.item_no;

-- 答え：その２　集約の前に１対多の結合を行う
SELECT I.item_no, SUM(SH.quantity) AS total_qty
FROM Items I LEFT OUTER JOIN SalesHistory SH
ON I.item_no = SH.item_no
GROUP BY I.item_no;