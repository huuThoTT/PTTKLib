USE PTTK_TTLT_ACCI
GO

DECLARE @NgayBatDau DATETIME = '2025-05-05 15:52';

WITH CTE AS (
    SELECT 
        ID, 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY ID) - 1, @NgayBatDau) AS NewNgayGioThi
    FROM LICH_THI
)
UPDATE L
SET NgayGioThi = C.NewNgayGioThi
FROM LICH_THI L
JOIN CTE C ON L.ID = C.ID;

UPDATE P
SET P.ThoiGianThi = L.NgayGioThi
FROM PHIEU_DU_THI P
JOIN LICH_THI L ON P.MaLT = L.MaLT;


GO
CREATE OR ALTER PROCEDURE CapNhatSoLuongDaDangKy
AS
BEGIN
    -- Cập nhật SoLuongDaDangKy dựa trên số lượng PHIEU_DU_THI theo MaLT
    UPDATE L
    SET SoLuongDaDangKy = ISNULL(T.SoLuong, 0)
    FROM LICH_THI L
    LEFT JOIN (
        SELECT MaLT, COUNT(*) AS SoLuong
        FROM PHIEU_DU_THI
        GROUP BY MaLT
    ) T ON L.MaLT = T.MaLT;
END;

EXEC CapNhatSoLuongDaDangKy;
Go

GO
CREATE OR ALTER PROCEDURE dbo.sp_KiemTraVaThemPhieuDuThiGiaHan
    @MaPDT VARCHAR(10),
    @Result BIT OUTPUT
AS
BEGIN
    DECLARE @Exists INT;

    SELECT @Exists = COUNT(*) 
    FROM PHIEU_DU_THI_GIA_HAN 
    WHERE MaPDT = @MaPDT;

    -- Nếu chưa tồn tại, thêm mới
    IF @Exists = 0
    BEGIN
        INSERT INTO PHIEU_DU_THI_GIA_HAN (MaPDT, SoLanConLai, HanGiaHan)
        VALUES (@MaPDT, 2, DATEADD(YEAR, 1, GETDATE()));
        SET @Result = 1; 
    END
    ELSE
    BEGIN
        SET @Result = 0; 
    END
END;
GO

GO
CREATE OR ALTER TRIGGER TRG_AfterInsert_PhieuDuThi
ON PHIEU_DU_THI
AFTER INSERT
AS
BEGIN
    DECLARE @MaPDT VARCHAR(10);
    DECLARE @Result BIT;

    SELECT @MaPDT = MaPDT
    FROM inserted;

    EXEC dbo.sp_KiemTraVaThemPhieuDuThiGiaHan @MaPDT, @Result OUTPUT;

    IF @Result = 1
    BEGIN
        PRINT 'Đã thêm PHIEU_DU_THI_GIA_HAN cho MaPDT: ' + @MaPDT;
    END
    ELSE
    BEGIN
        PRINT 'PHIEU_DU_THI_GIA_HAN đã tồn tại cho MaPDT: ' + @MaPDT;
    END
END;
GO

GO
CREATE OR ALTER FUNCTION dbo.fn_KiemTraPhieuDuThiGiaHan (@MaPDT VARCHAR(10))
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;

    IF EXISTS (SELECT 1 FROM PHIEU_DU_THI_GIA_HAN WHERE MaPDT = @MaPDT)
        SET @Exists = 1; 
    ELSE
        SET @Exists = 0; 

    RETURN @Exists;
END;
GO



DECLARE @MaPDT VARCHAR(10);
DECLARE @Result BIT;

BEGIN TRY
    DECLARE cursor_PDT CURSOR FOR 
        SELECT MaPDT 
        FROM PHIEU_DU_THI;

    OPEN cursor_PDT;

    FETCH NEXT FROM cursor_PDT INTO @MaPDT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Đang xử lý MaPDT: ' + @MaPDT;
        SELECT * FROM PHIEU_DU_THI_GIA_HAN WHERE MaPDT = @MaPDT;

        EXEC dbo.sp_KiemTraVaThemPhieuDuThiGiaHan @MaPDT = @MaPDT, @Result = @Result OUTPUT;

        PRINT 'Kết quả cho MaPDT ' + @MaPDT + ': ' + CAST(@Result AS VARCHAR(1));

        SELECT * FROM PHIEU_DU_THI_GIA_HAN WHERE MaPDT = @MaPDT;

        FETCH NEXT FROM cursor_PDT INTO @MaPDT;
    END;

    CLOSE cursor_PDT;
    DEALLOCATE cursor_PDT;
END TRY
BEGIN CATCH
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
    CLOSE cursor_PDT;
    DEALLOCATE cursor_PDT;
END CATCH;

