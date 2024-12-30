CREATE DATABASE THUEBANGDIA
GO

USE THUEBANGDIA
GO

CREATE TABLE KHACHHANG (
    MaKH char(5) PRIMARY KEY,
    HoTen nvarchar(30),
    DiaChi nvarchar(30),
    SoDT varchar(15),
    LoaiKH varchar(10)
);

CREATE TABLE BANG_DIA (
    MaBD char(5) PRIMARY KEY,
    TenBD nvarchar(25),
    TheLoai nvarchar(25)
);

CREATE TABLE PHIEUTHUE (
    MaPT char(5) PRIMARY KEY,
    MaKH char(5),
    NgayThue smalldatetime,
    NgayTra smalldatetime,
    Soluongthue int,
    FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH)
);

CREATE TABLE CHITIET_PM (
    MaPT char(5),
    MaBD char(5),
    PRIMARY KEY (MaPT, MaBD),
    FOREIGN KEY (MaPT) REFERENCES PHIEUTHUE(MaPT),
    FOREIGN KEY (MaBD) REFERENCES BANG_DIA(MaBD)
);

INSERT INTO KHACHHANG (MaKH, HoTen, DiaChi, SoDT, LoaiKH) VALUES
('KH001', N'Nguyễn Văn A', N'123 Nguyễn Trãi, Q1', '0901234567', 'VIP'),
('KH002', N'Trần Thị B', N'456 Lê Lợi, Q2', '0912345678', 'Thuong'),
('KH003', N'Lê Văn C', N'789 Hai Bà Trưng, Q3', '0987654321', 'VIP'),
('KH004', N'Phạm Thị D', N'1011 Cách Mạng Tháng 8, Q10', '0976543210', 'Thuong'),
('KH005', N'Hồ Văn E', N'1213 Trần Hưng Đạo, Q5', '0965432109', 'VIP');

INSERT INTO BANG_DIA (MaBD, TenBD, TheLoai) VALUES
('BD001', N'Em của ngày hôm qua', N'Ca nhạc'),
('BD002', N'John Wick 4', N'Phim hành động'),
('BD003', N'Titanic', N'Phim tình cảm'),
('BD004', N'Lật mặt 6', N'Phim hài'),
('BD005', N'Doraemon', N'Phim hoạt hình');

INSERT INTO PHIEUTHUE (MaPT, MaKH, NgayThue, NgayTra, Soluongthue) VALUES
('PT001', 'KH001', '2024-12-20', '2024-12-22', 6),
('PT002', 'KH002', '2024-12-21', '2024-12-23', 3),
('PT003', 'KH003', '2024-12-22', '2024-12-24', 4),
('PT004', 'KH004', '2024-12-23', '2024-12-25', 2),
('PT005', 'KH001', '2024-12-24', '2024-12-26', 7);

INSERT INTO CHITIET_PM (MaPT, MaBD) VALUES
('PT001', 'BD001'),
('PT001', 'BD002'),
('PT002', 'BD003'),
('PT003', 'BD004'),
('PT003', 'BD005'),
('PT004', 'BD001'),
('PT005', 'BD002'),
('PT005', 'BD003');

--2.1. Thể loại băng đĩa chỉ thuộc các thể loại sau “ca nhạc”, “phim hành động”, “phim tình cảm”, “phim hoạt hình”. 
ALTER TABLE BANG_DIA
ADD CONSTRAINT CK_THELOAI CHECK (TheLoai IN (N'ca nhạc', N'phim hành động', N'phim tình cảm', N'phim hoạt hình'));

--2.2. Chỉ những khách hàng thuộc loại VIP mới được thuê với số lượng băng đĩa trên 5.
CREATE TRIGGER TR_Validate_SoLuongThue
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN KHACHHANG kh ON i.MaKH = kh.MaKH
        WHERE i.Soluongthue > 5 AND kh.LoaiKH <> 'VIP'
    )
    BEGIN
        RAISERROR (N'Chỉ khách hàng VIP mới được thuê số lượng băng đĩa trên 5.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--3.1. Tìm các khách hàng (MaDG,HoTen) đã thuê băng đĩa thuộc thể loại phim “Tình cảm” có số lượng thuê lớn hơn 3. 
SELECT DISTINCT kh.MaKH, kh.HoTen
FROM KHACHHANG kh
JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
JOIN CHITIET_PM ct ON pt.MaPT = ct.MaPT
JOIN BANG_DIA bd ON ct.MaBD = bd.MaBD
WHERE bd.TheLoai = N'Phim tình cảm' AND pt.Soluongthue > 3;

--3.2. Tìm các khách hàng(MaDG,HoTen) thuộc loại VIP đã thuê nhiều băng đĩa nhất. 
SELECT TOP 1 kh.MaKH, kh.HoTen, SUM(pt.Soluongthue) AS TongSoLuongThue
FROM KHACHHANG kh
JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
WHERE kh.LoaiKH = 'VIP'
GROUP BY kh.MaKH, kh.HoTen
ORDER BY TongSoLuongThue DESC;

--3.3. Trong mỗi thể loại băng đĩa, cho biết tên khách hàng nào đã thuê nhiều băng đĩa nhất.
WITH RentalSummary AS (
    SELECT bd.TheLoai, kh.MaKH, kh.HoTen, COUNT(ct.MaBD) AS SoLuongThue
    FROM KHACHHANG kh
    JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
    JOIN CHITIET_PM ct ON pt.MaPT = ct.MaPT
    JOIN BANG_DIA bd ON ct.MaBD = bd.MaBD
    GROUP BY bd.TheLoai, kh.MaKH, kh.HoTen
),
MaxRentals AS (
    SELECT TheLoai, MAX(SoLuongThue) AS MaxSoLuong
    FROM RentalSummary
    GROUP BY TheLoai
)
SELECT rs.TheLoai, rs.MaKH, rs.HoTen, rs.SoLuongThue
FROM RentalSummary rs
JOIN MaxRentals mr ON rs.TheLoai = mr.TheLoai AND rs.SoLuongThue = mr.MaxSoLuong;
