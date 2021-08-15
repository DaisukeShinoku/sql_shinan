-- 自己結合

CREATE TABLE Products
(name VARCHAR(16) PRIMARY KEY,
 price INTEGER NOT NULL);

INSERT INTO Products VALUES('りんご',	100);
INSERT INTO Products VALUES('みかん',	50);
INSERT INTO Products VALUES('バナナ',	80);

-- 重複順列を得るSQL

SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1 CROSS JOIN Products P2;

-- 順列を得るSQL

SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1 INNER JOIN Products P2
ON P1.name <> P2.name;

-- 組み合わせを得るSQL

SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1 INNER JOIN Products P2
ON P1.name > P2.name;

-- 組み合わせを得るSQL(3列)

SELECT P1.name AS name_1, P2.name AS name_2, P3.name AS name_3
FROM Products P1
INNER JOIN Products P2
ON P1.name > P2.name
INNER JOIN Products P3
ON P2.name > P3.name;

-- 部分的に不一致なキーの検索

CREATE TABLE Addresses
(name VARCHAR(32),
 family_id INTEGER,
 address VARCHAR(32),
 PRIMARY KEY(name, family_id));

INSERT INTO Addresses VALUES('前田 義明', '100', '東京都港区虎ノ門3-2-29');
INSERT INTO Addresses VALUES('前田 由美', '100', '東京都港区虎ノ門3-2-92');
INSERT INTO Addresses VALUES('加藤 茶',   '200', '東京都新宿区西新宿2-8-1');
INSERT INTO Addresses VALUES('加藤 勝',   '200', '東京都新宿区西新宿2-8-1');
INSERT INTO Addresses VALUES('ホームズ',  '300', 'ベーカー街221B');
INSERT INTO Addresses VALUES('ワトソン',  '400', 'ベーカー街221B');

-- 同じ家族だけど住所が違うレコードを検索するSQL

SELECT DISTINCT A1.name, A1.address
FROM Addresses A1 INNER JOIN Addresses A2
ON A1.family_id = A2.family_id
AND A1.address <> A2.address;

-- 値段が同じ商品の抽出

DROP TABLE Products;

CREATE TABLE Products
(name VARCHAR(16) PRIMARY KEY,
 price INTEGER NOT NULL);

INSERT INTO Products
VALUES
('りんご',50),
('みかん',100),
('ぶどう',50),
('スイカ',80),
('レモン',30),
('いちご',100),
('バナナ',100);

SELECT DISTINCT P1.name, P1.price
FROM Products P1 INNER JOIN Products P2
ON P1.price = P2.price
AND P1.name <> P2.name;

-- 演習問題3-1

DROP TABLE Products;

CREATE TABLE Products
(name VARCHAR(16) PRIMARY KEY,
 price INTEGER NOT NULL);

INSERT INTO Products VALUES('りんご',	100);
INSERT INTO Products VALUES('みかん',	50);
INSERT INTO Products VALUES('バナナ',	80);

SELECT P1.name AS name_1, P2.name AS name_2
  FROM Products P1 INNER JOIN Products P2
    ON P1.name >= P2.name;



-- 演習問題3-2

DROP TABLE Products;

CREATE TABLE Products
(name VARCHAR(16) NOT NULL,
 price INTEGER NOT NULL);

INSERT INTO Products VALUES('りんご',	50);
INSERT INTO Products VALUES('みかん',	100);
INSERT INTO Products VALUES('みかん',	100);
INSERT INTO Products VALUES('みかん',	100);
INSERT INTO Products VALUES('バナナ',	80);

DROP TABLE Products_NoRedundant;

CREATE TABLE Products_NoRedundant
AS
SELECT ROW_NUMBER()
         OVER(PARTITION BY name, price
                  ORDER BY name) AS row_num,
       name, price
  FROM Products;

DELETE FROM Products_NoRedundant
  WHERE row_num > 1;
