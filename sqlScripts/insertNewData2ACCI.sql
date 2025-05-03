USE PTTK_TTLT_ACCI
GO

/*
DELETE FROM PHIEU_DANG_KY;
DELETE FROM HOA_DON;
DELETE FROM PHIEU_DU_THI;

DELETE FROM KET_QUA_THI;
DELETE FROM CHUNG_CHI;
*/
/*
SELECT * FROM PHIEU_DANG_KY;
SELECT * FROM HOA_DON;
SELECT * FROM PHIEU_DU_THI;

SELECT * FROM KET_QUA_THI;
SELECT * FROM CHUNG_CHI;
*/

SET IDENTITY_INSERT PHIEU_DANG_KY ON

DECLARE @i INT = 1
DECLARE @MaTS VARCHAR(10)
DECLARE @MaKH VARCHAR(10)
DECLARE @MaLT VARCHAR(10)
DECLARE @MaLCC VARCHAR(10)
DECLARE @MaNVTN VARCHAR(10)
DECLARE @NgayLapPDK DATE
DECLARE @HanThanhToan DATE

-- Lấy danh sách thí sinh (và MaKH tương ứng)
DECLARE @ListTS TABLE (rn INT IDENTITY(1,1), MaTS VARCHAR(10), MaKH VARCHAR(10))
INSERT INTO @ListTS (MaTS, MaKH)
SELECT MaTS, MaKH FROM THI_SINH

-- Random danh sách LICH_THI (MaLT, MaLCC)
DECLARE @ListLT TABLE (MaLT VARCHAR(10), MaLCC VARCHAR(10))
INSERT INTO @ListLT
SELECT MaLT, LoaiChungChi FROM LICH_THI ORDER BY NEWID()

-- Random danh sách nhân viên tiếp nhận
DECLARE @ListNV TABLE (MaNV VARCHAR(10))
INSERT INTO @ListNV
SELECT MaNV FROM NHAN_VIEN WHERE LoaiNhanVien = 'NVTN' ORDER BY NEWID()

DECLARE @TotalTS INT, @TotalLT INT, @TotalNV INT
SELECT @TotalTS = COUNT(*) FROM @ListTS
SELECT @TotalLT = COUNT(*) FROM @ListLT
SELECT @TotalNV = COUNT(*) FROM @ListNV

WHILE @i <= 30
BEGIN
    -- Lấy MaTS và MaKH tương ứng
    SELECT @MaTS = MaTS, @MaKH = MaKH FROM @ListTS WHERE rn = @i

    -- Random MaLT và MaLCC
    SELECT TOP 1 @MaLT = MaLT, @MaLCC = MaLCC FROM @ListLT ORDER BY NEWID()

    -- Random MaNVTiepNhan
    SELECT TOP 1 @MaNVTN = MaNV FROM @ListNV ORDER BY NEWID()

	-- Ngày lập và hạn thanh toán
    SET @NgayLapPDK = DATEADD(DAY, -@i + 1, GETDATE())
    SET @HanThanhToan = DATEADD(DAY, 3, @NgayLapPDK)

    -- Thêm bản ghi
    INSERT INTO PHIEU_DANG_KY (ID, NgayLapPDK, TrangThai, HanThanhToan, MaLCC, MaLT, MaKH, MaTS, MaNVTiepNhan)
    VALUES (
        @i,
        @NgayLapPDK,         -- Ngày lập phiếu lùi dần
        N'Chờ TT',                             -- Trạng thái mặc định
        @HanThanhToan,       -- Hạn thanh toán sau 7+i ngày
        @MaLCC,
        @MaLT,
        @MaKH,
        @MaTS,
        @MaNVTN
    )

    SET @i += 1
END

SET IDENTITY_INSERT PHIEU_DANG_KY OFF


-- HOA_DON
SET IDENTITY_INSERT HOA_DON ON

SET @i = 1
DECLARE @MaPDK VARCHAR(10)
DECLARE @MaNVKT VARCHAR(10)

-- Random danh sách nhân viên tiếp nhận
DECLARE @ListNVKT TABLE (MaNV VARCHAR(10))
INSERT INTO @ListNVKT
SELECT MaNV FROM NHAN_VIEN WHERE LoaiNhanVien = 'NVKT' ORDER BY NEWID()

WHILE @i <= 25
BEGIN
    SELECT @MaPDK = MaPDK FROM PHIEU_DANG_KY WHERE ID = @i

	-- Random MaNVTiepNhan
    SELECT TOP 1 @MaNVKT = MaNV FROM @ListNVKT ORDER BY NEWID()

    INSERT INTO HOA_DON (ID, NgayGioThanhToan, SoTienThanhToan, HinhThucThanhToan, ChietKhau, MaPDK, MaNVKeToan)
    VALUES (
        @i,
        DATEADD(DAY, -@i+1, GETDATE()),
        2000000 + (@i * 10000),
        N'Tiền mặt',
        0,
        @MaPDK,
        @MaNVKT
    )

    SET @i += 1
END

SET IDENTITY_INSERT HOA_DON OFF

-- PHIEU_DU_THI
SET IDENTITY_INSERT PHIEU_DU_THI ON

SET @i = 1
DECLARE @MaHD VARCHAR(10)
DECLARE @ThoiGianThi DATETIME
DECLARE @NgayPhatHanh DATE
DECLARE @DiaDiemThi NVARCHAR(100)

WHILE @i <= 20
BEGIN
    -- Lấy mã hóa đơn
    SELECT @MaHD = MaHD, @MaPDK = MaPDK FROM HOA_DON WHERE ID = @i

    -- Lấy thông tin phiếu đăng ký
    SELECT @MaTS = MaTS, @MaLT = MaLT FROM PHIEU_DANG_KY WHERE MaPDK = @MaPDK

    -- Lấy thời gian thi từ lịch thi
    SELECT @ThoiGianThi = NgayGioThi FROM LICH_THI WHERE MaLT = @MaLT

    -- Tính ngày phát hành: 14 ngày trước thời gian thi
    SET @NgayPhatHanh = DATEADD(DAY, -14, @ThoiGianThi)

    -- Tạo địa điểm thi (ví dụ: ngẫu nhiên từ 1 đến 5)
    SET @DiaDiemThi = N'Trung tâm thi số ' + CAST((@i % 5 + 1) AS NVARCHAR)

    -- Insert vào PHIEU_DU_THI
    INSERT INTO PHIEU_DU_THI (ID, NgayPhatHanh, TrangThai, ThoiGianThi, DiaDiemThi, MaTS, MaLT, MaHD)
    VALUES (
        @i,
        @NgayPhatHanh,
        N'Đã phát',
        @ThoiGianThi,
        @DiaDiemThi,
        @MaTS,
        @MaLT,
        @MaHD
    )

    SET @i += 1
END

SET IDENTITY_INSERT PHIEU_DU_THI OFF


-- KET_QUA_THI
SET IDENTITY_INSERT KET_QUA_THI ON

SET @i = 1

WHILE @i <= 18
BEGIN
    SELECT @MaTS = MaTS FROM PHIEU_DANG_KY WHERE ID = @i
    SELECT @MaLCC = MaLCC FROM PHIEU_DANG_KY WHERE ID = @i

    INSERT INTO KET_QUA_THI (ID, DiemSo, NgayCoDiem, MaTS, MaLCC, MaPDT)
    VALUES (
        @i,
        NULL,
		NULL,
        @MaTS,
        @MaLCC,
        (SELECT MaPDT FROM PHIEU_DU_THI WHERE ID = @i)
    )

    SET @i += 1
END

SET IDENTITY_INSERT KET_QUA_THI OFF