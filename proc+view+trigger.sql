use QL_THCSTanMai

--CÁC THỦ TỤC
-- 1. Thủ tục tính điểm trung bình học kỳ của học sinh
-- Input: Mã học sinh, Học kỳ (1 hoặc 2), Năm học
-- Output: Bảng điểm chi tiết và điểm trung bình
CREATE PROCEDURE spTinhDiemTrungBinh
    @MaHS varchar(10),
    @HocKy int,
    @NamHoc varchar(10)
AS
BEGIN
    -- Khai báo biến
    DECLARE @DiemTB float
    
    -- Tạo bảng tạm lưu hệ số môn học
    CREATE TABLE #HeSoMon (
        MaMH varchar(10),
        HeSo int
    )
    
    -- Gán hệ số cho các môn học
    INSERT INTO #HeSoMon VALUES
    ('TN001', 2), -- Toán (hệ số 2)
    ('XH001', 2), -- Văn (hệ số 2)
    ('NN001', 1), -- Anh văn (hệ số 1)
    ('TN002', 1)  -- Lý (hệ số 1)
    -- Thêm các môn học khác...

    -- Lấy bảng điểm chi tiết
    SELECT 
        hs.sHoTen,
        mh.sTenMH,
        d.fDiemKiemTra,
        d.fDiemGiuaKy,
        d.fDiemCuoiKy,
        ROUND((d.fDiemKiemTra + d.fDiemGiuaKy * 2 + d.fDiemCuoiKy * 3) / 6, 1) as DiemTBMon
    FROM DIEM d
    JOIN HOCSINH hs ON d.sMaHS = hs.sMaHS
    JOIN MONHOC mh ON d.sMaMH = mh.sMaMH
    WHERE d.sMaHS = @MaHS

    -- Tính điểm trung bình tổng kết
    SELECT @DiemTB = AVG(DiemTBMon)
    FROM (
        SELECT 
            ROUND((d.fDiemKiemTra + d.fDiemGiuaKy * 2 + d.fDiemCuoiKy * 3) / 6 * hm.HeSo, 1) as DiemTBMon
        FROM DIEM d
        JOIN #HeSoMon hm ON d.sMaMH = hm.MaMH
        WHERE d.sMaHS = @MaHS
    ) as TMP

    -- Trả về điểm trung bình
    SELECT @DiemTB as DiemTrungBinh

    -- Xóa bảng tạm
    DROP TABLE #HeSoMon
END
GO

EXEC spTinhDiemTrungBinh 
    @MaHS = 'K502024001', 
    @HocKy = 1,
    @NamHoc = '2024';


-- 2. Thủ tục phân công giảng dạy cho giáo viên
-- Input: Mã giáo viên, Mã lớp, Mã môn học, Năm học
CREATE PROCEDURE spPhanCongGiangDay
    @MaGV varchar(10),
    @MaLop varchar(10),
    @MaMH varchar(10),
    @NamHoc varchar(10)
AS
BEGIN
    -- Kiểm tra giáo viên có đúng chuyên môn
    IF NOT EXISTS (
        SELECT 1 FROM GIAOVIEN gv
        JOIN MONHOC mh ON gv.sChuyenMon = mh.sTenMH
        WHERE gv.sMaGV = @MaGV AND mh.sMaMH = @MaMH
    )
    BEGIN
        RAISERROR (N'Giáo viên không đúng chuyên môn giảng dạy!', 16, 1)
        RETURN
    END

    -- Kiểm tra trùng lịch
    IF EXISTS (
        SELECT 1 FROM THOIKHOABIEU
        WHERE sMaGV = @MaGV 
        AND dNgay IN (
            SELECT dNgay FROM THOIKHOABIEU WHERE sMaLop = @MaLop
        )
        AND sGio IN (
            SELECT sGio FROM THOIKHOABIEU WHERE sMaLop = @MaLop
        )
    )
    BEGIN
        RAISERROR (N'Trùng lịch giảng dạy!', 16, 1)
        RETURN
    END

    -- Thực hiện phân công
    DECLARE @MaTKB varchar(10)
    SET @MaTKB = 'TKB' + @MaLop + RIGHT('000' + CAST((
        SELECT COUNT(*) + 1 FROM THOIKHOABIEU WHERE sMaLop = @MaLop
    ) as varchar(3)), 3)

    INSERT INTO THOIKHOABIEU (sMaTKB, sMaLop, sMaMH, sMaGV, dNgay, sGio)
    VALUES (@MaTKB, @MaLop, @MaMH, @MaGV, GETDATE(), '07:30:00')
END
GO

EXEC spPhanCongGiangDay 
    @MaGV = 'TN261', 
    @MaLop = 'K506C', 
    @MaMH = 'TN001', 
    @NamHoc = '2024';

EXEC spPhanCongGiangDay 
    @MaGV = 'TN261', 
    @MaLop = 'K506C', 
    @MaMH = 'TN003', 
    @NamHoc = '2024';

-- 3. Thủ tục thống kê số lượng học sinh theo khối lớp
CREATE PROCEDURE spThongKeHocSinh
    @NamHoc varchar(10)
AS
BEGIN
    SELECT 
        l.sKhoi,
        COUNT(hs.sMaHS) as SoLuongHS,
        SUM(CASE WHEN hs.sGioiTinh = N'Nam' THEN 1 ELSE 0 END) as SoHSNam,
        SUM(CASE WHEN hs.sGioiTinh = N'Nữ' THEN 1 ELSE 0 END) as SoHSNu,
        MIN(YEAR(GETDATE()) - YEAR(hs.dNgaySinh)) as TuoiNhoNhat,
        MAX(YEAR(GETDATE()) - YEAR(hs.dNgaySinh)) as TuoiLonNhat
    FROM HOCSINH hs
    JOIN LOPHOC l ON hs.sTenLop = l.sTenLop
    GROUP BY l.sKhoi
    ORDER BY l.sKhoi
END
GO

EXEC spThongKeHocSinh 
    @NamHoc = '2024';

-- 4. Thủ tục cập nhật điểm học sinh với kiểm tra hợp lệ
CREATE PROCEDURE spCapNhatDiem
    @MaDiem varchar(10),
    @DiemKT float,
    @DiemGK float,
    @DiemCK float
AS
BEGIN
    -- Kiểm tra điểm hợp lệ
    IF @DiemKT < 0 OR @DiemKT > 10 OR
       @DiemGK < 0 OR @DiemGK > 10 OR
       @DiemCK < 0 OR @DiemCK > 10
    BEGIN
        RAISERROR (N'Điểm không hợp lệ! Điểm phải từ 0-10', 16, 1)
        RETURN
    END

    -- Cập nhật điểm
    UPDATE DIEM
    SET fDiemKiemTra = @DiemKT,
        fDiemGiuaKy = @DiemGK,
        fDiemCuoiKy = @DiemCK
    WHERE sMaDiem = @MaDiem
END
GO

select * from DIEM
EXEC spCapNhatDiem 
    @MaDiem = 'TOK506A001', 
    @DiemKT = 8.5, 
    @DiemGK = 7.0, 
    @DiemCK = 9.0;


-- 5. Thủ tục xử lý học sinh nghỉ học
CREATE PROCEDURE spXuLyNghiHoc
    @MaHS varchar(10),
    @NgayNghi date,
    @LyDo nvarchar(200)
AS
BEGIN
    -- Tạo bảng tạm lưu thông tin nghỉ học nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NGHIHOC')
    BEGIN
        CREATE TABLE NGHIHOC (
            sMaHS varchar(10),
            dNgayNghi date,
            sLyDo nvarchar(200),
            bCoPhep bit
        )
    END

    -- Kiểm tra ngày nghỉ hợp lệ
    IF @NgayNghi > GETDATE()
    BEGIN
        RAISERROR (N'Ngày nghỉ không hợp lệ!', 16, 1)
        RETURN
    END

    -- Thêm thông tin nghỉ học
    INSERT INTO NGHIHOC (sMaHS, dNgayNghi, sLyDo, bCoPhep)
    VALUES (@MaHS, @NgayNghi, @LyDo, 
            CASE 
                WHEN @LyDo LIKE N'%đau%' OR @LyDo LIKE N'%ốm%' OR @LyDo LIKE N'%bệnh%' THEN 1
                ELSE 0
            END)
END
GO

EXEC spXuLyNghiHoc 
    @MaHS = 'K502024001', 
    @NgayNghi = '2024-11-01', 
    @LyDo = N'Bị bệnh cảm cúm';
select * from NGHIHOC

-- =============================================
-- VIEWS
-- =============================================

-- 1. View thống kê kết quả học tập theo lớp
CREATE VIEW vwKetQuaHocTap
AS
SELECT 
    l.sTenLop,
    COUNT(DISTINCT hs.sMaHS) as TongSoHS,
    COUNT(DISTINCT d.sMaDiem) as TongSoDiem,
    ROUND(AVG(d.fDiemCuoiKy), 2) as DiemTBCuoiKy,
    SUM(CASE WHEN d.fDiemCuoiKy >= 8 THEN 1 ELSE 0 END) as SoHSGioi,
    SUM(CASE WHEN d.fDiemCuoiKy >= 6.5 AND d.fDiemCuoiKy < 8 THEN 1 ELSE 0 END) as SoHSKha,
    SUM(CASE WHEN d.fDiemCuoiKy < 5 THEN 1 ELSE 0 END) as SoHSYeu
FROM LOPHOC l
LEFT JOIN HOCSINH hs ON l.sTenLop = hs.sTenLop
LEFT JOIN DIEM d ON hs.sMaHS = d.sMaHS
GROUP BY l.sTenLop
GO

select * from vwKetQuaHocTap

-- 2. View xem thời khóa biểu giáo viên
CREATE VIEW vwThoiKhoaBieuGV
AS
SELECT 
    gv.sMaGV,
    gv.sHoTen as TenGV,
    l.sTenLop,
    mh.sTenMH,
    tkb.dNgay,
    tkb.sGio,
    DATEPART(dw, tkb.dNgay) as Thu
FROM THOIKHOABIEU tkb
JOIN GIAOVIEN gv ON tkb.sMaGV = gv.sMaGV
JOIN LOPHOC l ON tkb.sMaLop = l.sMaLop
JOIN MONHOC mh ON tkb.sMaMH = mh.sMaMH
GO

select * from vwThoiKhoaBieuGV

-- 3. View thống kê sĩ số theo địa chỉ
CREATE VIEW vwThongKeDiaChi
AS
SELECT 
    SUBSTRING(sDiaChi, CHARINDEX(',', sDiaChi) + 2, 
        CHARINDEX(',', sDiaChi, CHARINDEX(',', sDiaChi) + 1) - 
        CHARINDEX(',', sDiaChi) - 2) as Quan,
    COUNT(*) as SoLuongHS,
    STRING_AGG(sTenLop, ', ') as DanhSachLop
FROM HOCSINH
GROUP BY SUBSTRING(sDiaChi, CHARINDEX(',', sDiaChi) + 2, 
    CHARINDEX(',', sDiaChi, CHARINDEX(',', sDiaChi) + 1) - 
    CHARINDEX(',', sDiaChi) - 2)
GO

select * from vwThongKeDiaChi

-- 4. View xem tổng hợp điểm học sinh
CREATE VIEW vwTongHopDiem
AS
SELECT 
    hs.sMaHS,
    hs.sHoTen,
    hs.sTenLop,
    mh.sTenMH,
    d.fDiemKiemTra,
    d.fDiemGiuaKy,
    d.fDiemCuoiKy,
    ROUND((d.fDiemKiemTra + d.fDiemGiuaKy * 2 + d.fDiemCuoiKy * 3) / 6, 1) as DiemTBMon
FROM HOCSINH hs
JOIN DIEM d ON hs.sMaHS = d.sMaHS
JOIN MONHOC mh ON d.sMaMH = mh.sMaMH
GO

select * from vwTongHopDiem

-- 5. View thống kê giáo viên theo bộ môn
CREATE VIEW vwThongKeGiaoVien
AS
SELECT 
    mh.sTenMH as BoMon,
    COUNT(gv.sMaGV) as SoLuongGV,
    ROUND(AVG(YEAR(GETDATE()) - YEAR(gv.dNgaySinh)), 0) as TuoiTrungBinh,
    STRING_AGG(gv.sHoTen, ', ') as DanhSachGV
FROM MONHOC mh
LEFT JOIN GIAOVIEN gv ON mh.sTenMH = gv.sChuyenMon
GROUP BY mh.sTenMH
GO

select * from vwThongKeGiaoVien