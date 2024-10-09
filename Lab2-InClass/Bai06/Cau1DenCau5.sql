SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, HV.NGSINH, L.MALOP
FROM HOCVIEN HV
JOIN LOP L ON HV.MAHV = L.TRGLOP;

SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, KQ.LANTHI, KQ.DIEM
FROM HOCVIEN HV
INNER JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
INNER JOIN MONHOC MH ON KQ.MAMH = MH.MAMH
WHERE MH.TENMH = 'Cau truc roi rac' AND HV.MALOP = 'K12'
ORDER BY HV.TEN, HV.HO;

SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN, MH.TENMH
FROM HOCVIEN HV
INNER JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
INNER JOIN MONHOC MH ON KQ.MAMH = MH.MAMH
WHERE KQ.LANTHI = 1 AND KQ.KQUA = 'Dat';

SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN
FROM HOCVIEN HV
INNER JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
INNER JOIN MONHOC MH ON KQ.MAMH = MH.MAMH
WHERE HV.MALOP = 'K11' AND MH.TENMH = 'Cau truc roi rac' AND KQ.LANTHI = 1 AND KQ.KQUA = 'Khong Dat';

SELECT HV.MAHV, HV.HO + ' ' + HV.TEN AS HOTEN
FROM HOCVIEN HV
INNER JOIN KETQUATHI KQ ON HV.MAHV = KQ.MAHV
INNER JOIN MONHOC MH ON KQ.MAMH = MH.MAMH
WHERE HV.MALOP LIKE 'K%' AND MH.TENMH = 'Cau truc roi rac' AND KQ.KQUA = 'Khong Dat'
GROUP BY HV.MAHV, HV.HO, HV.TEN
HAVING COUNT(KQ.MAHV) = (SELECT COUNT(*) FROM KETQUATHI KQ2 WHERE KQ2.MAHV = HV.MAHV AND KQ2.MAMH = 'CTRR');

