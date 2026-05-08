from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models import HoaDon
from schemas import DashboardStats, RevenueByMonth, CertificateCount, TransactionRow

router = APIRouter(prefix="/api/dashboard", tags=["Dashboard"])


@router.get("/stats", response_model=DashboardStats)
def get_stats(db: Session = Depends(get_db)):
    total_revenue = db.query(func.sum(HoaDon.so_tien_thanh_toan)).scalar() or 0
    total_records = db.query(func.count(HoaDon.id)).scalar() or 0
    dat_count = db.query(func.count(HoaDon.id)).filter(
        HoaDon.trang_thai_thi == "Đạt"
    ).scalar() or 0
    ty_le_dat = (dat_count / total_records * 100) if total_records > 0 else 0
    top_cert = (
        db.query(HoaDon.ten_chung_chi, func.count(HoaDon.id).label("cnt"))
        .group_by(HoaDon.ten_chung_chi)
        .order_by(func.count(HoaDon.id).desc())
        .first()
    )
    return DashboardStats(
        tong_doanh_thu      = total_revenue,
        tong_thi_sinh       = total_records,
        ty_le_dat           = round(ty_le_dat, 1),
        chung_chi_hot_nhat  = top_cert[0] if top_cert else "N/A",
    )


@router.get("/revenue", response_model=list[RevenueByMonth])
def get_revenue_by_month(db: Session = Depends(get_db)):
    results = (
        db.query(
            func.to_char(HoaDon.ngay_gio_thanh_toan, "YYYY-MM").label("thang"),
            func.sum(HoaDon.so_tien_thanh_toan).label("doanh_thu"),
        )
        .group_by("thang")
        .order_by("thang")
        .all()
    )
    return [RevenueByMonth(thang=r.thang, doanh_thu=r.doanh_thu) for r in results]


@router.get("/certificates", response_model=list[CertificateCount])
def get_cert_distribution(db: Session = Depends(get_db)):
    results = (
        db.query(
            HoaDon.ten_chung_chi,
            func.count(HoaDon.id).label("so_luong"),
        )
        .group_by(HoaDon.ten_chung_chi)
        .order_by(func.count(HoaDon.id).desc())
        .all()
    )
    return [CertificateCount(ten_chung_chi=r.ten_chung_chi, so_luong=r.so_luong) for r in results]


@router.get("/transactions", response_model=list[TransactionRow])
def get_recent_transactions(db: Session = Depends(get_db)):
    results = (
        db.query(HoaDon)
        .order_by(HoaDon.ngay_gio_thanh_toan.desc())
        .limit(10)
        .all()
    )
    return [
        TransactionRow(
            ma_giao_dich    = r.ma_hd,
            ngay_thanh_toan = r.ngay_gio_thanh_toan.strftime("%Y-%m-%d") if r.ngay_gio_thanh_toan else "",
            ten_chung_chi   = r.ten_chung_chi or "",
            hinh_thuc_tt    = r.hinh_thuc_thanh_toan or "",
            so_tien         = r.so_tien_thanh_toan or 0,
            trang_thai_thi  = r.trang_thai_thi,
        )
        for r in results
    ]
