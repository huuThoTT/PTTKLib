from pydantic import BaseModel, EmailStr
from datetime import date, datetime
from typing import Optional


# ─── Lịch Thi ───────────────────────────────────────────────────────────────

class SlotInfo(BaseModel):
    lich_thi_id:        int
    ngay_thi:           datetime
    so_luong_toi_da:    int
    so_luong_da_dang_ky: int
    so_luong_con_lai:   int
    is_full:            bool

    class Config:
        from_attributes = True


class LichThiResponse(BaseModel):
    ma_lcc:     str
    ten_loai:   str
    hoc_phi:    float
    note:       str
    slots:      list[SlotInfo]


# ─── Đăng Ký ────────────────────────────────────────────────────────────────

class DangKyRequest(BaseModel):
    ho_ten:         str
    ngay_sinh:      date
    cccd:           str
    so_dien_thoai:  str
    email:          EmailStr
    ma_lcc:         str
    lich_thi_id:    int
    hinh_thuc_tt:   str  # Chuyển khoản, Tiền mặt, Momo, VNPay


class DangKyResponse(BaseModel):
    ma_pdk:         str
    ho_ten:         str
    ma_lcc:         str
    ngay_thi:       datetime
    dia_diem:       str
    trang_thai:     str
    message:        str


# ─── Dashboard ──────────────────────────────────────────────────────────────

class DashboardStats(BaseModel):
    tong_doanh_thu:     float
    tong_thi_sinh:      int
    ty_le_dat:          float
    chung_chi_hot_nhat: str


class RevenueByMonth(BaseModel):
    thang:      str  # "2023-01"
    doanh_thu:  float


class CertificateCount(BaseModel):
    ten_chung_chi:  str
    so_luong:       int
    hinh_anh: Optional[str] = None


class TransactionRow(BaseModel):
    ma_giao_dich:       str
    ngay_thanh_toan:    str
    ten_chung_chi:      str
    hinh_thuc_tt:       str
    so_tien:            float
    trang_thai_thi:     Optional[str]
