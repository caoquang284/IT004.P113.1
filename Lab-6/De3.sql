CREATE DATABASE THUESACH
GO

USE THUESACH
GO

CREATE TABLE DOCGIA (
	MaDG char(5) PRIMARY KEY,
	HoTen varchar(30),
	NgaySinh smalldatetime,
	DiaChi varchar(30),
	SoDT varchar(15)
);

CREATE TABLE SACH (
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25),
	NhaXuatBan varchar(30)
);

CREATE TABLE PHIEUTHUE (
	MaDG char(5),
	MaPT char(5) PRIMARY KEY,
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoSachThue int
	FOREIGN KEY (MaDG) REFERENCES DOCGIA(MaDG),
);

CREATE TABLE CHITIET_PT (
	MaSach char(5),
	MaPT char(5),	
	PRIMARY KEY (MaSach, MaPT),
	FOREIGN KEY (MaSach) REFERENCES SACH(MaSach),
	FOREIGN KEY (MaPT) REFERENCES PHIEUTHUE(MaPT),
);

INSERT INTO DOCGIA (MaDG, HoTen, NgaySinh, DiaChi, SoDT)
VALUES
    ('DG01', 'Nguyen Van A', '1980-01-01', '123 Lê Lợi, Q1', '0912345678'),
    ('DG02', 'Tran Thi B', '1975-05-15', '456 Nguyễn Trãi, Q5', '0987654321'),
    ('DG03', 'Le Van C', '1990-11-20', '789 Pasteur, Q3	', '0123456789'),
    ('DG04', 'Pham Thi D', '1985-07-08', '1011 CMT8, Q10', '0987654321'),
    ('DG05', 'Vuong Van E', '1995-03-12', '1213 Cách Mạng Tháng 8, Q11', '0912345678');

INSERT INTO SACH (MaSach, TenSach, TheLoai, NhaXuatBan)
VALUES
    ('S001', 'Lập trình Java', 'Tin học', 'NXB Giáo dục'),
    ('S002', 'Cơ sở dữ liệu', N'Tin học', 'NXB Khoa học'),
    ('S003', 'Sherlock Holmes', N'Trinh thám', 'NXB Kim Đồng'),
    ('S004', 'Doraemon', 'Thiếu nhi', 'NXB Trẻ'),
    ('S005', 'Tử vi 2024', 'Phong thủy', 'NXB Văn hóa');

INSERT INTO PHIEUTHUE(MaPT, MaDG, NgayThue, NgayTra, SoSachThue)
VALUES
    ('PT01', 'DG01', '2007-05-05', '2007-05-10', 2),
    ('PT02', 'DG02', '2007-06-10', '2007-06-15', 1),
    ('PT03', 'DG03', '2007-07-15', '2007-07-20', 3),
    ('PT04', 'DG04', '2007-08-20', '2007-08-25', 1),
    ('PT05', 'DG05', '2007-09-25', '2007-09-30', 2);

INSERT INTO CHITIET_PT(MaSach, MaPT)
VALUES
    ('S001', 'PT01'),
    ('S002', 'PT01'),
    ('S003', 'PT02'),
	('S001', 'PT03'),
	('S002', 'PT03'),
    ('S003', 'PT03'),
    ('S004', 'PT04'),
    ('S005', 'PT05'),
    ('S001', 'PT05');

--2.1. Mỗi lần thuê sách, độc giả không được thuê quá 10 ngày. 
CREATE TRIGGER TRG_ValidateNgayThue
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE DATEDIFF(DAY, NgayThue, NgayTra) > 10
    )
    BEGIN
        RAISERROR('Thời gian thuê sách không được vượt quá 10 ngày.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--2.2. Số sách thuê trong bảng phiếu thuê bằng tổng số lần thuê sách có trong bảng chi tiết phiếu thuê. 
CREATE TRIGGER TRG_ValidateSoSachThue
ON PHIEUTHUE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHIEUTHUE PT
        WHERE PT.SoSachThue != (
            SELECT COUNT(*)
            FROM CHITIET_PT CTP
            WHERE CTP.MaPT = PT.MaPT
        )
    )
    BEGIN
        RAISERROR('Số sách thuê không khớp với số chi tiết phiếu thuê.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--3.1. Tìm các độc giả (MaDG,HoTen) đã thuê sách thuộc thể loại “Tin học” trong năm 2007. 
SELECT DISTINCT DG.MaDG, DG.HoTen
FROM DOCGIA DG
JOIN PHIEUTHUE PT ON DG.MaDG = PT.MaDG
JOIN CHITIET_PT CTP ON PT.MaPT = CTP.MaPT
JOIN SACH S ON CTP.MaSach = S.MaSach
WHERE S.TheLoai = 'Tin học' 
  AND YEAR(PT.NgayThue) = 2007;

--3.2. Tìm các độc giả (MaDG,HoTen) đã thuê nhiều thể loại sách nhất. 
SELECT TOP 1 WITH TIES DG.MaDG, DG.HoTen, COUNT(DISTINCT S.TheLoai) AS SoTheLoai
FROM DOCGIA DG
JOIN PHIEUTHUE PT ON DG.MaDG = PT.MaDG
JOIN CHITIET_PT CTP ON PT.MaPT = CTP.MaPT
JOIN SACH S ON CTP.MaSach = S.MaSach
GROUP BY DG.MaDG, DG.HoTen
ORDER BY COUNT(DISTINCT S.TheLoai) DESC;

--3.3. Trong mỗi thể loại sách, cho biết tên sách được thuê nhiều nhất. 
WITH TheLoai_Thue AS (
    SELECT S.TheLoai, S.TenSach, COUNT(*) AS SoLanThue
    FROM SACH S
    JOIN CHITIET_PT CTP ON S.MaSach = CTP.MaSach
    GROUP BY S.TheLoai, S.TenSach
),
TheLoai_MaxThue AS (
    SELECT TheLoai, MAX(SoLanThue) AS MaxThue
    FROM TheLoai_Thue
    GROUP BY TheLoai
)
SELECT TLT.TheLoai, TLT.TenSach, TLT.SoLanThue
FROM TheLoai_Thue TLT
JOIN TheLoai_MaxThue TLM ON TLT.TheLoai = TLM.TheLoai AND TLT.SoLanThue = TLM.MaxThue;
