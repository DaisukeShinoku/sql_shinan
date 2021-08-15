-- HAVING句の力

/* データの歯抜けを探す */
CREATE TABLE SeqTbl
(seq  INTEGER PRIMARY KEY,
 name VARCHAR(16) NOT NULL);

INSERT INTO SeqTbl VALUES(1,	'ディック');
INSERT INTO SeqTbl VALUES(2,	'アン');
INSERT INTO SeqTbl VALUES(3,	'ライル');
INSERT INTO SeqTbl VALUES(5,	'カー');
INSERT INTO SeqTbl VALUES(6,	'マリー');
INSERT INTO SeqTbl VALUES(8,	'ベン');

-- 歯抜けの判定
SELECT '歯抜けアリ' AS gap
FROM SeqTbl
HAVING COUNT(*) <> MAX(seq);

-- 歯抜けの最小値
SELECT MIN(seq + 1) AS gap
FROM SeqTbl
WHERE (seq + 1) NOT IN (SELECT seq FROM SeqTbl);

-- HAVING句でサブクエリ

CREATE TABLE Graduates
(name   VARCHAR(16) PRIMARY KEY,
 income INTEGER NOT NULL);

INSERT INTO Graduates VALUES('サンプソン', 400000);
INSERT INTO Graduates VALUES('マイク',     30000);
INSERT INTO Graduates VALUES('ホワイト',   20000);
INSERT INTO Graduates VALUES('アーノルド', 20000);
INSERT INTO Graduates VALUES('スミス',     20000);
INSERT INTO Graduates VALUES('ロレンス',   15000);
INSERT INTO Graduates VALUES('ハドソン',   15000);
INSERT INTO Graduates VALUES('ケント',     10000);
INSERT INTO Graduates VALUES('ベッカー',   10000);
INSERT INTO Graduates VALUES('スコット',   10000);

-- 最頻値を求めるSQL(ALL述語)

SELECT income, COUNT(*) AS cnt
FROM Graduates
GROUP BY income
HAVING COUNT(*) >= ALL (
  SELECT COUNT(*)
  FROM Graduates
  GROUP BY income
);

-- 最頻値を求めるSQL(極値関数)

SELECT income, COUNT(*) AS cnt
FROM Graduates
GROUP BY income
HAVING COUNT(*) >= (
  SELECT MAX(cnt)
  FROM (
    SELECT COUNT(*) AS cnt
    FROM Graduates
    GROUP BY income
  ) TMP
);

/* NULL を含まない集合を探す */
CREATE TABLE Students
(student_id   INTEGER PRIMARY KEY,
 dpt          VARCHAR(16) NOT NULL,
 sbmt_date    DATE);

INSERT INTO Students VALUES(100,  '理学部',   '2018-10-10');
INSERT INTO Students VALUES(101,  '理学部',   '2018-09-22');
INSERT INTO Students VALUES(102,  '文学部',   NULL);
INSERT INTO Students VALUES(103,  '文学部',   '2018-09-10');
INSERT INTO Students VALUES(200,  '文学部',   '2018-09-22');
INSERT INTO Students VALUES(201,  '工学部',   NULL);
INSERT INTO Students VALUES(202,  '経済学部', '2018-09-25');

-- 提出日にNULLを含まない学部を選択する(COUNT関数の利用)

SELECT dpt
FROM Students
GROUP BY dpt
HAVING COUNT(*) = COUNT(sbmt_date);

-- 提出日にNULLを含まない学部を選択する(CASE式の利用)

SELECT dpt
FROM Students
GROUP BY dpt
HAVING COUNT(*) = SUM(
  CASE WHEN sbmt_date IS NOT NULL
  THEN 1 ELSE 0 END
);

/* 特製関数の応用 */

DROP TABLE TestResults;

CREATE TABLE TestResults
(student_id CHAR(12) NOT NULL PRIMARY KEY,
 class   CHAR(1)  NOT NULL,
 sex     CHAR(1)  NOT NULL,
 score   INTEGER  NOT NULL);

INSERT INTO TestResults VALUES('001', 'A', '男', 100);
INSERT INTO TestResults VALUES('002', 'A', '女', 100);
INSERT INTO TestResults VALUES('003', 'A', '女',  49);
INSERT INTO TestResults VALUES('004', 'A', '男',  30);
INSERT INTO TestResults VALUES('005', 'B', '女', 100);
INSERT INTO TestResults VALUES('006', 'B', '男',  92);
INSERT INTO TestResults VALUES('007', 'B', '男',  80);
INSERT INTO TestResults VALUES('008', 'B', '男',  80);
INSERT INTO TestResults VALUES('009', 'B', '女',  10);
INSERT INTO TestResults VALUES('010', 'C', '男',  92);
INSERT INTO TestResults VALUES('011', 'C', '男',  80);
INSERT INTO TestResults VALUES('012', 'C', '女',  21);
INSERT INTO TestResults VALUES('013', 'D', '女', 100);
INSERT INTO TestResults VALUES('014', 'D', '女',   0);
INSERT INTO TestResults VALUES('015', 'D', '女',   0);

-- 75%以上の生徒が80点以上のクラス

SELECT class
FROM TestResults
GROUP BY class
HAVING COUNT(*) * 0.75 <=
SUM(
  CASE WHEN score >= 80
  THEN 1
  ELSE 0 END
);

-- 50点以上を取った生徒のうち男子の数が女子の数より多いクラス

SELECT class
FROM TestResults
GROUP BY class
HAVING
SUM(
  CASE WHEN score >= 50 AND sex = '男'
  THEN 1
  ELSE 0 END
) >
SUM(
  CASE WHEN score >= 50 AND sex = '女'
  THEN 1
  ELSE 0 END
);

-- 女子の平均点が男子の平均点より高いクラス(空集合に対する平均を0で返す)

SELECT class
FROM TestResults
GROUP BY class
HAVING
AVG(
  CASE WHEN sex = '男' THEN score ELSE 0 END
) <
AVG(
  CASE WHEN sex = '女' THEN score ELSE 0 END
);

-- 女子の平均点が男子の平均点より高いクラス(空集合に対する平均をNULLで返す)

SELECT class
FROM TestResults
GROUP BY class
HAVING
AVG(
  CASE WHEN sex = '男' THEN score ELSE NULL END
) <
AVG(
  CASE WHEN sex = '女' THEN score ELSE NULL END
);

/* HAVING句で全称量化 */

CREATE TABLE Teams
(member  CHAR(12) NOT NULL PRIMARY KEY,
 team_id INTEGER  NOT NULL,
 status  CHAR(8)  NOT NULL);

INSERT INTO Teams VALUES('ジョー',   1, '待機');
INSERT INTO Teams VALUES('ケン',     1, '出動中');
INSERT INTO Teams VALUES('ミック',   1, '待機');
INSERT INTO Teams VALUES('カレン',   2, '出動中');
INSERT INTO Teams VALUES('キース',   2, '休暇');
INSERT INTO Teams VALUES('ジャン',   3, '待機');
INSERT INTO Teams VALUES('ハート',   3, '待機');
INSERT INTO Teams VALUES('ディック', 3, '待機');
INSERT INTO Teams VALUES('ベス',     4, '待機');
INSERT INTO Teams VALUES('アレン',   5, '出動中');
INSERT INTO Teams VALUES('ロバート', 5, '休暇');
INSERT INTO Teams VALUES('ケーガン', 5, '待機');

-- 全称文を述語で表現する

SELECT team_id, member
FROM Teams T1
WHERE NOT EXISTS (
  SELECT *
  FROM Teams T2
  WHERE T1.team_id = T2.team_id
  AND status <> '待機'
);

-- 全称文を集合で表現する1

SELECT team_id
FROM Teams
GROUP BY team_id
HAVING
COUNT(*) = SUM(
  CASE WHEN status = '待機' THEN 1 ELSE 0 END
);

-- 全称文を集合で表現する2

SELECT team_id
FROM Teams
GROUP BY team_id
HAVING MAX(status) = '待機'
AND MIN(status) = '待機';

-- 総員スタンバイかどうかチームごとに一覧表示

SELECT team_id,
CASE WHEN MAX(status) = '待機' AND MIN(status) = '待機'
THEN '総員スタンバイ'
ELSE 'メンバーが足りません！' END AS status
FROM Teams GROUP BY team_id ORDER BY team_id;

/* 一意集合と多重集合 */

CREATE TABLE Materials
(center         CHAR(12) NOT NULL,
 receive_date   DATE     NOT NULL,
 material       CHAR(12) NOT NULL,
 PRIMARY KEY(center, receive_date));

INSERT INTO Materials VALUES('東京'	,'2018-4-01',	'錫');
INSERT INTO Materials VALUES('東京'	,'2018-4-12',	'亜鉛');
INSERT INTO Materials VALUES('東京'	,'2018-5-17',	'アルミニウム');
INSERT INTO Materials VALUES('東京'	,'2018-5-20',	'亜鉛');
INSERT INTO Materials VALUES('大阪'	,'2018-4-20',	'銅');
INSERT INTO Materials VALUES('大阪'	,'2018-4-22',	'ニッケル');
INSERT INTO Materials VALUES('大阪'	,'2018-4-29',	'鉛');
INSERT INTO Materials VALUES('名古屋',	'2018-3-15',	'チタン');
INSERT INTO Materials VALUES('名古屋',	'2018-4-01',	'炭素鋼');
INSERT INTO Materials VALUES('名古屋',	'2018-4-24',	'炭素鋼');
INSERT INTO Materials VALUES('名古屋',	'2018-5-02',	'マグネシウム');
INSERT INTO Materials VALUES('名古屋',	'2018-5-10',	'チタン');
INSERT INTO Materials VALUES('福岡'	,'2018-5-10',	'亜鉛');
INSERT INTO Materials VALUES('福岡'	,'2018-5-28',	'錫');

-- 資材のダブっている拠点を選択

SELECT center
FROM Materials
GROUP BY center
HAVING COUNT(material) <> COUNT(DISTINCT material);

-- 拠点ごとに一覧表示

SELECT center,
CASE WHEN COUNT(material) <> COUNT(DISTINCT material)
THEN 'ダブっている'
ELSE '平気'
END AS status
FROM Materials
GROUP BY center;

-- ダブりのある集合 EXISTSの利用

SELECT center, material
FROM Materials M1
WHERE EXISTS (
  SELECT *
  FROM Materials M2
  WHERE M1.center = M2.center
  AND M1.receive_date <> M2.receive_date
  AND M1.material = M2.material
);

/* 関係徐算でバスケット解析 */

CREATE TABLE Items
(item VARCHAR(16) PRIMARY KEY);
 
CREATE TABLE ShopItems
(shop VARCHAR(16),
 item VARCHAR(16),
    PRIMARY KEY(shop, item));

INSERT INTO Items VALUES('ビール');
INSERT INTO Items VALUES('紙オムツ');
INSERT INTO Items VALUES('自転車');

INSERT INTO ShopItems VALUES('仙台',  'ビール');
INSERT INTO ShopItems VALUES('仙台',  '紙オムツ');
INSERT INTO ShopItems VALUES('仙台',  '自転車');
INSERT INTO ShopItems VALUES('仙台',  'カーテン');
INSERT INTO ShopItems VALUES('東京',  'ビール');
INSERT INTO ShopItems VALUES('東京',  '紙オムツ');
INSERT INTO ShopItems VALUES('東京',  '自転車');
INSERT INTO ShopItems VALUES('大阪',  'テレビ');
INSERT INTO ShopItems VALUES('大阪',  '紙オムツ');
INSERT INTO ShopItems VALUES('大阪',  '自転車');

-- 全ての商品が置いてある店舗を検索

SELECT SI.shop
FROM ShopItems SI INNER JOIN Items I
ON SI.item = I.item
GROUP BY SI.shop
HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items);

-- マスタにないカーテンを持つ仙台店を除外

SELECT SI.shop
FROM ShopItems SI LEFT OUTER JOIN Items I
ON SI.item = I.item
GROUP BY SI.shop
HAVING COUNT(SI.item) = (SELECT COUNT(item) FROM Items)
AND COUNT(I.item) = (SELECT COUNT(item) FROM Items);

-- 演習問題6-1

SELECT ' 歯抜けあり' AS gap
  FROM SeqTbl
HAVING COUNT(*) <> MAX(seq)
UNION ALL
SELECT ' 歯抜けなし' AS gap
  FROM SeqTbl
HAVING COUNT(*) = MAX(seq);

SELECT CASE WHEN COUNT(*) <> MAX(seq)
            THEN '歯抜けあり'
            ELSE '歯抜けなし' END AS gap
  FROM SeqTbl;

-- 演習問題6-2

SELECT dpt
  FROM Students
 GROUP BY dpt
HAVING COUNT(*) = SUM(CASE WHEN sbmt_date BETWEEN '2018-09-01' 
                                              AND '2018-09-30'
                           THEN 1 ELSE 0 END);

-- 演習問題6-3

SELECT SI.shop,
       COUNT(SI.item) AS my_item_cnt,
       (SELECT COUNT(item) FROM Items) - COUNT(SI.item) AS diff_cnt
  FROM ShopItems SI INNER JOIN Items I
    ON SI.item = I.item
 GROUP BY SI.shop;
 