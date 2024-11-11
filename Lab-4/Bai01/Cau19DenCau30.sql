--19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(*) AS SoHoaDon
FROM HOADON HD
WHERE NOT EXISTS (
    SELECT 1
    FROM KHACHHANG KH
    WHERE HD.MAKH = KH.MAKH
);

--20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT MASP) AS SoSanPhamKhacNhau
FROM CTHD CT
JOIN HOADON HD ON CT.SOHD = HD.SOHD
WHERE YEAR(HD.NGHD) = 2006;

--21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
SELECT MAX(TRIGIA) AS TriGiaCaoNhat, MIN(TRIGIA) AS TriGiaThapNhat
FROM HOADON;

--22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) AS TriGiaTrungBinh
FROM HOADON
WHERE YEAR(NGHD) = 2006;

--23. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) AS DoanhThu
FROM HOADON
WHERE YEAR(NGHD) = 2006;

--24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD
FROM HOADON
WHERE TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006)
AND YEAR(NGHD) = 2006;

--25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT KH.HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE HD.TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON WHERE YEAR(NGHD) = 2006)
AND YEAR(HD.NGHD) = 2006;

--26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT TOP 3 MAKH, HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC;

--27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP
FROM SANPHAM
WHERE GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

--28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' AND GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM WHERE NUOCSX = 'Trung Quoc' ORDER BY GIA DESC);

--30. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 MAKH, HOTEN, DOANHSO, RANK() OVER (ORDER BY DOANHSO DESC) AS XepHang
FROM KHACHHANG;