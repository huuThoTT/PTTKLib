USE PTTK_TTLT_ACCI
GO

CREATE OR ALTER PROCEDURE P_INSERT_HOA_DON_NVKT
	@v_MaPDK VARCHAR(10), 
	@v_SoTienThanhToan FLOAT,
	@v_ChietKhau FLOAT,
	@v_MaNVKeToan VARCHAR(10),
	@v_HinhThucThanhToan NVARCHAR(100),
	@v_NgayGioThanhToan DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	-- Kiểm tra nếu phiếu đăng ký tồn tại và đang ở trạng thái 'Chờ TT'
	IF EXISTS (
		SELECT 1
		FROM PHIEU_DANG_KY
		WHERE MaPDK = @v_MaPDK AND TrangThai = N'Chờ TT'
	)
	BEGIN
		-- Thêm hóa đơn
		INSERT INTO HOA_DON(NgayGioThanhToan, SoTienThanhToan, HinhThucThanhToan, ChietKhau, MaPDK, MaNVKeToan)
		VALUES(@v_NgayGioThanhToan, @v_SoTienThanhToan, @v_HinhThucThanhToan, @v_ChietKhau, @v_MaPDK, @v_MaNVKeToan);

		-- Cập nhật trạng thái phiếu đăng ký
		UPDATE PHIEU_DANG_KY
		SET TrangThai = N'Đã TT'
		WHERE MaPDK = @v_MaPDK AND TrangThai = N'Chờ TT';
	END
	-- Nếu phiếu đăng ký không tồn tại hoặc đã được thanh toán thì không làm gì cả
END 

GO
USE PTTK_TTLT_ACCI
GO

CREATE OR ALTER FUNCTION F_MaPDK_to_HOA_DON_NVKT
(
    @MaPDK VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaPDK,
		NgayLapPDK,
        TrangThai,
        HanThanhToan,
		MaLCC,
        MaLT,
        MaKH,
        MaTS,
        MaNVTiepNhan
    FROM PHIEU_DANG_KY
    WHERE MaPDK = @MaPDK
);

GO
USE PTTK_TTLT_ACCI
GO

CREATE OR ALTER FUNCTION F_MaHoaDon_to_HOA_DON_NVKT
(
    @MaHoaDon VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaHD,
        NgayGioThanhToan,
        SoTienThanhToan,
        HinhThucThanhToan,
		ChietKhau,
        MaPDK,
        MaNVKeToan
    FROM HOA_DON
    WHERE MaHD = @MaHoaDon
);