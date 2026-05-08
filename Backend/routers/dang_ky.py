from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import LichThi, PhieuDangKy
from schemas import DangKyRequest, DangKyResponse
import uuid
from datetime import datetime

router = APIRouter(prefix="/api/dang-ky", tags=["Đăng Ký"])


@router.post("", response_model=DangKyResponse, status_code=201)
def dang_ky_thi(payload: DangKyRequest, db: Session = Depends(get_db)):
    """
    Thí sinh đăng ký thi.
    - Kiểm tra lịch thi còn slot không.
    - Tạo phiếu đăng ký mới.
    - Tăng so_luong_da_dang_ky lên 1 (atomic update).
    """
    # 1. Kiểm tra lịch thi tồn tại
    lich_thi = db.query(LichThi).filter(LichThi.id == payload.lich_thi_id).first()
    if not lich_thi:
        raise HTTPException(status_code=404, detail="Lịch thi không tồn tại.")

    # 2. Kiểm tra còn slot
    if lich_thi.so_luong_con_lai <= 0:
        raise HTTPException(
            status_code=409,
            detail="Lịch thi này đã đầy. Vui lòng chọn lịch thi khác."
        )

    # 3. Kiểm tra thí sinh đã đăng ký lịch này chưa (theo CCCD)
    existing = db.query(PhieuDangKy).filter(
        PhieuDangKy.cccd == payload.cccd,
        PhieuDangKy.lich_thi_id == payload.lich_thi_id
    ).first()
    if existing:
        raise HTTPException(
            status_code=409,
            detail="CCCD này đã được đăng ký vào lịch thi này rồi."
        )

    # 4. Tạo mã phiếu đăng ký
    ma_pdk = "PDK" + uuid.uuid4().hex[:7].upper()

    # 5. Tạo phiếu đăng ký
    phieu = PhieuDangKy(
        ma_pdk          = ma_pdk,
        ho_ten          = payload.ho_ten.upper(),
        ngay_sinh       = payload.ngay_sinh,
        cccd            = payload.cccd,
        so_dien_thoai   = payload.so_dien_thoai,
        email           = payload.email,
        ma_lcc          = payload.ma_lcc,
        lich_thi_id     = payload.lich_thi_id,
        trang_thai      = "Chờ TT",
        ngay_dang_ky    = datetime.now(),
    )
    db.add(phieu)

    # 6. Tăng số lượng đã đăng ký
    lich_thi.so_luong_da_dang_ky += 1

    db.commit()
    db.refresh(phieu)

    return DangKyResponse(
        ma_pdk      = phieu.ma_pdk,
        ho_ten      = phieu.ho_ten,
        ma_lcc      = phieu.ma_lcc,
        ngay_thi    = lich_thi.ngay_gio_thi,
        dia_diem    = lich_thi.dia_diem,
        trang_thai  = phieu.trang_thai,
        message     = f"Đăng ký thành công! Mã phiếu: {ma_pdk}. Vui lòng kiểm tra email để thanh toán.",
    )
