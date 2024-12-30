CREATE DATABASE CongTyXe
GO

USE CongTyXe
GO

CREATE TABLE NHANVIEN (
	MaNV char(5) PRIMARY KEY,
	HoTen nvarchar(20),
	NgayVL smalldatetime,
	HSLuong numeric(4,2),
	MaPhong char(5),
	FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong),
);

CREATE TABLE PHONGBAN (
	MaPhong char(5) PRIMARY KEY,
	TenPhong nvarchar(25),
	TruongPhong char(5)
);

CREATE TABLE XE (
	MaXe char(5) PRIMARY KEY,
	LoaiXe varchar(20),
	SoChoNgoi int, 
	NamSX int
);

CREATE TABLE PHANCONG (
	MaPC char(5) PRIMARY KEY,
	MaNV char(5),
	MaXe char(5),
	NgayDi smalldatetime,
	NgayVe smalldatetime,
	NoiDen nvarchar(25),
	FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
	FOREIGN KEY (MaXe) REFERENCES Xe(MaXe),
);

-- NHANVIEN
INSERT INTO NHANVIEN (MaNV, HoTen, NgayVL, HSLuong, MaPhong) VALUES
('NV01', N'Nguyễn Văn A', '2020-05-15', 4.50, 'P01'),
('NV02', N'Trần Thị B', '2019-08-20', 5.00, 'P02'),
('NV03', N'Lê Văn C', '2021-01-10', 4.00, 'P01'),
('NV04', N'Phạm Thị D', '2018-03-05', 5.50, 'P02'),
('NV05', N'Hoàng Văn E', '2022-06-22', 4.75, 'P03');

-- PHONGBAN
INSERT INTO PHONGBAN (MaPhong, TenPhong, TruongPhong) VALUES
('P01', N'Nội thành', 'NV01'),
('P02', N'Ngoại thành', 'NV04'),
('P03', N'Bảo trì', 'NV05');

-- XE
INSERT INTO XE (MaXe, LoaiXe, SoChoNgoi, NamSX) VALUES
('X01', 'Toyota', 4, 2023),
('X02', 'Honda', 7, 2022),
('X03', 'Ford', 5, 2021),
('X04', 'Toyota', 16, 2020),
('X05', 'Kia', 4, 2019);

-- PHANCONG
INSERT INTO PHANCONG (MaPC, MaNV, MaXe, NgayDi, NgayVe, NoiDen) VALUES
('PC01', 'NV01', 'X01', '2024-01-05', '2024-01-08', N'Hà Nội'),
('PC02', 'NV02', 'X02', '2024-02-10', '2024-02-15', N'Đà Nẵng'),
('PC03', 'NV03', 'X01', '2024-03-03', '2024-03-06', N'TP. Hồ Chí Minh'),
('PC04', 'NV04', 'X04', '2024-04-01', '2024-04-05', N'Nha Trang'),
('PC05', 'NV05', 'X03', '2024-05-08', '2024-05-12', N'Huế');

--2.1. Năm sản xuất của xe loại Toyota phải từ năm 2006 trở về sau. 
ALTER TABLE XE
ADD CONSTRAINT CK_NamSX_Toyota CHECK (
    (LoaiXe != 'Toyota') OR (NamSX >= 2006)
);

--2.2. Nhân viên thuộc phòng lái xe “Ngoại thành” chỉ được phân công lái xe loại Toyota.
CREATE TRIGGER TRG_CheckNgoaiThanh
ON PHANCONG
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN NHANVIEN nv ON i.MaNV = nv.MaNV
        JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
        JOIN XE x ON i.MaXe = x.MaXe
        WHERE pb.TenPhong = N'Ngoại thành' AND x.LoaiXe != 'Toyota'
    )
    BEGIN
        ROLLBACK TRANSACTION;
		THROW 50001, 'Nhân viên thuộc phòng Ngoại thành chỉ được lái xe loại Toyota.', 1;
    END
END;

--3.1. Tìm nhân viên (MaNV,HoTen) thuộc phòng lái xe “Nội thành” được phân công lái loại xe Toyota có số chỗ ngồi là 4. 
SELECT DISTINCT nv.MaNV, nv.HoTen
FROM NHANVIEN nv
JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
JOIN PHANCONG pc ON nv.MaNV = pc.MaNV
JOIN XE x ON pc.MaXe = x.MaXe
WHERE pb.TenPhong = N'Nội thành'
  AND x.LoaiXe = 'Toyota'
  AND x.SoChoNgoi = 4;

--3.2. Tìm nhân viên(MANV,HoTen) là trưởng phòng được phân công lái tất cả các loại xe. 
SELECT DISTINCT nv.MaNV, nv.HoTen
FROM NHANVIEN nv
JOIN PHONGBAN pb ON nv.MaNV = pb.TruongPhong
WHERE NOT EXISTS (
    SELECT x.LoaiXe
    FROM XE x
    WHERE NOT EXISTS (
        SELECT 1
        FROM PHANCONG pc
        WHERE pc.MaNV = nv.MaNV AND pc.MaXe = x.MaXe
    )
);

--3.3. Trong mỗi phòng ban,tìm nhân viên (MaNV,HoTen) được phân công lái ít nhất loại xe Toyota. 
WITH ToyotaCounts AS (
    SELECT nv.MaNV, nv.HoTen, pb.TenPhong, COUNT(DISTINCT x.MaXe) AS SoLuongToyota
    FROM NHANVIEN nv
    JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
    JOIN PHANCONG pc ON nv.MaNV = pc.MaNV
    JOIN XE x ON pc.MaXe = x.MaXe
    WHERE x.LoaiXe = 'Toyota'
    GROUP BY nv.MaNV, nv.HoTen, pb.TenPhong
)
SELECT TenPhong, MaNV, HoTen
FROM (
    SELECT TenPhong, MaNV, HoTen, SoLuongToyota,
           RANK() OVER (PARTITION BY TenPhong ORDER BY SoLuongToyota ASC) AS rnk
    FROM ToyotaCounts
) AS Ranked
WHERE rnk = 1;
