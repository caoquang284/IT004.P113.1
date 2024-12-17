--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER TR_KiemTraNGHD_NGDK
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN KHACHHANG k ON i.MAKH = k.MAKH
               WHERE i.NGHD < k.NGDK)
    BEGIN
        RAISERROR('Ngày mua hàng phải lớn hơn hoặc bằng ngày đăng ký thành viên.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm. 
CREATE TRIGGER TR_KiemTraNGHD_NGVL
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted i JOIN NHANVIEN nv ON i.MANV = nv.MANV
               WHERE i.NGHD < nv.NGVL)
    BEGIN
        RAISERROR('Ngày mua hàng phải lớn hơn hoặc bằng ngày vào làm của nhân viên.', 16, 1)
        ROLLBACK TRANSACTION
    END;
END;

--13. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó. 
CREATE TRIGGER TR_CapNhatTriGia
ON CTHD
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE HOADON
    SET TRIGIA = (SELECT SUM(SL * GIA) 
                   FROM CTHD JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP 
                   WHERE CTHD.SOHD = HOADON.SOHD)
    WHERE SOHD IN (SELECT DISTINCT SOHD FROM inserted UNION ALL SELECT DISTINCT SOHD FROM deleted);
END;

--14. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.
CREATE TRIGGER TR_CapNhatDoanhSo
ON HOADON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE KHACHHANG
    SET DOANHSO = (SELECT SUM(TRIGIA) FROM HOADON WHERE HOADON.MAKH = KHACHHANG.MAKH)
    WHERE MAKH IN (SELECT DISTINCT MAKH FROM inserted UNION ALL SELECT DISTINCT MAKH FROM deleted);
END;

