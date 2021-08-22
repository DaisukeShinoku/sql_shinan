-- テーブル同士のコンペア

CREATE TABLE Tbl_A
 (keycol  CHAR(1) PRIMARY KEY,
  col_1   INTEGER , 
  col_2   INTEGER, 
  col_3   INTEGER);

CREATE TABLE Tbl_B
 (keycol  CHAR(1) PRIMARY KEY,
  col_1   INTEGER, 
  col_2   INTEGER, 
  col_3   INTEGER);

/* 等しいテーブル同士のケース */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', 2, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', 5, 1, 6);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', 2, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 9);
INSERT INTO Tbl_B VALUES('C', 5, 1, 6);


/* 「B」の行が相違するケース */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', 2, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', 5, 1, 6);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', 2, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 8);
INSERT INTO Tbl_B VALUES('C', 5, 1, 6);


/* NULLを含むケース（等しい） */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', NULL, NULL, NULL);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 9);
INSERT INTO Tbl_B VALUES('C', NULL, NULL, NULL);


/* NULLを含むケース（「C」の行が異なる） */
DELETE FROM Tbl_A;
INSERT INTO Tbl_A VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_A VALUES('B', 0, 7, 9);
INSERT INTO Tbl_A VALUES('C', NULL, NULL, NULL);

DELETE FROM Tbl_B;
INSERT INTO Tbl_B VALUES('A', NULL, 3, 4);
INSERT INTO Tbl_B VALUES('B', 0, 7, 9);
INSERT INTO Tbl_B VALUES('C', 0, NULL, NULL);

-- UNIONして列数を数える
SELECT COUNT(*) AS row_cnt
FROM (
  SELECT *
  FROM Tbl_A
  UNION
  SELECT *
  FROM Tbl_B
) TMP;

-- 2つのテーブルが等しいかどうかを返す
SELECT CASE WHEN COUNT(*) = 0
THEN '等しい'
ELSE '異なる' END AS result
FROM (
  (
    SELECT * FROM Tbl_A
    UNION
    SELECT * FROM Tbl_B
  ) EXCEPT (
    SELECT * FROM Tbl_A
    INTERSECT
    SELECT * FROM Tbl_B
  )
) TMP;

-- テーブル同士のdiff
(
  SELECT * FROM Tbl_A
  EXCEPT
  SELECT * FROM Tbl_B
) UNION ALL (
  SELECT * FROM Tbl_B
  EXCEPT
  SELECT * FROM Tbl_A
);

/* 差集合で関係除算を表現する */
CREATE TABLE Skills 
(skill VARCHAR(32),
 PRIMARY KEY(skill));

CREATE TABLE EmpSkills 
(emp   VARCHAR(32), 
 skill VARCHAR(32),
 PRIMARY KEY(emp, skill));

INSERT INTO Skills VALUES('Oracle');
INSERT INTO Skills VALUES('UNIX');
INSERT INTO Skills VALUES('Java');

INSERT INTO EmpSkills VALUES('相田', 'Oracle');
INSERT INTO EmpSkills VALUES('相田', 'UNIX');
INSERT INTO EmpSkills VALUES('相田', 'Java');
INSERT INTO EmpSkills VALUES('相田', 'C#');
INSERT INTO EmpSkills VALUES('神崎', 'Oracle');
INSERT INTO EmpSkills VALUES('神崎', 'UNIX');
INSERT INTO EmpSkills VALUES('神崎', 'Java');
INSERT INTO EmpSkills VALUES('平井', 'UNIX');
INSERT INTO EmpSkills VALUES('平井', 'Oracle');
INSERT INTO EmpSkills VALUES('平井', 'PHP');
INSERT INTO EmpSkills VALUES('平井', 'Perl');
INSERT INTO EmpSkills VALUES('平井', 'C++');
INSERT INTO EmpSkills VALUES('若田部', 'Perl');
INSERT INTO EmpSkills VALUES('渡来', 'Oracle');

-- 差集合で関係徐算を表現
SELECT DISTINCT emp
FROM EmpSkills ES1
WHERE NOT EXISTS
(
  SELECT skill
  FROM Skills
  EXCEPT
  SELECT skill
  FROM EmpSkills ES2
  WHERE ES1.tmp = ES2.tmp
);

-- 新しい部分集合を見つける
CREATE TABLE SupParts
(sup  CHAR(32) NOT NULL,
 part CHAR(32) NOT NULL,
 PRIMARY KEY(sup, part));

INSERT INTO SupParts VALUES('A',  'ボルト');
INSERT INTO SupParts VALUES('A',  'ナット');
INSERT INTO SupParts VALUES('A',  'パイプ');
INSERT INTO SupParts VALUES('B',  'ボルト');
INSERT INTO SupParts VALUES('B',  'パイプ');
INSERT INTO SupParts VALUES('C',  'ボルト');
INSERT INTO SupParts VALUES('C',  'ナット');
INSERT INTO SupParts VALUES('C',  'パイプ');
INSERT INTO SupParts VALUES('D',  'ボルト');
INSERT INTO SupParts VALUES('D',  'パイプ');
INSERT INTO SupParts VALUES('E',  'ヒューズ');
INSERT INTO SupParts VALUES('E',  'ナット');
INSERT INTO SupParts VALUES('E',  'パイプ');
INSERT INTO SupParts VALUES('F',  'ヒューズ');

-- 業種の組み合わせを作る
SELECT SP1.sup AS s1, SP2.sup AS s2
FROM SupParts SP1, SupParts SP2
WHERE SP1.sup < SP2.sup
GROUP BY SP1.sup, SP2.sup;

/*
上記に加え
条件１ どちらの業種も同じ種類の部品を扱っている
条件２ 同数の部品を扱っている
を追加
*/

SELECT SP1.sup AS s1, SP2.sup AS s2
FROM SupParts SP1, SupParts SP2
WHERE SP1.sup < SP2.sup
AND SP1.part= SP2.part
GROUP BY SP1.sup, SP2.sup
HAVING COUNT(*) = (
  SELECT COUNT(*)
  FROM SupParts SP3
  WHERE SP3.sup = SP1.sup
)
AND COUNT(*) = (
  SELECT COUNT(*)
  FROM SupParts SP4
  WHERE SP4.sup = SP2.sup
);