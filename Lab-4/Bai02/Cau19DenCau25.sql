--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT MAKHOA, TENKHOA
FROM KHOA
WHERE NGTLAP = (SELECT MIN(NGTLAP) FROM KHOA);

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(*)
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS');

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT K.MAKHOA, K.TENKHOA, 
       COUNT(CASE WHEN G.HOCVI = 'CN' THEN 1 END) AS SoLuong_CN,
       COUNT(CASE WHEN G.HOCVI = 'KS' THEN 1 END) AS SoLuong_KS,
       COUNT(CASE WHEN G.HOCVI = 'Ths' THEN 1 END) AS SoLuong_Ths,
       COUNT(CASE WHEN G.HOCVI = 'TS' THEN 1 END) AS SoLuong_TS,
       COUNT(CASE WHEN G.HOCVI = 'PTS' THEN 1 END) AS SoLuong_PTS
FROM GIAOVIEN G
JOIN KHOA K ON G.MAKHOA = K.MAKHOA
GROUP BY K.MAKHOA, K.TENKHOA;

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT MH.MAMH, MH.TENMH,
       COUNT(CASE WHEN KQ.DIEM >= 5 THEN 1 END) AS SoLuongDat,
       COUNT(CASE WHEN KQ.DIEM < 5 THEN 1 END) AS SoLuongKhongDat
FROM MONHOC MH
LEFT JOIN KETQUATHI KQ ON MH.MAMH = KQ.MAMH
GROUP BY MH.MAMH, MH.TENMH;

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT G.MAGV, G.HOTEN
FROM GIAOVIEN G
JOIN LOP L ON G.MAGV = L.MAGVCN
JOIN GIANGDAY GD ON L.MALOP = GD.MALOP AND G.MAGV = GD.MAGV
GROUP BY G.MAGV, G.HOTEN;

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HV.HO, HV.TEN
FROM HOCVIEN HV
JOIN LOP L ON HV.MAHV = L.TRGLOP
WHERE L.SISO = (SELECT MAX(SISO) FROM LOP);


--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).
SELECT hv.HO, hv.TEN
FROM HOCVIEN hv
JOIN LOP lp ON hv.MAHV = lp.TRGLOP
JOIN (
    SELECT MAHV, COUNT(DISTINCT MAMH) AS So_Mon_Thi_Khong_Dat
    FROM KETQUATHI
    WHERE KQUA = 'Không đạt'
    GROUP BY MAHV
    HAVING COUNT(DISTINCT MAMH) <= 3
) AS kq ON hv.MAHV = kq.MAHV;

