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


-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE ChuyenGia_KyNang_Log (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    MaKyNang INT,
    ThaoTac NVARCHAR(50),
    ThoiGian DATETIME,
    CapDoCu INT,
    CapDoMoi INT
);

CREATE TRIGGER TR_ChuyenGia_KyNang_GhiLog
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    INSERT INTO ChuyenGia_KyNang_Log (MaChuyenGia, MaKyNang, ThaoTac, ThoiGian, CapDoCu, CapDoMoi)
    SELECT i.MaChuyenGia, i.MaKyNang, 'UPDATE', GETDATE(), d.CapDo, i.CapDo
    FROM inserted i
    INNER JOIN deleted d ON i.MaChuyenGia = d.MaChuyenGia AND i.MaKyNang = d.MaKyNang;
END;

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

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.

---
-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).

-- Tạo bảng ThongBao nếu chưa có


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

-- Tạo bảng ThongKeChuyenNganh nếu chưa có

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.

-- Tạo bảng DuAnHoanThanh nếu chưa có


-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.



-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.



-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.



-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.
CREATE TRIGGER TR_ChuyenGia_KyNang_TrungLap
ON ChuyenGia_KyNang
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM ChuyenGia_KyNang 
        WHERE MaChuyenGia = (SELECT MaChuyenGia FROM inserted) 
          AND MaKyNang = (SELECT MaKyNang FROM inserted)
    )
    BEGIN
        RAISERROR('Chuyên gia này đã có kỹ năng này.', 16, 1)
        ROLLBACK TRANSACTION
    END
END;


-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.


-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.



-- 133. (tiếp tục) Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.


-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).


-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.


-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.


-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.


-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.


