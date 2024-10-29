
-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo
FROM KyNang k
JOIN ChuyenGia_KyNang ck ON k.MaKyNang = ck.MaKyNang
WHERE ck.MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_DuAn cd ON cg.MaChuyenGia = cd.MaChuyenGia
WHERE cd.MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(*) AS SoLuongChuyenGia
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT TOP 1 *
FROM ChuyenGia
ORDER BY NamKinhNghiem DESC

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT cg.HoTen, COUNT(cda.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cda ON cg.MaChuyenGia = cda.MaChuyenGia
GROUP BY cg.HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT ct.TenCongTy, COUNT(da.MaDuAn) AS SoLuongDuAn
FROM CongTy ct
LEFT JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
GROUP BY ct.TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT kn.TenKyNang
FROM KyNang kn
JOIN ChuyenGia_KyNang cgkn ON kn.MaKyNang = cgkn.MaKyNang
GROUP BY kn.TenKyNang
HAVING COUNT(cgkn.MaChuyenGia) = (
    SELECT MAX(SoLuongChuyenGia)
    FROM (
        SELECT MaKyNang, COUNT(MaChuyenGia) AS SoLuongChuyenGia
        FROM ChuyenGia_KyNang
        GROUP BY MaKyNang
    ) AS SoLuongChuyenGiaTheoKyNang
);

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
JOIN KyNang kn ON cgkn.MaKyNang = kn.MaKyNang
WHERE kn.TenKyNang = 'Python' AND cgkn.CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT da.TenDuAn
FROM DuAn da
JOIN ChuyenGia_DuAn cda ON da.MaDuAn = cda.MaDuAn
GROUP BY da.TenDuAn
HAVING COUNT(cda.MaChuyenGia) = (
    SELECT MAX(SoLuongChuyenGia)
    FROM (
        SELECT MaDuAn, COUNT(MaChuyenGia) AS SoLuongChuyenGia
        FROM ChuyenGia_DuAn
        GROUP BY MaDuAn
    ) AS SoLuongChuyenGiaTheoDuAn
);

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT cg.HoTen, COUNT(cgkn.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
GROUP BY cg.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, da.TenDuAn
FROM ChuyenGia cg1
JOIN ChuyenGia_DuAn cda1 ON cg1.MaChuyenGia = cda1.MaChuyenGia
JOIN ChuyenGia_DuAn cda2 ON cda1.MaDuAn = cda2.MaDuAn
JOIN ChuyenGia cg2 ON cda2.MaChuyenGia = cg2.MaChuyenGia
JOIN DuAn da ON cda1.MaDuAn = da.MaDuAn
WHERE cg1.MaChuyenGia < cg2.MaChuyenGia;

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT cg.HoTen, COUNT(cgkn.MaKyNang) AS SoLuongKyNangCapDo5
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
WHERE cgkn.CapDo = 5
GROUP BY cg.HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT ct.TenCongTy
FROM CongTy ct
LEFT JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
WHERE da.MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT cg.HoTen, da.TenDuAn
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cda ON cg.MaChuyenGia = cda.MaChuyenGia
LEFT JOIN DuAn da ON cda.MaDuAn = da.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
GROUP BY cg.HoTen
HAVING COUNT(cgkn.MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT ct.TenCongTy, SUM(cg.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
JOIN ChuyenGia_DuAn cda ON da.MaDuAn = cda.MaDuAn
JOIN ChuyenGia cg ON cda.MaChuyenGia = cg.MaChuyenGia
GROUP BY ct.TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
JOIN KyNang kn ON cgkn.MaKyNang = kn.MaKyNang
WHERE kn.TenKyNang = 'Java'
EXCEPT
SELECT cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
JOIN KyNang kn ON cgkn.MaKyNang = kn.MaKyNang
WHERE kn.TenKyNang = 'Python';

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT TOP 1 WITH TIES cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang cgkn ON cg.MaChuyenGia = cgkn.MaChuyenGia
GROUP BY cg.HoTen
ORDER BY COUNT(cgkn.MaKyNang) DESC;

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2
FROM ChuyenGia cg1
JOIN ChuyenGia cg2 ON cg1.ChuyenNganh = cg2.ChuyenNganh
WHERE cg1.MaChuyenGia < cg2.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 WITH TIES ct.TenCongTy
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
JOIN ChuyenGia_DuAn cda ON da.MaDuAn = cda.MaDuAn
JOIN ChuyenGia cg ON cda.MaChuyenGia = cg.MaChuyenGia
GROUP BY ct.TenCongTy
ORDER BY SUM(cg.NamKinhNghiem) DESC;

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT kn.TenKyNang
FROM KyNang kn
JOIN ChuyenGia_KyNang cgkn ON kn.MaKyNang = cgkn.MaKyNang
GROUP BY kn.TenKyNang
HAVING COUNT(DISTINCT cgkn.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);