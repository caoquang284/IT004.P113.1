--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN 
FROM HOCVIEN HV JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
WHERE KQ.DIEM >= 9
GROUP BY HV.MAHV, HV.HO + ' ' + HV.TEN    
HAVING COUNT(MAMH) >= ALL (SELECT COUNT(MAMH)
                          FROM KETQUATHI
                          WHERE DIEM >= 9
                          GROUP BY MAHV);

--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT MALOP, HV.MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
WHERE KQ.DIEM >= 9
GROUP BY MALOP, HV.MAHV, HO + ' ' + TEN
HAVING COUNT(MAMH) >= ALL (SELECT COUNT(MAMH)
                          FROM KETQUATHI KQ2 JOIN HOCVIEN HV2 ON KQ2.MAHV = HV2.MAHV
                          WHERE KQ2.DIEM >= 9 AND HV2.MALOP = HV.MALOP
                          GROUP BY HV2.MAHV);

--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT HOCKY, NAM, MAGV, COUNT(DISTINCT MAMH) AS SoMonHoc, COUNT(DISTINCT MALOP) AS SoLop
FROM GIANGDAY
GROUP BY HOCKY, NAM, MAGV;

--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT GD.HOCKY, GD.NAM, GD.MAGV, GV.HOTEN, COUNT(*) AS SoLuongMonHoc
FROM GIANGDAY GD
JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
GROUP BY GD.HOCKY, GD.NAM, GD.MAGV, GV.HOTEN
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM GIANGDAY GD2
                        WHERE GD2.HOCKY = GD.HOCKY AND GD2.NAM = GD.NAM
                        GROUP BY GD2.MAGV);

--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT MH.MAMH, TENMH
FROM MONHOC MH JOIN KETQUATHI KQ ON MH.MAMH = KQ.MAMH
WHERE KQ.LANTHI = 1 AND KQ.KQUA = 'Khong Dat'
GROUP BY MH.MAMH, TENMH
HAVING COUNT(MAHV) >= ALL (SELECT COUNT(MAHV)
                            FROM KETQUATHI
                            WHERE LANTHI = 1 AND KQUA = 'Khong Dat'
                            GROUP BY MAMH);

--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE NOT EXISTS (SELECT 1
                  FROM KETQUATHI
                  WHERE MAHV = HOCVIEN.MAHV AND LANTHI = 1 AND KQUA = 'Khong Dat');

--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV
WHERE NOT EXISTS (SELECT 1
                  FROM KETQUATHI KQ1
                  WHERE KQ1.MAHV = HV.MAHV 
                  AND KQ1.LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI KQ2 WHERE KQ2.MAHV = KQ1.MAHV AND KQ2.MAMH = KQ1.MAMH) 
                  AND KQ1.KQUA = 'Khong Dat');

--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (SELECT MAHV
                FROM KETQUATHI
                WHERE LANTHI = 1 AND KQUA = 'Dat'
                GROUP BY MAHV
                HAVING COUNT(DISTINCT MAMH) = (SELECT COUNT(*) FROM MONHOC));

--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng).
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN HV
WHERE MAHV IN (SELECT KQ1.MAHV
                FROM KETQUATHI KQ1
                WHERE KQ1.LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI KQ2 WHERE KQ2.MAHV = KQ1.MAHV AND KQ2.MAMH = KQ1.MAMH) AND KQ1.KQUA = 'Dat'
                GROUP BY KQ1.MAHV
                HAVING COUNT(DISTINCT KQ1.MAMH) = (SELECT COUNT(*) FROM MONHOC));

--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).
SELECT MH.MAMH, MH.TENMH, HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, MAX(KQ.DIEM) AS DiemCaoNhat
FROM MONHOC MH
JOIN KETQUATHI KQ ON MH.MAMH = KQ.MAMH
JOIN HOCVIEN HV ON KQ.MAHV = HV.MAHV
WHERE KQ.LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI KQ2 WHERE KQ2.MAHV = KQ.MAHV AND KQ2.MAMH = KQ.MAMH)
GROUP BY MH.MAMH, MH.TENMH, HV.MAHV, HV.HO + ' ' + HV.TEN;
