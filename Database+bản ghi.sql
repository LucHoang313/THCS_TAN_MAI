create database QL_THCSTanMai

use QL_THCSTanMai

--tạo bảng lớp học
CREATE TABLE LOPHOC (
    sMaLop VARCHAR(10) PRIMARY KEY,
    sTenLop NVARCHAR(50),
    sKhoi NVARCHAR(10)
);

-- tạo bảng môn học
CREATE TABLE MONHOC (
    sMaMH VARCHAR(10) PRIMARY KEY,
    sTenMH NVARCHAR(100)
);

--tạo bảng học sinh
CREATE TABLE HOCSINH (
    sMaHS VARCHAR(10) PRIMARY KEY,
    sHoTen NVARCHAR(100),
    dNgaySinh DATE,
    sGioiTinh NVARCHAR(10),
    sDiaChi NVARCHAR(200),
    sTenLop NVARCHAR(50)
);

-- tạo bảng giáo viên
CREATE TABLE GIAOVIEN (
    sMaGV VARCHAR(10) PRIMARY KEY,
    sHoTen NVARCHAR(100),
    dNgaySinh DATE,
    sGioiTinh NVARCHAR(10),
    sDiaChi NVARCHAR(200),
    sSDT VARCHAR(15),
    sChuyenMon NVARCHAR(100)
);

-- tạo bảng điểm
CREATE TABLE DIEM (
    sMaDiem VARCHAR(10) PRIMARY KEY,
    sMaHS VARCHAR(10),
    sMaMH VARCHAR(10),
    fDiemKiemTra FLOAT,
    fDiemGiuaKy FLOAT,
    fDiemCuoiKy FLOAT,
    FOREIGN KEY (sMaHS) REFERENCES HOCSINH(sMaHS),
    FOREIGN KEY (sMaMH) REFERENCES MONHOC(sMaMH)
);

-- tạo bảng thời khóa biểu
CREATE TABLE THOIKHOABIEU (
    sMaTKB VARCHAR(10) PRIMARY KEY,
    sMaLop VARCHAR(10),
    sMaMH VARCHAR(10),
    sMaGV VARCHAR(10),
    dNgay DATE,
    sGio TIME,
    FOREIGN KEY (sMaLop) REFERENCES LOPHOC(sMaLop),
    FOREIGN KEY (sMaMH) REFERENCES MONHOC(sMaMH),
    FOREIGN KEY (sMaGV) REFERENCES GIAOVIEN(sMaGV)
);


--THÊM CÁC BẢN GHI
-- =============================================
-- BẢNG MONHOC
-- Quy tắc đặt mã: [Mã ban 2 ký tự][3 số]
-- VD: TN001 - Ban Tự nhiên, môn số 001
-- =============================================

-- Ban Tự nhiên (TN): Các môn khoa học tự nhiên
INSERT INTO MONHOC VALUES ('TN001', N'Toán học');    
INSERT INTO MONHOC VALUES ('TN002', N'Vật lý');      
INSERT INTO MONHOC VALUES ('TN003', N'Hóa học');     
INSERT INTO MONHOC VALUES ('TN004', N'Sinh học');    

-- Ban Xã hội (XH): Các môn khoa học xã hội
INSERT INTO MONHOC VALUES ('XH001', N'Ngữ văn');     
INSERT INTO MONHOC VALUES ('XH002', N'Lịch sử');     
INSERT INTO MONHOC VALUES ('XH003', N'Địa lý');      
INSERT INTO MONHOC VALUES ('XH004', N'Giáo dục công dân'); 

-- Ban Ngoại ngữ (NN): Các môn ngoại ngữ
INSERT INTO MONHOC VALUES ('NN001', N'Tiếng Anh');   
INSERT INTO MONHOC VALUES ('NN002', N'Tiếng Pháp');  

-- Ban Nghệ thuật (NT): Các môn nghệ thuật
INSERT INTO MONHOC VALUES ('NT001', N'Âm nhạc');     
INSERT INTO MONHOC VALUES ('NT002', N'Mỹ thuật');    

-- Ban Tin học (TH): Môn Tin học
INSERT INTO MONHOC VALUES ('TH001', N'Tin học');     

-- Ban Thể dục (TD): Môn Thể dục
INSERT INTO MONHOC VALUES ('TD001', N'Thể dục');     

select * from dbo.MONHOC

-- =============================================
-- BẢNG LOPHOC
-- Quy tắc đặt mã: K[Khóa][Khối][Lớp]
-- VD: K506A - Khóa 50, lớp 6A
-- =============================================

-- Khối 6 (Khóa 50 - Năm học 2024-2025)
INSERT INTO LOPHOC VALUES ('K506A', N'6A', N'Khối 6');  -- Lớp 6A khóa 50
INSERT INTO LOPHOC VALUES ('K506B', N'6B', N'Khối 6');  -- Lớp 6B khóa 50
INSERT INTO LOPHOC VALUES ('K506C', N'6C', N'Khối 6');  -- Lớp 6C khóa 50
INSERT INTO LOPHOC VALUES ('K506D', N'6D', N'Khối 6');  -- Lớp 6D khóa 50
INSERT INTO LOPHOC VALUES ('K506E', N'6E', N'Khối 6');  -- Lớp 6E khóa 50

-- Khối 7 (Khóa 49 - Năm học 2023-2024)
INSERT INTO LOPHOC VALUES ('K497A', N'7A', N'Khối 7');  -- Lớp 7A khóa 49
INSERT INTO LOPHOC VALUES ('K497B', N'7B', N'Khối 7');  -- Lớp 7B khóa 49
INSERT INTO LOPHOC VALUES ('K497C', N'7C', N'Khối 7');  -- Lớp 7C khóa 49
INSERT INTO LOPHOC VALUES ('K497D', N'7D', N'Khối 7');  -- Lớp 7D khóa 49
INSERT INTO LOPHOC VALUES ('K497E', N'7E', N'Khối 7');  -- Lớp 7E khóa 49

-- Khối 8 (Khóa 48 - Năm học 2022-2023)
INSERT INTO LOPHOC VALUES ('K488A', N'8A', N'Khối 8');  -- Lớp 8A khóa 48
INSERT INTO LOPHOC VALUES ('K488B', N'8B', N'Khối 8');  -- Lớp 8B khóa 48
INSERT INTO LOPHOC VALUES ('K488C', N'8C', N'Khối 8');  -- Lớp 8C khóa 48
INSERT INTO LOPHOC VALUES ('K488D', N'8D', N'Khối 8');  -- Lớp 8D khóa 48
INSERT INTO LOPHOC VALUES ('K488E', N'8E', N'Khối 8');  -- Lớp 8E khóa 48

-- Khối 9 (Khóa 47 - Năm học 2021-2022)
INSERT INTO LOPHOC VALUES ('K479A', N'9A', N'Khối 9');  -- Lớp 9A khóa 47
INSERT INTO LOPHOC VALUES ('K479B', N'9B', N'Khối 9');  -- Lớp 9B khóa 47
INSERT INTO LOPHOC VALUES ('K479C', N'9C', N'Khối 9');  -- Lớp 9C khóa 47
INSERT INTO LOPHOC VALUES ('K479D', N'9D', N'Khối 9');  -- Lớp 9D khóa 47
INSERT INTO LOPHOC VALUES ('K479E', N'9E', N'Khối 9');  -- Lớp 9E khóa 47

select * from dbo.LOPHOC

-- =============================================
-- BẢNG GIAOVIEN
-- Quy tắc đặt mã: [Mã ban][3 số]
-- VD: TN261 - Giáo viên ban Tự nhiên số 261
-- =============================================

-- Giáo viên Ban Tự nhiên (TN)
INSERT INTO GIAOVIEN VALUES 
    ('TN261', N'Nguyễn Thị Mai',     -- Giáo viên Toán
    '1985-03-15',                     -- Ngày sinh: 15/03/1985
    N'Nữ',                            -- Giới tính: Nữ
    N'237 Tam Trinh, Hoàng Mai, Hà Nội',   -- Địa chỉ nhà riêng
    '0901234567',                     -- Số điện thoại di động
    N'Toán học');                     -- Chuyên môn: Toán

INSERT INTO GIAOVIEN VALUES 
    ('TN262', N'Trần Văn Minh',      -- Giáo viên Vật lý
    '1982-07-20', N'Nam',            -- Nam, sinh ngày 20/07/1982
    N'56 Tân Mai, Hoàng Mai, Hà Nội', 
    '0912345678', 
    N'Vật lý');

select * from dbo.GIAOVIEN
-- =============================================
-- BẢNG HOCSINH
-- Quy tắc đặt mã: K[Khóa][Năm nhập học][3 số]
-- VD: K502024001 - Khóa 50, nhập học 2024, học sinh số 001
-- =============================================

-- Học sinh Khối 6 (Khóa 50 - Nhập học 2024)
INSERT INTO HOCSINH VALUES 
    ('K502024001',                    -- Mã HS: Khóa 50, năm 2024, số 001
    N'Nguyễn Văn An',                 -- Họ tên học sinh
    '2013-05-15',                     -- Ngày sinh: 15/05/2013 (11 tuổi)
    N'Nam',                           -- Giới tính: Nam
    N'23 Trương Định, Hoàng Mai, Hà Nội',     -- Địa chỉ thường trú
    N'6A');                           -- Lớp 6A

select * from dbo.HOCSINH

-- =============================================
-- BẢNG DIEM
-- Quy tắc đặt mã: [Viết tắt môn][K][Khóa][Lớp][3 số]
-- VD: TOK506A001 - Toán, Khóa 50, lớp 9A, học sinh 001
-- =============================================

-- Điểm môn Toán
INSERT INTO DIEM VALUES 
    ('TOK506A001',                    -- Mã điểm Toán
    'K502024001',                     -- Mã học sinh
    'TN001',                          -- Mã môn học (Toán)
    8.5,                              -- Điểm kiểm tra
    7.5,                              -- Điểm giữa kỳ
    8.0);                             -- Điểm cuối kỳ

select * from dbo.DIEM

-- =============================================
-- BẢNG THOIKHOABIEU
-- Quy tắc đặt mã: TKB[Lớp][Khóa][3 số]
-- VD: TKB6A50001 - TKB lớp 6A, khóa 50, tiết 001
-- =============================================

-- Thời khóa biểu lớp 6A
INSERT INTO THOIKHOABIEU VALUES 
    ('TKB6A50001',                    -- Mã TKB: lớp 6A, khóa 50, tiết 001
    'K506A',                          -- Mã lớp 6A
    'TN001',                          -- Mã môn học (Toán)
    'TN261',                          -- Mã giáo viên dạy
    '2024-02-05',                     -- Ngày học: 05/02/2024
    '07:30:00');                      -- Giờ học: 7:30
select * from THOIKHOABIEU