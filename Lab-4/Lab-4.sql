-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 
    ChuyenGia.HoTen,
    COUNT(ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
LEFT JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT a.HoTen AS ChuyenGia1, b.HoTen AS ChuyenGia2, a.ChuyenNganh
FROM ChuyenGia a
JOIN ChuyenGia b ON a.ChuyenNganh = b.ChuyenNganh AND a.MaChuyenGia < b.MaChuyenGia
WHERE ABS(a.NamKinhNghiem - b.NamKinhNghiem) <= 2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT 
    CongTy.TenCongTy,
    COUNT(DISTINCT DuAn.MaDuAn) AS SoLuongDuAn,
    SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
LEFT JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
LEFT JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.MaCongTy, CongTy.TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT DISTINCT ChuyenGia.HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE ChuyenGia.MaChuyenGia IN (
    SELECT MaChuyenGia
    FROM ChuyenGia_KyNang
    WHERE CapDo = 5
)
AND ChuyenGia.MaChuyenGia NOT IN (
    SELECT MaChuyenGia
    FROM ChuyenGia_KyNang
    WHERE CapDo < 3
);

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen;

-- 81. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
WITH RankedSkills AS (
    SELECT 
        ChuyenGia.HoTen,
        KyNang.LoaiKyNang,
        ChuyenGia_KyNang.CapDo,
        ROW_NUMBER() OVER (PARTITION BY KyNang.LoaiKyNang ORDER BY ChuyenGia_KyNang.CapDo DESC) AS Rank
    FROM ChuyenGia
    JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
    JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
)
SELECT HoTen, LoaiKyNang, CapDo
FROM RankedSkills
WHERE Rank = 1;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
WITH ChuyenNganhCount AS (
    SELECT ChuyenNganh, COUNT(*) AS SoLuong
    FROM ChuyenGia
    GROUP BY ChuyenNganh
),
TotalCount AS (
    SELECT COUNT(*) AS TongSo
    FROM ChuyenGia
)
SELECT 
    ChuyenNganhCount.ChuyenNganh,
    ChuyenNganhCount.SoLuong,
    CAST(ChuyenNganhCount.SoLuong AS FLOAT) / TotalCount.TongSo * 100 AS PhanTram
FROM ChuyenNganhCount, TotalCount;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
WITH SkillPairs AS (
    SELECT 
        CKN1.MaKyNang AS Skill1,
        CKN2.MaKyNang AS Skill2,
        COUNT(*) AS Frequency
    FROM ChuyenGia_KyNang CKN1
    JOIN ChuyenGia_KyNang CKN2 ON CKN1.MaChuyenGia = CKN2.MaChuyenGia AND CKN1.MaKyNang < CKN2.MaKyNang
    GROUP BY CKN1.MaKyNang, CKN2.MaKyNang
)
SELECT TOP 5
    K1.TenKyNang AS Skill1,
    K2.TenKyNang AS Skill2,
    SkillPairs.Frequency
FROM SkillPairs
JOIN KyNang K1 ON SkillPairs.Skill1 = K1.MaKyNang
JOIN KyNang K2 ON SkillPairs.Skill2 = K2.MaKyNang
ORDER BY SkillPairs.Frequency DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT 
    CongTy.TenCongTy,
    AVG(DATEDIFF(day, DuAn.NgayBatDau, DuAn.NgayKetThuc)) AS TrungBinhSoNgay
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.MaCongTy, CongTy.TenCongTy;

-- 85. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
WITH UniqueSkills AS (
    SELECT 
        ChuyenGia.MaChuyenGia,
        ChuyenGia.HoTen,
        COUNT(*) AS SoLuongKyNangDocDao
    FROM ChuyenGia
    JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
    WHERE ChuyenGia_KyNang.MaKyNang NOT IN (
        SELECT DISTINCT MaKyNang
        FROM ChuyenGia_KyNang
        WHERE MaChuyenGia != ChuyenGia.MaChuyenGia
    )
    GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
)
SELECT TOP 1 HoTen, SoLuongKyNangDocDao
FROM UniqueSkills
ORDER BY SoLuongKyNangDocDao DESC;

-- 86. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
WITH ProjectCount AS (
    SELECT MaChuyenGia, COUNT(*) AS SoLuongDuAn
    FROM ChuyenGia_DuAn
    GROUP BY MaChuyenGia
),
SkillLevelSum AS (
    SELECT MaChuyenGia, SUM(CapDo) AS TongCapDoKyNang
    FROM ChuyenGia_KyNang
    GROUP BY MaChuyenGia
)
SELECT 
    ChuyenGia.HoTen,
    COALESCE(ProjectCount.SoLuongDuAn, 0) AS SoLuongDuAn,
    COALESCE(SkillLevelSum.TongCapDoKyNang, 0) AS TongCapDoKyNang,
    RANK() OVER (ORDER BY COALESCE(ProjectCount.SoLuongDuAn, 0) + COALESCE(SkillLevelSum.TongCapDoKyNang, 0) DESC) AS XepHang
FROM ChuyenGia
LEFT JOIN ProjectCount ON ChuyenGia.MaChuyenGia = ProjectCount.MaChuyenGia
LEFT JOIN SkillLevelSum ON ChuyenGia.MaChuyenGia = SkillLevelSum.MaChuyenGia;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
WITH DuAnChuyenNganh AS (
    SELECT 
        DuAn.MaDuAn,
        DuAn.TenDuAn,
        COUNT(DISTINCT ChuyenGia.ChuyenNganh) AS SoLuongChuyenNganh
    FROM DuAn
    JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
    JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
    GROUP BY DuAn.MaDuAn, DuAn.TenDuAn
),
TotalChuyenNganh AS (
    SELECT COUNT(DISTINCT ChuyenNganh) AS TongSoChuyenNganh
    FROM ChuyenGia
)
SELECT DuAnChuyenNganh.TenDuAn
FROM DuAnChuyenNganh, TotalChuyenNganh
WHERE DuAnChuyenNganh.SoLuongChuyenNganh = TotalChuyenNganh.TongSoChuyenNganh;

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
WITH DuAnStatus AS (
    SELECT 
        CongTy.MaCongTy,
        CongTy.TenCongTy,
        SUM(CASE WHEN DuAn.TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) AS SoDuAnHoanThanh,
        COUNT(*) AS TongSoDuAn
    FROM CongTy
    LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
    GROUP BY CongTy.MaCongTy, CongTy.TenCongTy
)
SELECT 
    TenCongTy,
    SoDuAnHoanThanh,
    TongSoDuAn,
    CASE 
        WHEN TongSoDuAn > 0 THEN CAST(SoDuAnHoanThanh AS FLOAT) / TongSoDuAn * 100 
        ELSE 0 
    END AS TyLeThanhCong
FROM DuAnStatus;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
WITH SkillLevels AS (
    SELECT
        CG.MaChuyenGia,
        CG.HoTen,
        CGK.MaKyNang,
        CGK.CapDo,
        ROW_NUMBER() OVER (PARTITION BY CG.MaChuyenGia ORDER BY CGK.CapDo DESC) AS SkillRank,
        ROW_NUMBER() OVER (PARTITION BY CG.MaChuyenGia ORDER BY CGK.CapDo ASC) AS ReverseSkillRank
    FROM ChuyenGia CG
    JOIN ChuyenGia_KyNang CGK ON CG.MaChuyenGia = CGK.MaChuyenGia
)
SELECT 
    A.HoTen AS ChuyenGia1,
    B.HoTen AS ChuyenGia2,
    KN1.TenKyNang AS KyNang1,
    KN2.TenKyNang AS KyNang2
FROM SkillLevels A
JOIN SkillLevels B ON A.MaChuyenGia <> B.MaChuyenGia AND A.MaKyNang = B.MaKyNang 
JOIN KyNang KN1 ON A.MaKyNang = KN1.MaKyNang
JOIN KyNang KN2 ON B.MaKyNang = KN2.MaKyNang
WHERE A.SkillRank = 1 AND B.ReverseSkillRank = 1 
AND EXISTS (
    SELECT 1
    FROM SkillLevels C
    WHERE C.MaChuyenGia = A.MaChuyenGia AND C.MaKyNang <> A.MaKyNang AND C.ReverseSkillRank = 1
    AND EXISTS (
        SELECT 1
        FROM SkillLevels D
        WHERE D.MaChuyenGia = B.MaChuyenGia AND D.MaKyNang = C.MaKyNang AND D.SkillRank = 1
    )
);