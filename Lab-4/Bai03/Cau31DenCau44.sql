--31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(*) AS TotalProducts
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

--32. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX AS Country, COUNT(*) AS TotalProducts
FROM SANPHAM
GROUP BY NUOCSX;

--33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX AS Country,
       MAX(GIA) AS MaxPrice,
       MIN(GIA) AS MinPrice,
       AVG(GIA) AS AvgPrice
FROM SANPHAM
GROUP BY NUOCSX;

--34. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD AS SaleDate,
       SUM(TRIGIA) AS DailyRevenue
FROM HOADON
GROUP BY NGHD;

--35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT CTHD.MASP AS ProductID,
       SUM(CTHD.SL) AS TotalQuantity
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE MONTH(HOADON.NGHD) = 10 AND YEAR(HOADON.NGHD) = 2006
GROUP BY CTHD.MASP;

--36. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) AS Month,
       SUM(TRIGIA) AS MonthlyRevenue
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD);

--37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD AS InvoiceID
FROM CTHD
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) >= 4;

--38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT CTHD.SOHD AS InvoiceID
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE SANPHAM.NUOCSX = 'Viet Nam'
GROUP BY CTHD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3;

--39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
SELECT MAKH, HOTEN
FROM KHACHHANG
WHERE MAKH IN (SELECT MAKH FROM HOADON GROUP BY MAKH HAVING COUNT(*)  >= ALL (SELECT COUNT(*) FROM HOADON GROUP BY MAKH));

--40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT MONTH(NGHD) AS ThangCoDoanhSoCaoNhat
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
HAVING SUM(TRIGIA) >= ALL (
    SELECT SUM(TRIGIA)
    FROM HOADON
    WHERE YEAR(NGHD) = 2006
    GROUP BY MONTH(NGHD)
);

--41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP IN (SELECT MASP FROM CTHD JOIN HOADON ON CTHD.SOHD = HOADON.SOHD WHERE YEAR(NGHD) = 2006 GROUP BY MASP HAVING sum(SL) <= ALL (SELECT sum(SL) FROM CTHD JOIN HOADON ON CTHD.SOHD = HOADON.SOHD WHERE YEAR(NGHD) = 2006 GROUP BY MASP));

--42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT MASP, TENSP
FROM SANPHAM sp1
WHERE GIA = (SELECT MAX(GIA) FROM SANPHAM sp2 WHERE sp1.NUOCSX = sp2.NUOCSX)
GROUP BY NUOCSX, MASP, TENSP;

--43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX AS Country
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

--44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT MAKH, HOTEN
FROM KHACHHANG
WHERE MAKH IN (SELECT TOP 10 MAKH FROM HOADON GROUP BY MAKH ORDER BY SUM(TRIGIA) DESC)
GROUP BY MAKH, HOTEN
HAVING COUNT(MAKH) >= ALL (
    SELECT COUNT(MAKH)
    FROM KHACHHANG
    WHERE MAKH IN (SELECT TOP 10 MAKH FROM HOADON GROUP BY MAKH ORDER BY SUM(TRIGIA) DESC)
    GROUP BY MAKH
);

