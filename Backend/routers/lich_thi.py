from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import LichThi, LoaiChungChi
from schemas import LichThiResponse, SlotInfo

router = APIRouter(prefix="/api/lich-thi", tags=["Lịch Thi"])

SCHEDULE_NOTES = {
    "IELTS":  "Lịch thi IELTS: Thứ 7 hàng tuần. Đặt chỗ trước tối thiểu 3 tuần.",
    "TOEIC":  "Lịch thi TOEIC: Chủ nhật hàng tuần. Đặt chỗ trước tối thiểu 2 tuần.",
    "VSTEP":  "Lịch thi VSTEP: Cuối mỗi tháng. Đặt chỗ trước tối thiểu 4 tuần.",
    "MOS":    "Lịch thi MOS: Thứ 4 và Thứ 6 hàng tuần.",
    "IC3":    "Lịch thi IC3: Thứ 3 và Thứ 5 hàng tuần.",
}


@router.get("", response_model=LichThiResponse)
def get_lich_thi(cert: str, db: Session = Depends(get_db)):
    """
    Lấy danh sách lịch thi theo loại chứng chỉ.
    Mỗi lịch thi có thông tin slot: so_luong_toi_da, so_luong_da_dang_ky, so_luong_con_lai.
    """
    cert = cert.upper()
    loai = db.query(LoaiChungChi).filter(LoaiChungChi.ma_lcc == cert).first()
    if not loai:
        raise HTTPException(status_code=404, detail=f"Không tìm thấy chứng chỉ: {cert}")

    from datetime import datetime
    now = datetime.now()

    lich_this = (
        db.query(LichThi)
        .filter(LichThi.ma_lcc == cert, LichThi.ngay_gio_thi > now)
        .order_by(LichThi.ngay_gio_thi)
        .all()
    )

    slots = [
        SlotInfo(
            lich_thi_id         = lt.id,
            ngay_thi            = lt.ngay_gio_thi,
            so_luong_toi_da     = lt.so_luong_toi_da,
            so_luong_da_dang_ky = lt.so_luong_da_dang_ky,
            so_luong_con_lai    = lt.so_luong_con_lai,
            is_full             = lt.so_luong_con_lai <= 0,
        )
        for lt in lich_this
    ]

    return LichThiResponse(
        ma_lcc    = loai.ma_lcc,
        ten_loai  = loai.ten_loai,
        hoc_phi   = loai.hoc_phi,
        note      = SCHEDULE_NOTES.get(cert, ""),
        slots     = slots,
    )
