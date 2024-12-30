﻿CREATE DATABASE BAITHI;
GO

USE BAITHI;
GO

CREATE TABLE NHACUNGCAP (
    MANCC VARCHAR(10) PRIMARY KEY,
    TENNCC NVARCHAR(50),
    QUOCGIA NVARCHAR(50),
    LOAINCC NVARCHAR(20)
);

CREATE TABLE DUOCPHAM (
    MADP VARCHAR(10) PRIMARY KEY,
    TENDP NVARCHAR(100),
    LOAIDP NVARCHAR(50),
    GIA DECIMAL(18, 0)
);

CREATE TABLE PHIEUNHAP (
    SOPN VARCHAR(10) PRIMARY KEY,
    NGNHAP DATE,
    MANCC VARCHAR(10),
    LOAINHAP NVARCHAR(20),
    FOREIGN KEY (MANCC) REFERENCES NHACUNGCAP(MANCC)
);

CREATE TABLE CTPN (
    SOPN VARCHAR(10),
    MADP VARCHAR(10),
    SOLUONG INT,
    PRIMARY KEY (SOPN, MADP),
    FOREIGN KEY (SOPN) REFERENCES PHIEUNHAP(SOPN),
    FOREIGN KEY (MADP) REFERENCES DUOCPHAM(MADP)
);

INSERT INTO NHACUNGCAP (MANCC, TENNCC, QUOCGIA, LOAINCC)
VALUES
('NCC01', N'Phuc Hung', N'Viet Nam', N'Thuong xuyen'),
('NCC02', N'J.B. Pharmaceuticals', N'India', N'Vang lai'),
('NCC03', N'Sapharco', N'Singapore', N'Vang lai');

INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA)
VALUES
('DP01', N'Thuoc ho PH', N'Siro', 120000),
('DP02', N'Zecuf Herbal CouchRemedy', N'Vien nen', 200000),
('DP03', N'Cotrim', N'Vien sui', 80000);

INSERT INTO PHIEUNHAP (SOPN, NGNHAP, MANCC, LOAINHAP)
VALUES
('00001', '2017-11-22', 'NCC01', N'Noi dia'),
('00002', '2017-12-04', 'NCC03', N'Nhap khau'),
('00003', '2017-12-10', 'NCC02', N'Nhap khau');

INSERT INTO CTPN (SOPN, MADP, SOLUONG)
VALUES
('00001', 'DP01', 100),
('00002', 'DP02', 200),
('00003', 'DP03', 543);

-- Câu 3
ALTER TABLE DUOCPHAM
ADD CONSTRAINT CK_GIA_SIRO 
CHECK (LOAIDP <> N'Siro' OR GIA > 100000);

-- Câu 4
CREATE TRIGGER TRG_PHIEUNHAP_LOAINHAP
ON PHIEUNHAP
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHIEUNHAP P
        JOIN NHACUNGCAP N ON P.MANCC = N.MANCC
        WHERE N.QUOCGIA <> N'Viet Nam' AND P.LOAINHAP <> N'Nhap khau'
    )
    BEGIN
        RAISERROR (N'Phiếu nhập của nhà cung cấp không phải Việt Nam phải có loại nhập là "Nhập khẩu".', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

-- Câu 5
SELECT * FROM PHIEUNHAP 
WHERE YEAR(NGNHAP) = 2017 AND MONTH(NGNHAP) = 12
ORDER BY NGNHAP ASC

-- Câu 6
SELECT TOP 1 CT.MADP, SUM(CT.SOLUONG) AS TONG_SOLUONG
FROM CTPN CT
JOIN PHIEUNHAP PN ON CT.SOPN = PN.SOPN
WHERE YEAR(PN.NGNHAP) = 2017
GROUP BY CT.MADP
ORDER BY TONG_SOLUONG DESC;

-- Câu 7
SELECT DISTINCT DP.MADP
FROM DUOCPHAM DP
JOIN CTPN CT ON DP.MADP = CT.MADP
JOIN PHIEUNHAP PN ON CT.SOPN = PN.SOPN
JOIN NHACUNGCAP NCC ON PN.MANCC = NCC.MANCC
WHERE NCC.LOAINCC = N'Thuong xuyen'
EXCEPT
SELECT DISTINCT DP.MADP
FROM DUOCPHAM DP
JOIN CTPN CT ON DP.MADP = CT.MADP
JOIN PHIEUNHAP PN ON CT.SOPN = PN.SOPN
JOIN NHACUNGCAP NCC ON PN.MANCC = NCC.MANCC
WHERE NCC.LOAINCC = N'Vang lai';

-- C2
SELECT D.MADP, D.TENDP
FROM DUOCPHAM D
WHERE D.MADP NOT IN (
    SELECT DISTINCT C.MADP
    FROM CTPN C
    JOIN PHIEUNHAP P ON C.SOPN = P.SOPN
    JOIN NHACUNGCAP N ON P.MANCC = N.MANCC
    WHERE N.LOAINCC = N'Vang lai'
)
AND D.MADP IN (
    SELECT DISTINCT C.MADP
    FROM CTPN C
    JOIN PHIEUNHAP P ON C.SOPN = P.SOPN
    JOIN NHACUNGCAP N ON P.MANCC = N.MANCC
    WHERE N.LOAINCC = N'Thuong xuyen'
);


-- Câu 8
SELECT N.MANCC, N.TENNCC
FROM NHACUNGCAP N
WHERE NOT EXISTS (
    SELECT D.MADP
    FROM DUOCPHAM D
    WHERE D.GIA > 100000
    AND NOT EXISTS (
        SELECT 1
        FROM CTPN C
        JOIN PHIEUNHAP P ON C.SOPN = P.SOPN
        WHERE C.MADP = D.MADP AND P.MANCC = N.MANCC AND YEAR(P.NGNHAP) = 2017
    )
);

-- C2
SELECT DISTINCT MANCC
FROM PHIEUNHAP pn
JOIN CTPN ctp ON pn.SOPN = ctp.SOPN
JOIN DUOCPHAM dp ON ctp.MADP = dp.MADP
WHERE YEAR(pn.NGNHAP) = 2017 AND dp.GIA > 100000
GROUP BY MANCC
HAVING COUNT(DISTINCT dp.MADP) = (
    SELECT COUNT(*)
    FROM DUOCPHAM
    WHERE GIA > 100000
);