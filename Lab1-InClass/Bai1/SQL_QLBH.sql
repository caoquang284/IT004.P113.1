CREATE TABLE KHACHHANG (
    MAKH char(4) PRIMARY KEY,
    HOTEN varchar(40),
    DIACHI varchar(50),
    SODT varchar(20),
    NGSINH smalldatetime,
    NGDK smalldatetime,
    DOANHSO money
);

CREATE TABLE NHANVIEN (
    MANV char(4) PRIMARY KEY,
    HOTEN varchar(40),
    SODT varchar(20),
    NGVL smalldatetime
);

CREATE TABLE SANPHAM (
    MASP char(4) PRIMARY KEY,
    TENSP varchar(40),
    DVT varchar(20),
    NUOCSX varchar(20),
    GIA money
);

CREATE TABLE HOADON (
    SOHD int PRIMARY KEY,
    NGHD smalldatetime,
    MAKH char(4) FOREIGN KEY REFERENCES KHACHHANG(MAKH),
    MANV char(4) FOREIGN KEY REFERENCES NHANVIEN(MANV),
    TRIGIA money
);

CREATE TABLE CTHD (
    SOHD int FOREIGN KEY REFERENCES HOADON(SOHD),
    MASP char(4) FOREIGN KEY REFERENCES SANPHAM(MASP),
    SL int,
    PRIMARY KEY (SOHD, MASP) 
);


