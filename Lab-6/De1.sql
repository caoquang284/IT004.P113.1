CREATE DATABASE THUVIEN;
GO

USE THUVIEN;
GO

CREATE TABLE TACGIA (
	MaTG char(5) PRIMARY KEY,
	HoTen varchar(20),
	DiaChi varchar(50),
	NgSinh smalldatetime,
	SoDT varchar(15)
);

CREATE TABLE SACH (
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai nvarchar(25)
);

CREATE TABLE TACGIA_SACH (
	MaSach char(5),
	MaTG char(5),
	PRIMARY KEY (MaSach, MaTG),
	FOREIGN KEY (MaSach) REFERENCES SACH(MaSach),
	FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG)
);

CREATE TABLE PHATHANH (
	MaPH char(5) PRIMARY KEY,
	MaSach char(5),
	NgayPH smalldatetime,
	SoLuong int,
	NhaXuatBan nvarchar(20)
	FOREIGN KEY (MaSach) REFERENCES SACH(MaSach),
);

INSERT INTO TACGIA (MaTG, HoTen, DiaChi, NgSinh, SoDT)
VALUES
    ('TG001', 'Nguyen Van A', 'Ha Noi', '1980-01-01', '0912345678'),
    ('TG002', 'Tran Thi B', 'Ho Chi Minh', '1975-05-15', '0987654321'),
    ('TG003', 'Le Van C', 'Da Nang', '1990-11-20', '0123456789'),
    ('TG004', 'Pham Thi D', 'Hai Phong', '1985-07-08', '0987654321'),
    ('TG005', 'Vuong Van E', 'Hue', '1995-03-12', '0912345678');

INSERT INTO SACH (MaSach, TenSach, TheLoai)
VALUES
    ('S001', 'Sach 1', 'Khoa hoc'),
    ('S002', 'Sach 2', N'Văn học'),
    ('S003', 'Sach 3', N'Giáo khoa'),
    ('S004', 'Sach 4', 'Kinh te'),
    ('S005', 'Sach 5', 'Cong nghe');

INSERT INTO TACGIA_SACH (MaSach, MaTG)
VALUES
    ('S001', 'TG001'),
    ('S002', 'TG002'),
    ('S003', 'TG003'),
    ('S004', 'TG004'),
    ('S005', 'TG005');

INSERT INTO PHATHANH (MaPH, MaSach, NgayPH, SoLuong, NhaXuatBan)
VALUES
    ('PH001', 'S001', '2023-11-15', 100, 'NXB 1'),
    ('PH002', 'S002', '2023-12-01', 150, N'Trẻ'),
    ('PH003', 'S003', '2023-10-20', 80, N'Giáo dục'),
    ('PH004', 'S004', '2023-11-25', 120, 'NXB 4'),
    ('PH005', 'S005', '2023-12-10', 200, 'NXB 5');

--2.1. Ngày phát hành sách phải lớn hơn ngày sinh của tác giả. 
CREATE TRIGGER TRG_CheckNgayPH
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra ràng buộc
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN TACGIA_SACH ts ON i.MaSach = ts.MaSach
        JOIN TACGIA tg ON ts.MaTG = tg.MaTG
        WHERE i.NgayPH <= tg.NgSinh
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Ngày phát hành phải lớn hơn ngày sinh của tác giả.', 1;
    END
END;

--2.2. Sách thuộc thể loại “Giáo khoa” chỉ do nhà xuất bản “Giáo dục” phát hành. 
CREATE TRIGGER TRG_CheckTheLoai
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra ràng buộc
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN SACH s ON i.MaSach = s.MaSach
        WHERE s.TheLoai = N'Giáo khoa' AND i.NhaXuatBan <> N'Giáo dục'
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Sách thuộc thể loại "Giáo khoa" chỉ do nhà xuất bản "Giáo dục" phát hành.', 1;
    END
END;


--3.1. Tìm tác giả (MaTG,HoTen,SoDT) của những quyển sách thuộc thể loại “Văn học” do nhà xuất bản Trẻ phát hành. 
SELECT DISTINCT tg.MaTG, tg.HoTen, tg.SoDT
FROM TACGIA tg
JOIN TACGIA_SACH ts ON tg.MaTG = ts.MaTG
JOIN SACH s ON ts.MaSach = s.MaSach
JOIN PHATHANH ph ON s.MaSach = ph.MaSach
WHERE s.TheLoai = N'Văn học' AND ph.NhaXuatBan = N'Trẻ';

--3.2. Tìm nhà xuất bản phát hành nhiều thể loại sách nhất.
SELECT TOP 1 ph.NhaXuatBan, COUNT(DISTINCT s.TheLoai) AS SoLuongTheLoai
FROM PHATHANH ph
JOIN SACH s ON ph.MaSach = s.MaSach
GROUP BY ph.NhaXuatBan
ORDER BY SoLuongTheLoai DESC;

--3.3. Trong mỗi nhà xuất bản, tìm tác giả (MaTG,HoTen) có số lần phát hành nhiều sách nhất. 
WITH SoLanPhatHanh AS (
    SELECT ph.NhaXuatBan, tg.MaTG, tg.HoTen, COUNT(*) AS SoLan
    FROM PHATHANH ph
    JOIN TACGIA_SACH ts ON ph.MaSach = ts.MaSach
    JOIN TACGIA tg ON ts.MaTG = tg.MaTG
    GROUP BY ph.NhaXuatBan, tg.MaTG, tg.HoTen
),
MaxPhatHanh AS (
    SELECT NhaXuatBan, MAX(SoLan) AS MaxLan
    FROM SoLanPhatHanh
    GROUP BY NhaXuatBan
)
SELECT s.NhaXuatBan, s.MaTG, s.HoTen, s.SoLan
FROM SoLanPhatHanh s
JOIN MaxPhatHanh m ON s.NhaXuatBan = m.NhaXuatBan AND s.SoLan = m.MaxLan;
