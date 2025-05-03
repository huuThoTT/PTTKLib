USE PTTK_TTLT_ACCI
GO

GO
CREATE OR ALTER PROCEDURE P_INSERT_KHACH_HANG_NVTN 
    @v_TenKH NVARCHAR(100),
    @v_LoaiKH NVARCHAR(12),
    @v_SDT CHAR(12),
    @v_DiaChi NVARCHAR(100),
    @v_Email VARCHAR(100)/*,
	@v_MaKH NVARCHAR(10) OUTPUT*/
AS
BEGIN
    SET NOCOUNT OFF;

    INSERT INTO KHACH_HANG (TenKH, LoaiKH, SDT, DiaChi, Email)
    VALUES (@v_TenKH, @v_LoaiKH, @v_SDT, @v_DiaChi, @v_Email);

	/*SELECT @v_MaKH = MaKH
    FROM KHACH_HANG
    WHERE ID = SCOPE_IDENTITY();*/
END
GO

GO
CREATE OR ALTER PROCEDURE P_INSERT_THI_SINH_NVTN 
    @v_TenTS NVARCHAR(100),
	@v_NgaySinh DATE,
    @v_CCCD CHAR(12),
    @v_MaKH NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT OFF;

    INSERT INTO THI_SINH(TenTS, NgaySinh, CCCD, MaKH)
    VALUES (@v_TenTS, @v_NgaySinh, @v_CCCD, @v_MaKH);
END
GO

GO
CREATE OR ALTER PROCEDURE P_INSERT_PHIEU_DANG_KY_NVTN
    @v_MaTS VARCHAR(10),
    @v_MaLT VARCHAR(10),
    @v_MaLCC VARCHAR(10),
	@v_MaNVTiepNhan VARCHAR(10)
AS
BEGIN
    SET NOCOUNT OFF;

    BEGIN TRY
        -- Ngày lập là ngày hiện tại
        DECLARE @NgayLap DATE = CAST(GETDATE() AS DATE);

        -- Trạng thái luôn là 'Chờ TT'
        DECLARE @TrangThai NVARCHAR(12) = N'Chờ TT';

        -- Hạn thanh toán = Ngày lập + 14 ngày
        DECLARE @HanThanhToan DATE = DATEADD(DAY, 14, @NgayLap);

        -- Lấy ngày thi từ LICH_THI
        DECLARE @NgayThi DATE;
        SELECT @NgayThi = NgayGioThi
        FROM LICH_THI
        WHERE MaLT = @v_MaLT;

        IF @NgayThi IS NULL
        BEGIN
            RAISERROR(N'Mã lịch thi không hợp lệ hoặc không có ngày thi.', 16, 1);
            RETURN;
        END

        -- Lấy mã khách hàng từ thí sinh
        DECLARE @MaKH VARCHAR(10);
        SELECT @MaKH = TS.MaKH
        FROM THI_SINH TS
        WHERE TS.MaTS = @v_MaTS;

        IF @MaKH IS NULL
        BEGIN
            RAISERROR(N'Thí sinh không tồn tại hoặc chưa có mã khách hàng.', 16, 1);
            RETURN;
        END

        -- Chèn dữ liệu vào bảng PHIEU_DANG_KY
        INSERT INTO PHIEU_DANG_KY (
            NgayLapPDK, TrangThai, HanThanhToan,
            MaLCC, MaLT, MaKH, MaTS, MaNVTiepNhan
        )
        VALUES (
            @NgayLap, @TrangThai, @HanThanhToan,
            @v_MaLCC, @v_MaLT, @MaKH, @v_MaTS, @v_MaNVTiepNhan
        );

		-- Cập nhật SoLuongDaDangKy của mã lịch thi tương ứng +1
        UPDATE LICH_THI
        SET SoLuongDaDangKy = ISNULL(SoLuongDaDangKy, 0) + 1
        WHERE MaLT = @v_MaLT;
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO
/*
EXEC P_INSERT_PHIEU_DANG_KY_NVTN
    @v_MaTS = 'THSH000001',
    @v_MaLT = 'LICH000001',
    @v_MaLCC = 'LOCC000001',
    @v_MaNVTiepNhan = 'NHVN000001';


SELECT * FROM PHIEU_DANG_KY;
*/

GO
CREATE OR ALTER FUNCTION F_TenKH_to_KHACH_HANG_NVTN(@v_tenkh NVARCHAR(100))
RETURNS TABLE
AS
RETURN
    SELECT MaKH, TenKH, LoaiKH, SDT, DiaChi, Email
    FROM KHACH_HANG
    WHERE TenKH = @v_tenkh;
GO
-- SELECT * FROM F_MaKH_to_KHACH_HANG_NVTN('KHHG000001'); 
GO
CREATE OR ALTER FUNCTION F_TenTS_to_THI_SINH_NVTN(@v_tents NVARCHAR(100))
RETURNS TABLE
AS
RETURN
    SELECT MaTS, TenTS, NgaySinh, CCCD, MaKH
    FROM THI_SINH
    WHERE TenTS = @v_tents;
GO
-- SELECT * FROM F_TenTS_to_THI_SINH_NVTN('Thí Sinh A');

GO
CREATE OR ALTER FUNCTION F_MaPDK_to_PHIEU_DANG_KY_NVTN (@v_mapdk VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT
        P.MaPDK,
        KH.TenKH,
        TS.TenTS,
        LCC.TenLoaiChungChi,
        LT.NgayGioThi,
        P.NgayLapPDK,
        P.HanThanhToan,
        P.TrangThai
    FROM PHIEU_DANG_KY P
    LEFT JOIN KHACH_HANG KH ON P.MaKH = KH.MaKH
    LEFT JOIN THI_SINH TS ON P.MaTS = TS.MaTS
    LEFT JOIN LOAI_CHUNG_CHI LCC ON P.MaLCC = LCC.MaLCC
    LEFT JOIN LICH_THI LT ON P.MaLT = LT.MaLT
    WHERE P.MaPDK = @v_mapdk
);
GO

-- SELECT * FROM F_MaPDK_to_PHIEU_DANG_KY_NVTN('PHDK000001');