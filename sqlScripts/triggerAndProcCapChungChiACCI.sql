GO
USE PTTK_TTLT_ACCI
GO

GO
CREATE OR ALTER FUNCTION F_SELECT_KET_QUA_THI_NVNL()
RETURNS TABLE
AS
RETURN
    SELECT MaKQT as N'Mã bài thi/kết quả thi',
	DiemSo as N'Điểm số',
	NgayCoDiem as N'Ngày có điểm',
	MaTS as N'Mã thí sinh',
	MaLCC as N'Mã loại chứng chỉ',
	MaPDT as N'Mã phiếu dự thi'
    FROM KET_QUA_THI
GO

GO
CREATE OR ALTER FUNCTION F_MaKQT_to_KET_QUA_THI_NVNL(@v_makqt VARCHAR(10))
RETURNS TABLE
AS
RETURN
    SELECT TOP 1
        MaKQT AS N'Mã bài thi/kết quả thi', 
        DiemSo AS N'Điểm số', 
        NgayCoDiem AS N'Ngày có điểm',
        MaTS AS N'Mã thí sinh', 
        MaLCC AS N'Mã loại chứng chỉ',
        MaPDT AS N'Mã phiếu dự thi'
    FROM KET_QUA_THI
    WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
    AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]';
GO
-- SELECT * FROM F_MaKQT_to_KET_QUA_THI_NVNL('KQTH000003');

GO
CREATE OR ALTER FUNCTION F_MaKQT_to_THI_SINH_NVNL(@v_makqt varchar(10))
RETURNS TABLE
AS
RETURN (
    SELECT ts.MaTS as N'Mã thí sinh', ts.TenTS as N'Tên thí sinh',
	ts.NgaySinh as N'Ngày sinh', ts.CCCD as N'Căn cước công dân',
	ts.MaKH as N'Mã khách hàng'
    FROM THI_SINH ts
	JOIN KET_QUA_THI kqt ON ts.MaTS = kqt.MaTS
    WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
    AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]')
GO

-- SELECT * FROM F_MaKQT_to_THI_SINH_NVNL('KQTH000003');
-- SELECT * FROM KET_QUA_THI WHERE MaKQT = 'KQTH000003';

GO
CREATE OR ALTER FUNCTION F_MaKQT_to_KHACH_HANG_NVNL(@v_makqt varchar(10))  
RETURNS TABLE
AS
RETURN (
    SELECT kh.MaKH as N'Mã khách hàng', kh.TenKH as N'Tên khách hàng',
	kh.LoaiKH as N'Loại khách hàng', kh.SDT as N'Số điện thoại',
	kh.DiaChi as N'Địa chỉ', kh.Email
    FROM THI_SINH ts
	JOIN KET_QUA_THI kqt ON ts.MaTS = kqt.MaTS
	JOIN KHACH_HANG kh ON kh.MaKH = ts.MaKH
    WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
    AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]')
GO
-- SELECT * FROM F_MaKQT_to_KHACH_HANG_NVNL('KQTH000003');

GO
CREATE OR ALTER FUNCTION F_MaKQT_to_LOAI_CHUNG_CHI_NVNL(@v_makqt varchar(10))  
RETURNS TABLE
AS
RETURN (
    SELECT lcc.MaLCC as N'Mã loại chứng chỉ', lcc.TenLoaiChungChi as N'Tên loại chứng chỉ',
	lcc.LinhVucChungChi as N'Lĩnh vực chứng chỉ', lcc.DiemChuan as N'Điểm chuẩn',
	lcc.ThoiHan as N'Thời hạn (tháng)'
    FROM LOAI_CHUNG_CHI lcc
	JOIN KET_QUA_THI kqt ON lcc.MaLCC = kqt.MaLCC
    WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
    AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]')
GO
-- SELECT * FROM F_MaKQT_to_LOAI_CHUNG_CHI_NVNL('KQTH000003');

GO
CREATE OR ALTER FUNCTION F_TenKH_to_MaKH_NVNL(@v_tenkh varchar(10))  
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN (
        SELECT MaKH 
        FROM KHACH_HANG
        WHERE TenKH = @v_tenkh
    )
END
GO

GO
CREATE OR ALTER PROCEDURE P_UPDATE_KET_QUA_THI_NVNL
    @v_makqt varchar(10),
    @v_diemso float
AS
BEGIN
    -- Kiểm tra MaKQT không được để trống
    IF @v_makqt IS NULL OR LTRIM(RTRIM(@v_makqt)) = ''
    BEGIN
        RAISERROR('Mã Kết Quả Thi không được để trống.', 16, 1);
        RETURN;
    END

    -- Kiểm tra MaKQT tồn tại
	DECLARE @MaKQT VARCHAR(10);
	SET @MaKQT = (
		SELECT MaKQT
		FROM KET_QUA_THI
		WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
		AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]')
    IF NOT EXISTS (SELECT 1 FROM KET_QUA_THI WHERE MaKQT = @MaKQT)
    BEGIN
        RAISERROR('Mã Kết Quả Thi không tồn tại.', 16, 1);
        RETURN;
    END

    -- Cập nhật DiemSo và NgayCoDiem (chỉ cập nhật NgayCoDiem nếu hiện tại là NULL)
    UPDATE KET_QUA_THI
    SET DiemSo = @v_diemso,
        NgayCoDiem = CASE WHEN NgayCoDiem IS NULL THEN GETDATE() ELSE NgayCoDiem END
    WHERE RIGHT(MaKQT, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makqt)), 6)
    AND MaKQT LIKE 'KQTH[0-9][0-9][0-9][0-9][0-9][0-9]';

    -- Tạo/Cập nhật chứng chỉ
    DECLARE @DiemChuan FLOAT,
			@XepHang VARCHAR(10),
            @NgayCap DATE,
            @NgayHetHan DATE,
            @ThoiHan INT, 
            @ThoiHanNam INT, 
            @ThoiHanThangDu INT,
            @MaTS VARCHAR(10), 
            @MaLCC VARCHAR(10);
			
    SET @MaTS = (
        SELECT MaTS
        FROM KET_QUA_THI
        WHERE MaKQT = @MaKQT)
    SET @MaLCC = (
        SELECT MaLCC
        FROM KET_QUA_THI
        WHERE MaKQT = @MaKQT)
    SET @DiemChuan = (
		SELECT DiemChuan FROM LOAI_CHUNG_CHI
		WHERE MaLCC = @MaLCC)
    SET @XepHang = (
        SELECT XepHang 
        FROM XEP_HANG_CHUNG_CHI
        WHERE MaLCC = @MaLCC
        AND @v_diemso >= DiemSan AND @v_diemso <= DiemTran)
	SET @NgayCap = GETDATE();
    SET @ThoiHan = (
        SELECT ThoiHan 
        FROM LOAI_CHUNG_CHI
        WHERE MaLCC = @MaLCC)
    SET @ThoiHanNam = @ThoiHan / 12;
    SET @ThoiHanThangDu = @ThoiHan % 12;

    -- Tính NgayHetHan
    SET @NgayHetHan = DATEADD(YEAR, @ThoiHanNam, @NgayCap);
    SET @NgayHetHan = DATEADD(MONTH, @ThoiHanThangDu, @NgayHetHan);

	IF @v_diemso >= @DiemChuan
	BEGIN
		IF NOT EXISTS (
			SELECT MaKQT 
			FROM CHUNG_CHI
			WHERE MaKQT = @MaKQT)
		BEGIN
			INSERT INTO CHUNG_CHI (DiemSo, XepHang, NgayCap, NgayHetHan, TrangThai, MaKQT, MaTS, MaLCC)
			VALUES (
				@v_diemso,
				@XepHang,
				@NgayCap,
				@NgayHetHan,
				N'Chưa trả',
				@MaKQT,
				@MaTS,
				@MaLCC)
		END
		ELSE
		BEGIN
			UPDATE CHUNG_CHI
			SET DiemSo = @v_diemso,
				XepHang = @XepHang
			WHERE MaKQT = @MaKQT
		END
	END
END
GO

GO
CREATE OR ALTER FUNCTION F_SELECT_KHACH_HANG_NVTN()
RETURNS TABLE
AS
RETURN
    SELECT 
        MaKH AS N'Mã khách hàng', 
        TenKH AS N'Tên khách hàng', 
        LoaiKH AS N'Loại khách hàng',
        SDT AS N'Số điện thoại', 
        DiaChi AS N'Địa chỉ',
        Email
    FROM KHACH_HANG
GO

GO
CREATE OR ALTER FUNCTION F_MaKH_to_KHACH_HANG_NVTN(@v_makh VARCHAR(10))
RETURNS TABLE
AS
RETURN
    SELECT 
        MaKH AS N'Mã khách hàng', 
        TenKH AS N'Tên khách hàng', 
        LoaiKH AS N'Loại khách hàng',
        SDT AS N'Số điện thoại', 
        DiaChi AS N'Địa chỉ',
        Email
    FROM KHACH_HANG
    WHERE RIGHT(MaKH, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makh)), 6)
    AND MaKH LIKE 'KHHG[0-9][0-9][0-9][0-9][0-9][0-9]';
GO

GO
CREATE OR ALTER FUNCTION F_MaKH_to_CHUNG_CHI_THI_SINH_NVTN(@v_makh varchar(10))  
RETURNS TABLE
AS
RETURN (
    SELECT 
	cc.MaCC as N'Mã chứng chỉ',
	cc.MaTS as N'Mã thí sinh',
	ts.TenTS as N'Tên thí sinh',
	ts.CCCD as N'Căn cước công dân',
	ts.NgaySinh as N'Ngày sinh',
	lcc.TenLoaiChungChi as N'Tên loại chứng chỉ',
	cc.TrangThai as N'Trạng thái',
	cc.DiemSo as N'Điểm số',
	cc.XepHang as N'Xếp hạng',
	cc.NgayCap as N'Ngày cấp',
	cc.NgayHetHan as N'Ngày hết hạn'
    FROM CHUNG_CHI cc
	JOIN THI_SINH ts ON cc.MaTS = ts.MaTS
	JOIN LOAI_CHUNG_CHI lcc on cc.MaLCC = lcc.MaLCC
    WHERE RIGHT(ts.MaKH, 6) = RIGHT('000000' + LTRIM(RTRIM(@v_makh)), 6)
    AND ts.MaKH LIKE 'KHHG[0-9][0-9][0-9][0-9][0-9][0-9]')
GO
-- SELECT * FROM F_MaKH_to_CHUNG_CHI_THI_SINH_NVTN('KHHG000009');

GO
CREATE OR ALTER PROCEDURE P_UPDATE_CHUNG_CHI_NVTN
    @v_macc varchar(10)
AS
BEGIN
	UPDATE CHUNG_CHI
	SET TrangThai = N'Đã trả'
	WHERE MaCC = @v_macc
	AND TrangThai = N'Chưa trả'
END
GO

GO
CREATE OR ALTER TRIGGER T_UPDATE_KET_QUA_THI_IELTS_NVNL
ON KET_QUA_THI
FOR UPDATE
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @MaKQT VARCHAR(10), @DiemSo FLOAT, @MaLCC VARCHAR(10), @TenLoaiChungChi NVARCHAR(100);
    DECLARE cursor_ketquathi CURSOR FOR
        SELECT i.MaKQT, i.DiemSo, i.MaLCC, lcc.TenLoaiChungChi
        FROM inserted i
        LEFT JOIN LOAI_CHUNG_CHI lcc ON i.MaLCC = lcc.MaLCC;
    OPEN cursor_ketquathi;
    FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    WHILE @@FETCH_STATUS = 0
	BEGIN
        -- Chỉ kiểm tra nếu là chứng chỉ IELTS
        IF @TenLoaiChungChi = N'IELTS'
        BEGIN
            -- Kiểm tra điểm từ 1.0 đến 9.0
            IF @DiemSo < 1.0
            BEGIN
                THROW 51000, 'Điểm IELTS không thể thấp hơn 1.0.', 1;
                RETURN;
            END
            ELSE IF @DiemSo > 9.0
            BEGIN
                THROW 51000, 'Điểm IELTS không thể cao hơn 9.0.', 1;
                RETURN;
            END
            -- Kiểm tra điểm cách nhau 0.5
            ELSE IF (@DiemSo * 2) != FLOOR(@DiemSo * 2)
            BEGIN
                THROW 51000, 'Điểm IELTS phải cách nhau 0.5 (ví dụ: 1.0, 1.5, 2.0, ...).', 1;
                RETURN;
            END
        END
        FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    END
    CLOSE cursor_ketquathi;
    DEALLOCATE cursor_ketquathi;
END
GO

GO
CREATE OR ALTER TRIGGER T_UPDATE_KET_QUA_THI_TOEIC_NVNL
ON KET_QUA_THI
FOR UPDATE
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @MaKQT VARCHAR(10), @DiemSo FLOAT, @MaLCC VARCHAR(10), @TenLoaiChungChi NVARCHAR(100);
    DECLARE cursor_ketquathi CURSOR FOR
        SELECT i.MaKQT, i.DiemSo, i.MaLCC, lcc.TenLoaiChungChi
        FROM inserted i
        LEFT JOIN LOAI_CHUNG_CHI lcc ON i.MaLCC = lcc.MaLCC;
    OPEN cursor_ketquathi;
    FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Chỉ kiểm tra nếu là chứng chỉ TOEIC
        IF @TenLoaiChungChi = N'TOEIC'
        BEGIN
            -- Kiểm tra điểm từ 0 đến 990
            IF @DiemSo < 0.0
            BEGIN
                THROW 51000, 'Điểm TOEIC không thể thấp hơn 0.', 1;
                RETURN;
            END
            ELSE IF @DiemSo > 990.0
            BEGIN
                THROW 51000, 'Điểm TOEIC không thể cao hơn 990.', 1;
                RETURN;
            END
            -- Kiểm tra điểm là số tự nhiên
            ELSE IF (@DiemSo * 10) != (FLOOR(@DiemSo) * 10)
            BEGIN
                THROW 51000, 'Điểm TOEIC phải là số tự nhiên.', 1;
                RETURN;
            END
        END
        FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    END
    CLOSE cursor_ketquathi;
    DEALLOCATE cursor_ketquathi;
END
GO

GO
CREATE OR ALTER TRIGGER T_UPDATE_KET_QUA_THI_MOS_NVNL
ON KET_QUA_THI
FOR UPDATE
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @MaKQT VARCHAR(10), @DiemSo FLOAT, @MaLCC VARCHAR(10), @TenLoaiChungChi NVARCHAR(100);
    DECLARE cursor_ketquathi CURSOR FOR
        SELECT i.MaKQT, i.DiemSo, i.MaLCC, lcc.TenLoaiChungChi
        FROM inserted i
        LEFT JOIN LOAI_CHUNG_CHI lcc ON i.MaLCC = lcc.MaLCC;
    OPEN cursor_ketquathi;
    FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Chỉ kiểm tra nếu là chứng chỉ MOS
        IF @TenLoaiChungChi = N'MOS%'
        BEGIN
            -- Kiểm tra điểm từ 0 đến 1000
            IF @DiemSo < 0.0
            BEGIN
                THROW 51000, 'Điểm MOS không thể thấp hơn 0.', 1;
                RETURN;
            END
            ELSE IF @DiemSo > 990.0
            BEGIN
                THROW 51000, 'Điểm MOS không thể cao hơn 1000.', 1;
                RETURN;
            END
            -- Kiểm tra điểm là số tự nhiên
            ELSE IF (@DiemSo * 10) != (FLOOR(@DiemSo) * 10)
            BEGIN
                THROW 51000, 'Điểm MOS phải là số tự nhiên.', 1;
                RETURN;
            END
        END
        FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    END
    CLOSE cursor_ketquathi;
    DEALLOCATE cursor_ketquathi;
END
GO

/*GO
CREATE OR ALTER TRIGGER T_UPDATE_KET_QUA_THI_INSERT_CHUNG_CHI_NVNL
ON KET_QUA_THI
AFTER UPDATE
AS
BEGIN
SELECT 
    DECLARE @MaKQT VARCHAR(10), @DiemSo FLOAT, @MaLCC VARCHAR(10), @TenLoaiChungChi NVARCHAR(100), @DiemChuan FLOAT, @XepHang VARCHAR(10);
    DECLARE cursor_ketquathi CURSOR FOR
        SELECT i.MaKQT, i.DiemSo, i.MaLCC, lcc.TenLoaiChungChi, lcc.DiemChuan
        FROM inserted i
        LEFT JOIN LOAI_CHUNG_CHI lcc ON i.MaLCC = lcc.MaLCC;
    OPEN cursor_ketquathi;
    FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi, @DiemChuan;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Chỉ kiểm tra nếu là chứng chỉ IELTS
        IF @TenLoaiChungChi = N'IELTS'
        BEGIN
            -- Kiểm tra điểm từ 1.0 đến 9.0
            IF @DiemChuan >= (SELECT DiemChuan FROM LOAI_CHUNG_CHI WHERE TenLoaiChungChi = N'IELTS')
            BEGIN
                SET @XepHang = (
					SELECT TOP 1 XepHang FROM XEP_HANG_CHUNG_CHI
					WHERE @MaLCC = MaLCC
					AND @DiemSo >= DiemSan
					AND @DiemSo <= DiemSan)
            END
        END
        FETCH NEXT FROM cursor_ketquathi INTO @MaKQT, @DiemSo, @MaLCC, @TenLoaiChungChi;
    END
    CLOSE cursor_ketquathi;
    DEALLOCATE cursor_ketquathi;
END
GO*/

SELECT o.name, m.definition, o.type_desc 
  FROM sys.sql_modules m 
INNER JOIN sys.objects o 
        ON m.object_id=o.object_id
WHERE o.type_desc like '%function%';
-- drop function F_MaKQT_to_KET_QUA_THI_NVTN