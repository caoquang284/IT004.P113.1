-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT * FROM ChuyenGia

--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email FROM ChuyenGia
WHERE GioiTinh=N'Nữ'

--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT * FROM CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau FROM DuAn
WHERE YEAR(NgayBatDau)=2023 AND YEAR(NgayKetThuc)=2023

--5
-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT 
    cg.HoTen,
    COUNT(cgda.MaDuAn) AS SoLuongDuAn
FROM 
    ChuyenGia cg
LEFT JOIN 
    ChuyenGia_DuAn cgda ON cg.MaChuyenGia = cgda.MaChuyenGia
GROUP BY 
    cg.HoTen;

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT DISTINCT 
    da.TenDuAn
FROM 
    DuAn da
JOIN 
    ChuyenGia_DuAn cgda ON da.MaDuAn = cgda.MaDuAn
JOIN 
    ChuyenGia_KyNang cgk ON cgda.MaChuyenGia = cgk.MaChuyenGia
JOIN 
    KyNang kn ON cgk.MaKyNang = kn.MaKyNang
WHERE 
    kn.TenKyNang = 'Python' AND cgk.CapDo >= 4;


--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT 
    ct.TenCongTy,
    COUNT(da.MaDuAn) AS SoLuongDuAnDangThucHien
FROM 
    CongTy ct
JOIN 
    DuAn da ON ct.MaCongTy = da.MaCongTy
WHERE 
    da.TrangThai = N'Đang thực hiện'
GROUP BY 
    ct.TenCongTy;


--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT 
    ChuyenNganh,
    HoTen,
    NamKinhNghiem
FROM 
    ChuyenGia cg1
WHERE 
    NamKinhNghiem = (
        SELECT 
            MAX(cg2.NamKinhNghiem)
        FROM 
            ChuyenGia cg2
        WHERE 
            cg2.ChuyenNganh = cg1.ChuyenNganh
    );



--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT DISTINCT 
    cg1.HoTen AS ChuyenGia1,
    cg2.HoTen AS ChuyenGia2
FROM 
    ChuyenGia_DuAn cgda1
JOIN 
    ChuyenGia_DuAn cgda2 ON cgda1.MaDuAn = cgda2.MaDuAn AND cgda1.MaChuyenGia < cgda2.MaChuyenGia
JOIN 
    ChuyenGia cg1 ON cgda1.MaChuyenGia = cg1.MaChuyenGia
JOIN 
    ChuyenGia cg2 ON cgda2.MaChuyenGia = cg2.MaChuyenGia;


-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT 
    cg.HoTen,
    SUM(DATEDIFF(DAY, cgda.NgayThamGia, da.NgayKetThuc)) AS TongThoiGian
FROM 
    ChuyenGia cg
JOIN 
    ChuyenGia_DuAn cgda ON cg.MaChuyenGia = cgda.MaChuyenGia
JOIN 
    DuAn da ON cgda.MaDuAn = da.MaDuAn
GROUP BY 
    cg.HoTen;


--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT 
    ct.TenCongTy,
    CAST(COUNT(CASE WHEN da.TrangThai = N'Hoàn thành' THEN 1 END) AS FLOAT) / COUNT(da.MaDuAn) * 100 AS TyLeHoanThanh
FROM 
    CongTy ct
JOIN 
    DuAn da ON ct.MaCongTy = da.MaCongTy
GROUP BY 
    ct.TenCongTy
HAVING 
    CAST(COUNT(CASE WHEN da.TrangThai = N'Hoàn thành' THEN 1 END) AS FLOAT) / COUNT(da.MaDuAn) > 0.9;


--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 
    kn.TenKyNang,
    COUNT(*) AS SoLuong
FROM 
    ChuyenGia_KyNang cgk
JOIN 
    KyNang kn ON cgk.MaKyNang = kn.MaKyNang
GROUP BY 
    kn.TenKyNang
ORDER BY 
    COUNT(*) DESC;

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT 
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN N'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN N'Middle'
        ELSE N'Senior'
    END AS CapDoKinhNghiem,
    AVG(Luong) AS LuongTrungBinh
FROM 
    (SELECT *, 5000 + NamKinhNghiem * 1000 AS Luong FROM ChuyenGia) AS cg
GROUP BY 
    CASE 
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN N'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN N'Middle'
        ELSE N'Senior'
    END;


--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT 
    da.TenDuAn
FROM 
    DuAn da
JOIN 
    ChuyenGia_DuAn cgda ON da.MaDuAn = cgda.MaDuAn
JOIN 
    ChuyenGia cg ON cgda.MaChuyenGia = cg.MaChuyenGia
GROUP BY 
    da.TenDuAn
HAVING 
    COUNT(DISTINCT cg.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);


-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
-- Thêm cột SoLuongDuAn vào bảng CongTy nếu chưa có
ALTER TABLE CongTy ADD SoLuongDuAn INT DEFAULT 0;

CREATE TRIGGER trg_CapNhatSoLuongDuAn
ON DuAn
AFTER INSERT, DELETE
AS
BEGIN
    -- Cập nhật khi thêm dự án mới
    UPDATE ct
    SET SoLuongDuAn = (
        SELECT COUNT(*) 
        FROM DuAn 
        WHERE MaCongTy = ct.MaCongTy
    )
    FROM CongTy ct
    WHERE ct.MaCongTy IN (
        SELECT MaCongTy FROM inserted
        UNION
        SELECT MaCongTy FROM deleted
    );
END;

-- Thêm dữ liệu mẫu
INSERT INTO CongTy (MaCongTy, TenCongTy, DiaChi, LinhVuc, SoNhanVien) 
VALUES (11, N'Công ty A', N'Hà Nội', N'Công nghệ', 100);


INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (11, N'Dự án 1', 11, '2024-01-01', '2024-12-31', N'Đang thực hiện');
-- Thêm dự án thứ 2
INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (12, N'Dự án 2', 11, '2024-02-01', '2024-12-31', N'Đang thực hiện');

-- Kiểm tra 
SELECT MaCongTy, TenCongTy, SoLuongDuAn 
FROM CongTy 
WHERE MaCongTy = 11;

-- Xóa dự án và kiểm tra
DELETE FROM DuAn WHERE MaDuAn = 12;
SELECT MaCongTy, TenCongTy, SoLuongDuAn 
FROM CongTy 
WHERE MaCongTy = 11;

--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE Log_ChuyenGia (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    HoTen NVARCHAR(100),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    Email NVARCHAR(100),
    SoDienThoai NVARCHAR(20),
    ChuyenNganh NVARCHAR(50),
    NamKinhNghiem INT,
    LogTime DATETIME DEFAULT GETDATE(),
    LogType NVARCHAR(10)
);

CREATE TRIGGER trg_LogChuyenGia
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Ghi log khi thêm
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, LogType)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'INSERT'
        FROM inserted;
    END
    
    -- Ghi log khi cập nhật
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, LogType)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'UPDATE'
        FROM inserted;
    END
    
    -- Ghi log khi xóa
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Log_ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, LogType)
        SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem, 'DELETE'
        FROM deleted;
    END
END;

INSERT INTO ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem)
VALUES (11, N'Test Chuyên Gia', '1990-01-01', N'Nam', 'test@email.com', '0912345678', N'Kiểm thử phần mềm', 3);
UPDATE ChuyenGia
SET HoTen = N'Test Chuyên Gia Updated'
WHERE MaChuyenGia = 11;
DELETE FROM ChuyenGia WHERE MaChuyenGia = 11;
SELECT * FROM Log_ChuyenGia;


--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_LimitDuAn
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT MaChuyenGia
        FROM ChuyenGia_DuAn
        GROUP BY MaChuyenGia
        HAVING COUNT(MaDuAn) > 5
    )
    BEGIN
        RAISERROR ('Chuyên gia không được tham gia quá 5 dự án cùng một lúc', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
VALUES (1, 2, N'Trưởng nhóm kiểm thử', '2024-01-01'),
(1, 3, N'Trưởng nhóm kiểm thử', '2024-01-01'),
(1, 4, N'Trưởng nhóm kiểm thử', '2024-01-01'),
(1, 5, N'Trưởng nhóm kiểm thử', '2024-01-01'),
(1, 6, N'Trưởng nhóm kiểm thử', '2024-01-01');

--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
CREATE TRIGGER trg_UpdateTrangThaiDuAn
ON ChuyenGia_DuAn
AFTER UPDATE
AS
BEGIN
    UPDATE DuAn
    SET TrangThai = N'Hoàn thành'
    WHERE MaDuAn IN (
        SELECT cgda.MaDuAn
        FROM ChuyenGia_DuAn cgda
        JOIN DuAn da ON cgda.MaDuAn = da.MaDuAn
        WHERE da.TrangThai <> N'Hoàn thành'
        GROUP BY cgda.MaDuAn
        HAVING COUNT(*) = COUNT(CASE WHEN cgda.NgayThamGia IS NOT NULL THEN 1 END)
    );
END;

UPDATE ChuyenGia_DuAn
SET NgayThamGia = '2024-01-01'
WHERE MaDuAn = 2 AND MaChuyenGia = 4;

SELECT MaDuAn, TenDuAn, TrangThai FROM DuAn;

--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
-- Thêm cột DiemDanhGia vào bảng DuAn và CongTy nếu chưa có
ALTER TABLE DuAn ADD DiemDanhGia FLOAT;
ALTER TABLE CongTy ADD DiemTrungBinh FLOAT;

CREATE TRIGGER trg_CapNhatDiemDanhGia
ON DuAn
AFTER UPDATE
AS
BEGIN
    IF UPDATE(DiemDanhGia)
    BEGIN
        UPDATE CongTy
        SET DiemTrungBinh = (
            SELECT AVG(DiemDanhGia)
            FROM DuAn
            WHERE MaCongTy = CongTy.MaCongTy
            AND DiemDanhGia IS NOT NULL
        )
        FROM CongTy ct
        INNER JOIN inserted i ON ct.MaCongTy = i.MaCongTy;
    END
END;


