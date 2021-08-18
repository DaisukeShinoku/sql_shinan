-- 成長・後退・現状維持
CREATE TABLE Sales
(year INTEGER NOT NULL , 
 sale INTEGER NOT NULL ,
 PRIMARY KEY (year));

INSERT INTO Sales VALUES (1990, 50);
INSERT INTO Sales VALUES (1991, 51);
INSERT INTO Sales VALUES (1992, 52);
INSERT INTO Sales VALUES (1993, 52);
INSERT INTO Sales VALUES (1994, 50);
INSERT INTO Sales VALUES (1995, 50);
INSERT INTO Sales VALUES (1996, 49);
INSERT INTO Sales VALUES (1997, 55);

-- 前年と年商が同じ年度を求める(相関サブクエリの利用)
SELECT year, sale
FROM Sales S1
WHERE sale = (
  SELECT sale
  FROM Sales S2
  WHERE S2.year = S1.year -1
)
ORDER BY year;

-- 前年と年商が同じ年度を求める(ウィンドウ関数の利用)

SELECT year, current_sale
FROM (
  SELECT year,
  sale AS current_sale,
  SUM(sale) OVER (
    ORDER BY year
    RANGE BETWEEN 1 PRECEDING
    AND 1 PRECEDING
  ) AS pre_sale
  FROM Sales
) TMP
WHERE current_sale = pre_sale
ORDER BY year;


-- 上記のウィンドウ関数を切り出す
SELECT year,
sale AS current_sale,
SUM(sale) OVER (
  ORDER BY year
  RANGE BETWEEN 1 PRECEDING
  AND 1 PRECEDING
) AS pre_sale
FROM Sales;

-- 成長・後退・現状維持を一度に求める(相関サブクエリの利用)
SELECT year, current_sale AS sale,
CASE WHEN current_sale = pre_sale
THEN '→'
WHEN current_sale > pre_sale
THEN '↑'
WHEN current_sale < pre_sale
THEN '↓'
ELSE '-' END AS var
FROM (
  SELECT year,
  sale AS current_sale,
  (SELECT sale
  FROM Sales S2
  WHERE S2.year = S1.year - 1) AS pre_sale
  FROM Sales S1 
) TMP
ORDER BY year;

-- 成長・後退・現状維持を一度に求める(ウィンドウ関数の利用)
SELECT year, current_sale AS sale,
CASE WHEN current_sale = pre_sale
THEN '→'
WHEN current_sale > pre_sale
THEN '↑'
WHEN current_sale < pre_sale
THEN '↓'
ELSE '-' END AS var
FROM (
  SELECT year,
  sale AS current_sale,
  SUM(sale) OVER (
    ORDER BY year
    RANGE BETWEEN 1 PRECEDING
    AND 1 PRECEDING) AS pre_sale
  FROM Sales) TMP
ORDER BY year;

-- 直近と比較
CREATE TABLE Sales2
(year INTEGER NOT NULL , 
 sale INTEGER NOT NULL , 
 PRIMARY KEY (year));

INSERT INTO Sales2 VALUES (1990, 50);
INSERT INTO Sales2 VALUES (1992, 50);
INSERT INTO Sales2 VALUES (1993, 52);
INSERT INTO Sales2 VALUES (1994, 55);
INSERT INTO Sales2 VALUES (1997, 55);

-- 直近の年と同じ年商の年を選択する(相関サブクエリ)
SELECT year, sale
FROM Sales2 S1
WHERE sale =(
  SELECT sale
  FROM Sales2 S2
  WHERE S2.year = (
    SELECT MAX(year)
    FROM Sales2 S3
    WHERE S1.year > S3.year
  )
)
ORDER BY year;

-- 直近の年と同じ年商の年を選択する（ウィンドウ関数）
SELECT year, current_sale
FROM (
  SELECT
  year,
  sale AS current_sale,
  SUM(sale) OVER (
    ORDER BY year
    ROWS BETWEEN 1 PRECEDING
    AND 1 PRECEDING
  ) AS pre_sale
  FROM Sales2
) TMP
WHERE current_sale = pre_sale
ORDER BY year;

-- なぜウィンドウ関数で相関サブクエリを置き換えられるのか

-- サブクエリを用いて平均との比較
SELECT shohin_bunrui, shohin_mei, hanbai_tanka
FROM Shohin S1
WHERE hanbai_tanka > (
  SELECT AVG(hanbai_tanka)
  FROM Shohin S2
  WHERE S1.shohin_bunrui = S2.shohin_bunrui
  GROUP BY shohin_bunrui
);

-- ウィンドウ関数を用いて平均との比較
SELECT shohin_bunrui, shohin_mei, hanbai_tanka
FROM (
  SELECT shohin_mei, shohin_bunrui, hanbai_tanka,
  AVG(hanbai_tanka)
  OVER(PARTITION BY shohin_bunrui) AS avg_tanka
  FROM Shohin
) TMP
WHERE hanbai_tanka > avg_tanka;

-- オーバーラップする期間を調べる
CREATE TABLE Reservations
(reserver    VARCHAR(30) PRIMARY KEY,
 start_date  DATE  NOT NULL,
 end_date    DATE  NOT NULL);

INSERT INTO Reservations VALUES('木村', '2018-10-26', '2018-10-27');
INSERT INTO Reservations VALUES('荒木', '2018-10-28', '2018-10-31');
INSERT INTO Reservations VALUES('堀',   '2018-10-31', '2018-11-01');
INSERT INTO Reservations VALUES('山本', '2018-11-03', '2018-11-04');
INSERT INTO Reservations VALUES('内田', '2018-11-03', '2018-11-05');
INSERT INTO Reservations VALUES('水谷', '2018-11-06', '2018-11-06');

-- オーバーラップする期間を求める：その１ (相関サブクエリの利用)
SELECT reserver, start_date, end_date
FROM Reservations R1
WHERE EXISTS(
  SELECT *
  FROM Reservations R2
  WHERE R1.reserver <> R2.reserver
  AND (
    R1.start_date BETWEEN R2.start_date AND R2.end_date
    OR
    R1.end_date BETWEEN R2.start_date AND R2.end_date
  )
);

-- オーバーラップする期間を求める：その2 (ウィンドウ関数の利用)
SELECT reserver, next_reserver
FROM (
  SELECT
  reserver,
  start_date,
  end_date,
  MAX(start_date)
  OVER (
    ORDER BY start_date
    ROWS BETWEEN 1 FOLLOWING
    AND 1 FOLLOWING
  ) AS next_start_date,
  MAX(reserver)
  OVER (
    ORDER BY start_date
    ROWS BETWEEN 1 FOLLOWING
    AND 1 FOLLOWING
  ) AS next_reserver
  FROM Reservations
) TMP
WHERE next_start_date BETWEEN start_date AND end_date;

UPDATE Reservations SET start_date = '2018-11-04' WHERE reserver = '水谷';