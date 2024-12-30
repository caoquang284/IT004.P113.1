-- Câu hỏi và ví dụ về Triggers (101-110)
-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
ALTER TABLE ChuyenGia
ADD NgayCapNhat DATETIME;

CREATE TRIGGER TR_ChuyenGia_CapNhatThongTin
ON ChuyenGia
AFTER UPDATE, INSERT
AS
BEGIN
    UPDATE ChuyenGia
    SET NgayCapNhat = GETDATE()
    WHERE MaChuyenGia IN (SELECT DISTINCT MaChuyenGia FROM inserted);
END;

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TABLE DuAn_Log (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaDuAn INT,
    ThaoTac NVARCHAR(50),
    ThoiGian DATETIME,
    GiaTriCu NVARCHAR(MAX),
    GiaTriMoi NVARCHAR(MAX)
);

CREATE TRIGGER TR_DuAn_GhiLog
ON DuAn
AFTER UPDATE, INSERT, DELETE
AS
BEGIN
    IF EXISTS(SELECT 1 FROM inserted)
    BEGIN
        -- INSERT hoặc UPDATE
        INSERT INTO DuAn_Log (MaDuAn, ThaoTac, ThoiGian, GiaTriMoi)
        SELECT MaDuAn, 'INSERT/UPDATE', GETDATE(), 
               (SELECT TenDuAn + ', ' + CAST(MaCongTy AS NVARCHAR) + ', ' + CONVERT(VARCHAR, NgayBatDau, 103) + ', ' + 
                       CONVERT(VARCHAR, NgayKetThuc, 103) + ', ' + TrangThai FROM inserted)
        FROM inserted;
    END
    IF EXISTS(SELECT 1 FROM deleted)
    BEGIN
        -- DELETE
        INSERT INTO DuAn_Log (MaDuAn, ThaoTac, ThoiGian, GiaTriCu)
        SELECT MaDuAn, 'DELETE', GETDATE(), 
               (SELECT TenDuAn + ', ' + CAST(MaCongTy AS NVARCHAR) + ', ' + CONVERT(VARCHAR, NgayBatDau, 103) + ', ' + 
                       CONVERT(VARCHAR, NgayKetThuc, 103) + ', ' + TrangThai FROM deleted)
        FROM deleted;
    END
END;


-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER TR_ChuyenGia_DuAn_GioiHan
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM ChuyenGia_DuAn WHERE MaChuyenGia = (SELECT MaChuyenGia FROM inserted)) > 5
    BEGIN
        RAISERROR('Chuyên gia này đã tham gia quá 5 dự án.', 16, 1)
        ROLLBACK TRANSACTION
    END
END;

-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.


-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER TR_DuAn_NganChanXoa
ON DuAn
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE TrangThai = N'Hoàn thành')
    BEGIN
        RAISERROR('Không thể xóa dự án đã hoàn thành.', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        DELETE FROM DuAn WHERE MaDuAn IN (SELECT MaDuAn FROM deleted)
    END
END;

-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.
CREATE TRIGGER trg_UpdateCapDoKyNang
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    UPDATE ChuyenGia_KyNang
    SET CapDo = CapDo + 1
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM inserted);
END;

INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang, CapDo)
VALUES (1, 4, 4);
INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
VALUES (1, 4, 'Developer', GETDATE());
SELECT * FROM ChuyenGia_KyNang WHERE MaChuyenGia = 1;


-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE LogKyNang (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    MaKyNang INT,
    CapDoCu INT,
    CapDoMoi INT,
    ThoiGian DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_LogCapDoKyNang
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    INSERT INTO LogKyNang (MaChuyenGia, MaKyNang, CapDoCu, CapDoMoi)
    SELECT d.MaChuyenGia, d.MaKyNang, d.CapDo AS CapDoCu, i.CapDo AS CapDoMoi
    FROM deleted d
    JOIN inserted i ON d.MaChuyenGia = i.MaChuyenGia AND d.MaKyNang = i.MaKyNang;
END;

UPDATE ChuyenGia_KyNang
SET CapDo = CapDo + 1
WHERE MaChuyenGia = 1 AND MaKyNang = 1;

SELECT * FROM LogKyNang;


-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER TR_DuAn_KiemTraNgay
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NgayKetThuc <= NgayBatDau)
    BEGIN
        RAISERROR('Ngày kết thúc phải lớn hơn ngày bắt đầu.', 16, 1)
        ROLLBACK TRANSACTION
    END
END;

-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER TR_KyNang_Xoa
ON KyNang
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM ChuyenGia_KyNang WHERE MaKyNang IN (SELECT MaKyNang FROM deleted);
    DELETE FROM KyNang WHERE MaKyNang IN (SELECT MaKyNang FROM deleted);
END;

-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER TR_CongTy_DuAn_GioiHan
ON DuAn
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = (SELECT MaCongTy FROM inserted) AND TrangThai = N'Đang thực hiện') > 10
    BEGIN
        RAISERROR('Công ty này đã có quá 10 dự án đang thực hiện.', 16, 1)
        ROLLBACK TRANSACTION
    END
END;

DECLARE @i INT = 30;
WHILE @i <= 41
BEGIN
    INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
    VALUES (@i, 'Du An ' + CAST(@i AS NVARCHAR), 2, GETDATE(), DATEADD(DAY, 30, GETDATE()), N'Đang thực hiện');
    SET @i = @i + 1;
END;

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.
ALTER TABLE ChuyenGia ADD Luong DECIMAL(18, 2);

CREATE TRIGGER trg_UpdateLuong
ON ChuyenGia
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE ChuyenGia
    SET Luong = (1000 * NamKinhNghiem + 500 * (
        SELECT MAX(CapDo)
        FROM ChuyenGia_KyNang
        WHERE ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
    ))
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM inserted);
END;

INSERT INTO ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem)
VALUES (22, 'Nguyen Thi B', '1985-01-01', 'Nu', 'nguyenthib@gmail.com', '0987654321', 'CNTT', 10);
INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang, CapDo)
VALUES (22, 1, 3); 

SELECT * FROM ChuyenGia WHERE MaChuyenGia = 22;


-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).
CREATE TRIGGER trg_NotifyDuAnSapHetHan
ON DuAn
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT MaDuAn
        FROM DuAn
        WHERE DATEDIFF(DAY, GETDATE(), NgayKetThuc) = 7
    )
    BEGIN
        PRINT N'Thông báo: Một dự án sắp đến hạn trong 7 ngày.';
    END
END;

UPDATE DuAn
SET NgayKetThuc = DATEADD(DAY, 7, GETDATE())
WHERE MaDuAn = 1;

-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.
CREATE TRIGGER TR_ChuyenGia_NganChanThayDoi
ON ChuyenGia
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d JOIN ChuyenGia_DuAn c ON d.MaChuyenGia = c.MaChuyenGia)
    BEGIN
        RAISERROR('Không thể thay đổi thông tin chuyên gia đang tham gia dự án.', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        -- Thực hiện UPDATE hoặc DELETE nếu chuyên gia không tham gia dự án
        IF EXISTS(SELECT 1 FROM inserted)
        BEGIN
            UPDATE ChuyenGia
            SET HoTen = i.HoTen, 
                NgaySinh = i.NgaySinh,
                GioiTinh = i.GioiTinh,
                Email = i.Email,
                SoDienThoai = i.SoDienThoai,
                ChuyenNganh = i.ChuyenNganh,
                NamKinhNghiem = i.NamKinhNghiem
            FROM inserted i
            WHERE ChuyenGia.MaChuyenGia = i.MaChuyenGia;
        END
        ELSE
        BEGIN
            DELETE FROM ChuyenGia WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM deleted);
        END
    END
END;

-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.
CREATE TABLE ThongKeChuyenNganh (
    ChuyenNganh NVARCHAR(50) PRIMARY KEY,
    SoLuongChuyenGia INT DEFAULT 0
);

CREATE TRIGGER trg_UpdateThongKeChuyenNganh
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    -- Cập nhật số lượng chuyên gia sau khi thêm
    MERGE ThongKeChuyenNganh AS tk
    USING (
        SELECT ChuyenNganh, COUNT(*) AS SoLuong
        FROM ChuyenGia
        GROUP BY ChuyenNganh
    ) AS cg
    ON tk.ChuyenNganh = cg.ChuyenNganh
    WHEN MATCHED THEN
        UPDATE SET SoLuongChuyenGia = cg.SoLuong
    WHEN NOT MATCHED THEN
        INSERT (ChuyenNganh, SoLuongChuyenGia) VALUES (cg.ChuyenNganh, cg.SoLuong)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
END;

INSERT INTO ChuyenGia (MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem)
VALUES (31, N'Nguyễn Văn A', '1990-01-01', N'Nam', 'a@gmail.com', '0123456789', N'Công nghệ thông tin', 5);
SELECT * FROM ThongKeChuyenNganh;

DELETE FROM ChuyenGia WHERE MaChuyenGia = 31;
SELECT * FROM ThongKeChuyenNganh;



-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.
CREATE TABLE DuAnHoanThanh (
    MaDuAn INT PRIMARY KEY,
    TenDuAn NVARCHAR(200),
    MaCongTy INT,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    TrangThai NVARCHAR(50)
);

CREATE TRIGGER trg_BackupDuAnHoanThanh
ON DuAn
AFTER UPDATE
AS
BEGIN
    INSERT INTO DuAnHoanThanh (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
    SELECT MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai
    FROM inserted
    WHERE TrangThai = 'Hoàn thành';
END;

INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (21, N'Dự án A', 1, '2024-01-01', '2024-12-31', N'Đang thực hiện');

UPDATE DuAn
SET TrangThai = N'Hoàn thành'
WHERE MaDuAn = 21;

SELECT * FROM DuAnHoanThanh;


-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
CREATE TABLE DanhGiaDuAn (
    MaDuAn INT PRIMARY KEY,
    DiemDanhGia FLOAT CHECK (DiemDanhGia BETWEEN 0 AND 100)
);

CREATE TRIGGER trg_UpdateDiemDanhGiaCongTy
ON DanhGiaDuAn
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia)
        FROM DanhGiaDuAn dg
        JOIN DuAn da ON dg.MaDuAn = da.MaDuAn
        WHERE da.MaCongTy = CongTy.MaCongTy
    )
    WHERE MaCongTy IN (
        SELECT da.MaCongTy
        FROM DuAn da
        JOIN inserted i ON da.MaDuAn = i.MaDuAn
    );
END;


-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.
CREATE TRIGGER trg_AutoAssignChuyenGia
ON DuAn
AFTER INSERT
AS
BEGIN
    INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
    SELECT TOP 1 
        ck.MaChuyenGia,         -- Mã chuyên gia phù hợp
        i.MaDuAn,               -- Mã dự án từ bảng inserted
        'Thành viên',           -- Vai trò mặc định
        GETDATE()               -- Ngày tham gia
    FROM inserted i
    JOIN ChuyenGia_KyNang ck 
        ON ck.MaKyNang = (SELECT TOP 1 MaKyNang FROM DuAn WHERE MaDuAn = i.MaDuAn)
    JOIN ChuyenGia
        ON ChuyenGia.MaChuyenGia = ck.MaChuyenGia -- Kết nối bảng ChuyenGia để lấy thông tin kinh nghiệm
    WHERE ck.CapDo > 5         -- Điều kiện: Kỹ năng đủ cao
    ORDER BY ck.CapDo DESC, ChuyenGia.NamKinhNghiem DESC; -- Sắp xếp theo cấp độ kỹ năng và kinh nghiệm
END;

INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (22, N'Dự án B', 1, '2024-01-01', '2024-06-30', N'Đang thực hiện');

SELECT * FROM ChuyenGia_DuAn;

-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.
ALTER TABLE ChuyenGia
ADD TrangThai NVARCHAR(20) DEFAULT 'Rảnh'; -- Mặc định là 'Rảnh'

CREATE TRIGGER trg_UpdateTrangThaiChuyenGia
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    UPDATE ChuyenGia
    SET TrangThai = N'Bận'
    WHERE MaChuyenGia IN (
        SELECT MaChuyenGia
        FROM inserted
    );
END;

INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
VALUES (11, 9, 'Thành viên', GETDATE());

SELECT MaChuyenGia, HoTen, TrangThai
FROM ChuyenGia;


-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.
CREATE TRIGGER trg_PreventDuplicateKyNang
ON ChuyenGia_KyNang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ChuyenGia_KyNang ck
        JOIN inserted i ON ck.MaChuyenGia = i.MaChuyenGia AND ck.MaKyNang = i.MaKyNang
    )
    BEGIN
        RAISERROR ('Không thể thêm kỹ năng trùng lặp!', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang, CapDo)
        SELECT MaChuyenGia, MaKyNang, CapDo
        FROM inserted;
    END;
END;


INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang, CapDo)
VALUES (1, 1, 8); 

-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.
CREATE TABLE BaoCaoDuAn (
    MaBaoCao INT IDENTITY PRIMARY KEY,
    MaDuAn INT,
    TenDuAn NVARCHAR(200),
    NgayKetThuc DATE,
    FOREIGN KEY (MaDuAn) REFERENCES DuAn(MaDuAn)
);

CREATE TRIGGER trg_GenerateReport
ON DuAn
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE TrangThai = 'Hoàn thành')
    BEGIN
        INSERT INTO BaoCaoDuAn (MaDuAn, TenDuAn, NgayKetThuc)
        SELECT MaDuAn, TenDuAn, GETDATE()
        FROM inserted
        WHERE TrangThai = 'Hoàn thành';
    END;
END;

UPDATE DuAn
SET TrangThai = N'Hoàn thành'
WHERE MaDuAn = 10;

SELECT * FROM BaoCaoDuAn;


-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.
-- Thêm các bảng bổ sung cần thiết
CREATE TABLE CongTyThongKe (
    MaCongTy INT PRIMARY KEY,
    ThuHang INT,
    SoDuAnHoanThanh INT DEFAULT 0,
    DiemDanhGia FLOAT DEFAULT 0,
    TyLeThanhCong FLOAT DEFAULT 0,
    SoChuyenGiaCapCao INT DEFAULT 0,
    FOREIGN KEY (MaCongTy) REFERENCES CongTy(MaCongTy)
);

CREATE TABLE ChuyenGiaThongKe (
    MaChuyenGia INT PRIMARY KEY,
    SoDuAnDangThucHien INT DEFAULT 0,
    FOREIGN KEY (MaChuyenGia) REFERENCES ChuyenGia(MaChuyenGia)
);

CREATE TABLE LogLuongChuyenGia (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    LuongCu DECIMAL(18,2),
    LuongMoi DECIMAL(18,2),
    NgayThayDoi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaChuyenGia) REFERENCES ChuyenGia(MaChuyenGia)
);

CREATE TRIGGER trg_CapNhatThuHangCongTy
ON DuAn
AFTER UPDATE
AS
BEGIN
    UPDATE CongTyThongKe
    SET ThuHang = Ranks.NewRank
    FROM (
        SELECT 
            MaCongTy,
            RANK() OVER (ORDER BY SoDuAnHoanThanh DESC, DiemDanhGia DESC) AS NewRank
        FROM CongTyThongKe
    ) Ranks
    WHERE CongTyThongKe.MaCongTy = Ranks.MaCongTy
END;

INSERT INTO CongTyThongKe (MaCongTy, ThuHang, SoDuAnHoanThanh, DiemDanhGia) VALUES
(1, 1, 5, 8.5),
(2, 2, 3, 7.5);

UPDATE CongTyThongKe
SET SoDuAnHoanThanh = 7
WHERE MaCongTy = 2;

SELECT * FROM CongTyThongKe ORDER BY ThuHang;



-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).
CREATE TRIGGER trg_ThongBaoThangCapChuyenGia
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    IF UPDATE(NamKinhNghiem)
    BEGIN
        DECLARE @MaChuyenGia INT, @NamKinhNghiemMoi INT
        SELECT @MaChuyenGia = i.MaChuyenGia, @NamKinhNghiemMoi = i.NamKinhNghiem
        FROM inserted i

        IF @NamKinhNghiemMoi >= 5
            PRINT N'Thông báo: Chuyên gia ' + CAST(@MaChuyenGia AS NVARCHAR(10)) + N' đã đủ điều kiện thăng cấp!'
    END
END;

UPDATE ChuyenGia
SET NamKinhNghiem = 5
WHERE MaChuyenGia = 1;

-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.
CREATE TRIGGER trg_CapNhatTrangThaiKhanCap
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE d
    SET TrangThai = N'Khẩn cấp'
    FROM DuAn d
    JOIN inserted i ON d.MaDuAn = i.MaDuAn
    WHERE DATEDIFF(day, GETDATE(), d.NgayKetThuc) <= 
          (DATEDIFF(day, d.NgayBatDau, d.NgayKetThuc) * 0.1)
END;

UPDATE DuAn
SET NgayKetThuc = DATEADD(day, 5, GETDATE())
WHERE MaDuAn = 1;

SELECT * FROM DuAn WHERE MaDuAn = 1;

-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.
CREATE TRIGGER trg_CapNhatSoDuAnDangThucHien
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE ChuyenGiaThongKe
    SET SoDuAnDangThucHien = (
        SELECT COUNT(*)
        FROM ChuyenGia_DuAn cda
        JOIN DuAn d ON cda.MaDuAn = d.MaDuAn
        WHERE cda.MaChuyenGia = ChuyenGiaThongKe.MaChuyenGia
        AND d.TrangThai = N'Đang thực hiện'
    )
END;

INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia) VALUES
(11, 1, N'Developer', GETDATE()),
(11, 2, N'Developer', GETDATE());

SELECT cg.HoTen, cgt.SoDuAnDangThucHien
FROM ChuyenGia cg
JOIN ChuyenGiaThongKe cgt ON cg.MaChuyenGia = 11;

-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.
CREATE TRIGGER trg_CapNhatTyLeThanhCong
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE CongTyThongKe
    SET TyLeThanhCong = (
        SELECT CAST(COUNT(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 END) AS FLOAT) /
               NULLIF(COUNT(*), 0) * 100
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTyThongKe.MaCongTy
    )
END;

UPDATE DuAn
SET TrangThai = N'Hoàn thành'
WHERE MaDuAn = 1;

SELECT c.TenCongTy, ct.TyLeThanhCong
FROM CongTy c
JOIN CongTyThongKe ct ON c.MaCongTy = ct.MaCongTy;

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.
CREATE TRIGGER trg_GhiLogThayDoiLuong
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Luong)
    BEGIN
        INSERT INTO LogLuongChuyenGia (MaChuyenGia, LuongCu, LuongMoi)
        SELECT d.MaChuyenGia, d.Luong, i.Luong
        FROM deleted d
        JOIN inserted i ON d.MaChuyenGia = i.MaChuyenGia
    END
END;

UPDATE ChuyenGia
SET Luong = 20000000
WHERE MaChuyenGia = 1;

SELECT * FROM LogLuongChuyenGia;


-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.
CREATE TRIGGER trg_CapNhatSoChuyenGiaCapCao
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE CongTyThongKe
    SET SoChuyenGiaCapCao = (
        SELECT COUNT(*)
        FROM ChuyenGia cg
        JOIN ChuyenGia_DuAn cda ON cg.MaChuyenGia = cda.MaChuyenGia
        JOIN DuAn d ON cda.MaDuAn = d.MaDuAn
        WHERE d.MaCongTy = CongTyThongKe.MaCongTy
        AND cg.NamKinhNghiem >= 5
    )
END;

UPDATE ChuyenGia
SET NamKinhNghiem = 6
WHERE MaChuyenGia = 1;

SELECT c.TenCongTy, ct.SoChuyenGiaCapCao
FROM CongTy c
JOIN CongTyThongKe ct ON c.MaCongTy = ct.MaCongTy;


-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.
CREATE TRIGGER trg_CapNhatTrangThaiNhanLuc
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE DuAn
    SET TrangThai = N'Cần bổ sung nhân lực'
    WHERE MaDuAn IN (
        SELECT d.MaDuAn
        FROM DuAn d
        LEFT JOIN ChuyenGia_DuAn cda ON d.MaDuAn = cda.MaDuAn
        GROUP BY d.MaDuAn
        HAVING COUNT(cda.MaChuyenGia) < 3 -- Giả sử mỗi dự án cần tối thiểu 3 chuyên gia
    )
END;

DELETE FROM ChuyenGia_DuAn
WHERE MaDuAn = 7;

SELECT * FROM DuAn WHERE TrangThai = N'Cần bổ sung nhân lực';
