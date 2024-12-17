--9. Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER TR_KiemTraLopTruong
ON LOP
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i 
               WHERE i.MAGVCN NOT IN (SELECT MAHV FROM HOCVIEN WHERE MALOP = i.MALOP))
    BEGIN
        RAISERROR('Lớp trưởng phải là học viên của lớp.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER TR_KiemTraTruongKhoa
ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i 
               WHERE i.TRGKHOA NOT IN (SELECT MAGV FROM GIAOVIEN WHERE MAKHOA = i.MAKHOA AND HOTEN LIKE '%TS' OR HOTEN LIKE '%PTS'))
    BEGIN
        RAISERROR('Trưởng khoa phải là giáo viên thuộc khoa và có học vị "TS" hoặc "PTS".', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này. 
CREATE TRIGGER TR_KiemTraHocVienThi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN HOCVIEN hv ON i.MAHV = hv.MAHV
               WHERE NOT EXISTS (SELECT 1 
                                 FROM GIANGDAY gd 
                                 WHERE gd.MALOP = hv.MALOP AND gd.MAMH = i.MAMH AND gd.DENNGAY < i.NGTHI))
    BEGIN
        RAISERROR('Học viên chỉ được thi khi lớp đã học xong môn học.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn. 
CREATE TRIGGER TR_KiemTraSo_MonHoc
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM GIANGDAY 
               WHERE MALOP IN (SELECT DISTINCT MALOP FROM inserted)
               GROUP BY MALOP, HOCKY, NAM
               HAVING COUNT(*) > 3)
    BEGIN
        RAISERROR('Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

DROP TRIGGER TR_KiemTraLopTruong
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. 
CREATE TRIGGER TR_CapNhatSiSo_Lop
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = LOP.MALOP)
    WHERE MALOP IN (SELECT DISTINCT MALOP FROM inserted);
END;

--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). 
CREATE TRIGGER TR_KiemTraDieuKien
ON DIEUKIEN
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE MAMH = MAMH_TRUOC)
    BEGIN
        RAISERROR('MAMH và MAMH_TRUOC không được giống nhau.', 16, 1)
        ROLLBACK TRANSACTION
    END;

    IF EXISTS (SELECT 1 
               FROM inserted i1 JOIN inserted i2 ON i1.MAMH = i2.MAMH_TRUOC AND i1.MAMH_TRUOC = i2.MAMH)
    BEGIN
        RAISERROR('Không tồn tại hai bộ ("A","B") và ("B","A").', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau. 
CREATE TRIGGER TR_CapNhatMucLuong
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE GIAOVIEN 
    SET MUCLUONG = (SELECT TOP 1 MUCLUONG 
                     FROM GIAOVIEN 
                     WHERE HOCVI = i.HOCVI AND HOCHAM = i.HOCHAM AND HESO = i.HESO)
    FROM inserted i
    WHERE GIAOVIEN.MAGV = i.MAGV;
END;

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5. 
CREATE TRIGGER TR_KiemTraThiLai
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN KETQUATHI kq ON i.MAHV = kq.MAHV AND i.MAMH = kq.MAMH
               WHERE i.LANTHI > 1 AND kq.LANTHI = i.LANTHI - 1 AND kq.DIEM >= 5)
    BEGIN
        RAISERROR('Học viên chỉ được thi lại khi điểm lần thi trước đó dưới 5.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học). 
CREATE TRIGGER TR_KiemTraNgayThi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN KETQUATHI kq ON i.MAHV = kq.MAHV AND i.MAMH = kq.MAMH
               WHERE i.LANTHI > 1 AND kq.LANTHI = i.LANTHI - 1 AND i.NGTHI <= kq.NGTHI)
    BEGIN
        RAISERROR('Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--22. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau).
CREATE TRIGGER TR_KiemTraThuTuMonHoc
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN DIEUKIEN dk ON i.MAMH = dk.MAMH
               WHERE NOT EXISTS (SELECT 1 
                                 FROM GIANGDAY gd 
                                 WHERE gd.MALOP = i.MALOP AND gd.MAMH = dk.MAMH_TRUOC AND gd.DENNGAY < i.TUNGAY))
    BEGIN
        RAISERROR('Phải học xong môn học trước mới được học môn liền sau.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--23. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER TR_KiemTraPhanCongGiangDay
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN GIAOVIEN gv ON i.MAGV = gv.MAGV JOIN MONHOC mh ON i.MAMH = mh.MAMH
               WHERE gv.MAKHOA <> mh.MAKHOA)
    BEGIN
        RAISERROR('Giáo viên chỉ được dạy môn thuộc khoa mình phụ trách.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;