USE PTTK_TTLT_ACCI
GO

/*
DELETE FROM LOAI_CHUNG_CHI;
DELETE FROM XEP_HANG_CHUNG_CHI;

DELETE FROM KHACH_HANG;
DELETE FROM THI_SINH;
DELETE FROM NHAN_VIEN;

DELETE FROM PHONG_THI;
DELETE FROM LICH_THI;
DELETE FROM NHAN_VIEN_GIAM_THI_LICH_THI;
*/
/*
SELECT * FROM LOAI_CHUNG_CHI;
SELECT * FROM XEP_HANG_CHUNG_CHI;

SELECT * FROM KHACH_HANG;
SELECT * FROM THI_SINH;
SELECT * FROM NHAN_VIEN;

SELECT * FROM PHONG_THI;
SELECT * FROM LICH_THI;
SELECT * FROM NHAN_VIEN_GIAM_THI_LICH_THI;
*/
-- LOAI_CHUNG_CHI
SET IDENTITY_INSERT LOAI_CHUNG_CHI ON

INSERT INTO LOAI_CHUNG_CHI (ID, TenLoaiChungChi, LinhVucChungChi, DiemChuan, ThoiHan) VALUES 
(1, N'IELTS', N'Ngoại ngữ', 1.0, 24),
(2, N'TOEIC', N'Ngoại ngữ', 10, 24),
(3, N'MOS Word Associate', N'Tin học', 700, 36),
(4, N'MOS Word Expert', N'Tin học', 700, 36),
(5, N'MOS Excel Associate', N'Tin học', 700, 36),
(6, N'MOS Excel Expert', N'Tin học', 700, 36),
(7, N'MOS PowerPoint Associate', N'Tin học', 700, 36),
(8, N'MOS Access Associate', N'Tin học', 700, 36);

SET IDENTITY_INSERT LOAI_CHUNG_CHI OFF


-- XEP_HANG_CHUNG_CHI
INSERT INTO XEP_HANG_CHUNG_CHI (MaLCC, XepHang, DiemSan, DiemTran) VALUES
-- IELTS: A1, A2, B1, B2, C1, C2
('LOCC000001', 'A1', 1.0, 2.5),
('LOCC000001', 'A2', 3.0, 3.5),
('LOCC000001', 'B1', 4.0, 5.0),
('LOCC000001', 'B2', 5.5, 6.5),
('LOCC000001', 'C1', 7.0, 8.0),
('LOCC000001', 'C2', 8.5, 9.0),
-- TOEIC: Basic, Average, Upper, Advanced, Master
('LOCC000002', 'Basic', 10, 299),
('LOCC000002', 'Average', 300, 499),
('LOCC000002', 'Upper', 500, 699),
('LOCC000002', 'Advanced', 700, 899),
('LOCC000002', 'Master', 900, 990),
-- MOS Word Associate
('LOCC000003', 'Associate', 700, 1000),
-- MOS Word Expert
('LOCC000004', 'Expert', 700, 1000),
-- MOS Excel Associate
('LOCC000005', 'Associate', 700, 1000),
-- MOS Excel Expert
('LOCC000006', 'Expert', 700, 1000),
-- MOS PowerPoint Associate
('LOCC000007', 'Associate', 700, 1000),
-- MOS Access Associate
('LOCC000008', 'Associate', 700, 1000);


-- KHACH_HANG
SET IDENTITY_INSERT KHACH_HANG ON

DECLARE @i INT = 1
WHILE @i <= 50
BEGIN
    INSERT INTO KHACH_HANG (ID, TenKH, LoaiKH, SDT, DiaChi, Email)
    VALUES (
        @i,
        N'Khách hàng ' + CHAR(64 + @i),
        CASE WHEN @i % 3 = 0 THEN N'Đơn vị' ELSE N'Cá nhân' END,
        '09' + RIGHT('00000000' + CAST(@i * 12345 AS VARCHAR(8)), 8),
        N'Đường ' + CHAR(65 + (@i % 26)) + N' Quận ' + CAST((@i % 5 + 1) AS NVARCHAR) + N' Tỉnh ABC',
        'khachhang' + CAST(@i AS VARCHAR) + '@gmail.com'
    )
    SET @i += 1
END

SET IDENTITY_INSERT KHACH_HANG OFF


-- THI_SINH
SET IDENTITY_INSERT THI_SINH ON

SET @i = 1
WHILE @i <= 50
BEGIN
    INSERT INTO THI_SINH (ID, TenTS, NgaySinh, CCCD, MaKH)
    VALUES (
        @i,
        N'Thí sinh ' + CHAR(64 + (@i % 26 + 1)),
		DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 * 10, '1990-01-01'),
        RIGHT('000000000000' + CAST(@i * 49726 AS VARCHAR(12)), 12),
        (SELECT TOP 1 MaKH FROM KHACH_HANG ORDER BY NEWID())
    )
    SET @i += 1
END

SET IDENTITY_INSERT THI_SINH OFF


-- NHANVIEN, đủ các loại
-- NVTN (Nhân viên tiếp nhận), NVGT (Nhân viên giám thị), NVKT (Nhân viên kế toán), NVNL (Nhân viên nhập liệu), NVPH (Nhân viên phát hành)
SET IDENTITY_INSERT NHAN_VIEN ON

DECLARE @LoaiNV NVARCHAR(12)

SET @i = 1
WHILE @i <= 20
BEGIN
    SET @LoaiNV = CASE 
                    WHEN @i % 5 = 1 THEN N'NVTN' 
                    WHEN @i % 5 = 2 THEN N'NVPH'
                    WHEN @i % 5 = 3 THEN N'NVKT'
                    WHEN @i % 5 = 4 THEN N'NVNL'
                    ELSE N'NVGT'
                  END

    INSERT INTO NHAN_VIEN (ID, TenNhanVien, NgaySinh, Email, SDT, DiaChi, CCCD, LoaiNhanVien)
    VALUES (
        @i,
        N'Nhân viên ' + CHAR(64 + @i),
        DATEADD(DAY, -(@i * 800), GETDATE()),
        'nhanvien' + CAST(@i AS VARCHAR) + '@gmail.com',
        '09' + RIGHT('00000000' + CAST(@i * 6789 AS VARCHAR(8)), 8),
        N'Phường ' + CHAR(65 + (@i % 26)) + N' TP.XYZ',
        RIGHT('000000000000' + CAST(@i * 23537 AS VARCHAR(12)), 12),
        @LoaiNV
    )
    SET @i += 1
END

SET IDENTITY_INSERT NHAN_VIEN OFF


-- PHONG_THI
SET IDENTITY_INSERT PHONG_THI ON

SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO PHONG_THI (ID, SucChua, TrangThai)
    VALUES (
        @i,
        30 + (@i * 2),
        CASE WHEN @i % 5 = 0 THEN N'Tạm ngưng' ELSE N'Hoạt động' END
    )
    SET @i += 1
END

SET IDENTITY_INSERT PHONG_THI OFF


-- LICH_THI
SET IDENTITY_INSERT LICH_THI ON

SET @i = 1
DECLARE @PhongHoatDong TABLE (MaPT VARCHAR(10))
INSERT INTO @PhongHoatDong (MaPT)
SELECT MaPT FROM PHONG_THI WHERE TrangThai = N'Hoạt động'

DECLARE @PhongCount INT
SELECT @PhongCount = COUNT(*) FROM @PhongHoatDong

DECLARE @PhongIndex INT

WHILE @i <= 30
BEGIN
    SET @PhongIndex = ((@i - 1) % @PhongCount) + 1 -- Lấy vòng tròn phòng thi hoạt động

    INSERT INTO LICH_THI (ID, NgayGioThi, SoLuongToiDa, SoLuongDaDangKy, LoaiChungChi, MaPT)
    SELECT 
        @i,
        DATEADD(DAY, @i-60, GETDATE()),
        50 + (@i % 30), -- Sức chứa từ 50-80
        0,
        (SELECT TOP 1 MaLCC FROM LOAI_CHUNG_CHI ORDER BY NEWID()),
        (SELECT MaPT FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum, MaPT FROM @PhongHoatDong
        ) AS Phong
        WHERE RowNum = @PhongIndex)
    
    SET @i += 1
END

SET IDENTITY_INSERT LICH_THI OFF


-- NHAN_VIEN_GIAM_THI_LICH_THI
DECLARE @MaLT VARCHAR(10)
DECLARE @NVGT TABLE (MaNV VARCHAR(10))
INSERT INTO @NVGT (MaNV)
SELECT MaNV FROM NHAN_VIEN WHERE LoaiNhanVien = N'NVGT'

DECLARE @NVGTCount INT
SELECT @NVGTCount = COUNT(*) FROM @NVGT

DECLARE @GTIndex INT = 1

SET @i = 1
WHILE @i <= 30
BEGIN
    SELECT @MaLT = MaLT FROM LICH_THI WHERE ID = @i

    -- Gán Giám thị chính
    INSERT INTO NHAN_VIEN_GIAM_THI_LICH_THI (MaLT, MaNV, VaiTro)
    SELECT 
        @MaLT,
        (SELECT MaNV FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum, MaNV FROM @NVGT
        ) AS NV WHERE RowNum = ((@GTIndex - 1) % @NVGTCount) + 1),
        N'Giám thị chính'

    -- Gán Thư ký
    INSERT INTO NHAN_VIEN_GIAM_THI_LICH_THI (MaLT, MaNV, VaiTro)
    SELECT 
        @MaLT,
        (SELECT MaNV FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum, MaNV FROM @NVGT
        ) AS NV WHERE RowNum = ((@GTIndex) % @NVGTCount) + 1),
        N'Thư ký'

    SET @GTIndex += 2
    SET @i += 1
END