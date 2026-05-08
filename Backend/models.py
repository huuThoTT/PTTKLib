"""
models.py — SQLAlchemy ORM Models cho PostgreSQL
Dịch đầy đủ từ schema SQL Server gốc (scriptACCI.sql)
Tổng cộng: 14 bảng chính + 3 bảng phụ (gia hạn) = 17 models
"""

from sqlalchemy import (
    Column, Integer, String, Float, DateTime, Date,
    ForeignKey, func, UniqueConstraint
)
from sqlalchemy.orm import relationship
from database import Base


# ═══════════════════════════════════════════════════════════════
# 1. KHACH_HANG
# ═══════════════════════════════════════════════════════════════
class KhachHang(Base):
    """Khách hàng (tổ chức/cá nhân đăng ký cho thí sinh)"""
    __tablename__ = "khach_hang"

    id      = Column(Integer, primary_key=True, index=True)
    ma_kh   = Column(String(10), unique=True, index=True)  # KHHG000001
    ten_kh  = Column(String(100))
    loai_kh = Column(String(12))    # Cá nhân / Tổ chức
    sdt     = Column(String(12))
    dia_chi = Column(String(100))
    email   = Column(String(100))

    thi_sinhs     = relationship("ThiSinh", back_populates="khach_hang")
    phieu_dang_kys = relationship("PhieuDangKy", back_populates="khach_hang")


# ═══════════════════════════════════════════════════════════════
# 2. THI_SINH
# ═══════════════════════════════════════════════════════════════
class ThiSinh(Base):
    """Thí sinh dự thi"""
    __tablename__ = "thi_sinh"

    id        = Column(Integer, primary_key=True, index=True)
    ma_ts     = Column(String(10), unique=True, index=True)  # THSH000001
    ten_ts    = Column(String(100))
    ngay_sinh = Column(Date)
    cccd      = Column(String(12))
    ma_kh     = Column(String(10), ForeignKey("khach_hang.ma_kh"))

    khach_hang      = relationship("KhachHang", back_populates="thi_sinhs")
    phieu_dang_kys  = relationship("PhieuDangKy", back_populates="thi_sinh")
    phieu_du_this   = relationship("PhieuDuThi", back_populates="thi_sinh")
    ket_qua_this    = relationship("KetQuaThi", back_populates="thi_sinh")
    chung_chis      = relationship("ChungChi", back_populates="thi_sinh")


# ═══════════════════════════════════════════════════════════════
# 3. NHAN_VIEN
# ═══════════════════════════════════════════════════════════════
class NhanVien(Base):
    """Nhân viên trung tâm (tiếp nhận, giám thị, kế toán)"""
    __tablename__ = "nhan_vien"

    id              = Column(Integer, primary_key=True, index=True)
    ma_nv           = Column(String(10), unique=True, index=True)  # NHVN000001
    ten_nhan_vien   = Column(String(100))
    ngay_sinh       = Column(Date)
    email           = Column(String(100))
    sdt             = Column(String(12))
    dia_chi         = Column(String(100))
    cccd            = Column(String(12))
    loai_nhan_vien  = Column(String(20))  # Tiếp nhận / Giám thị / Kế toán

    lich_thi_giam_this  = relationship("NhanVienGiamThiLichThi", back_populates="nhan_vien")


# ═══════════════════════════════════════════════════════════════
# 4. PHONG_THI
# ═══════════════════════════════════════════════════════════════
class PhongThi(Base):
    """Phòng thi (sức chứa, trạng thái)"""
    __tablename__ = "phong_thi"

    id          = Column(Integer, primary_key=True, index=True)
    ma_pt       = Column(String(10), unique=True, index=True)  # PHTI000001
    suc_chua    = Column(Integer)
    trang_thai  = Column(String(12))  # Trống / Đang dùng / Bảo trì

    lich_this = relationship("LichThi", back_populates="phong_thi")


# ═══════════════════════════════════════════════════════════════
# 5. LOAI_CHUNG_CHI
# ═══════════════════════════════════════════════════════════════
class LoaiChungChi(Base):
    """Loại chứng chỉ: IELTS, TOEIC, MOS, IC3, VSTEP..."""
    __tablename__ = "loai_chung_chi"

    id              = Column(Integer, primary_key=True, index=True)
    ma_lcc          = Column(String(10), unique=True, index=True)  # LOCC000001
    ten_loai        = Column(String(100))
    linh_vuc        = Column(String(100))   # Ngoại Ngữ / Tin Học
    diem_chuan      = Column(Float)
    thoi_han        = Column(Integer)       # Thời hạn chứng chỉ (tháng)
    hoc_phi         = Column(Float)         # Thêm để Web App dùng
    hinh_anh        = Column(String,nullable=True)

    xep_hang_chung_chis = relationship("XepHangChungChi", back_populates="loai_chung_chi")
    lich_this           = relationship("LichThi", back_populates="loai_chung_chi")
    phieu_dang_kys      = relationship("PhieuDangKy", back_populates="loai_chung_chi")
    ket_qua_this        = relationship("KetQuaThi", back_populates="loai_chung_chi")
    chung_chis          = relationship("ChungChi", back_populates="loai_chung_chi")


# ═══════════════════════════════════════════════════════════════
# 6. XEP_HANG_CHUNG_CHI
# ═══════════════════════════════════════════════════════════════
class XepHangChungChi(Base):
    """Bảng xếp hạng từng loại chứng chỉ (A, B, C / Band score...)"""
    __tablename__ = "xep_hang_chung_chi"
    __table_args__ = (
        UniqueConstraint("ma_lcc", "xep_hang", name="uq_xhcc_malcc_xephang"),
    )

    id       = Column(Integer, primary_key=True, index=True)
    ma_lcc   = Column(String(10), ForeignKey("loai_chung_chi.ma_lcc"))
    xep_hang = Column(String(10))   # A, B, C / Band 5.0, 5.5...
    diem_san = Column(Float)
    diem_tran = Column(Float)

    loai_chung_chi = relationship("LoaiChungChi", back_populates="xep_hang_chung_chis")


# ═══════════════════════════════════════════════════════════════
# 7. LICH_THI
# ═══════════════════════════════════════════════════════════════
class LichThi(Base):
    """Lịch thi — quản lý slot đăng ký"""
    __tablename__ = "lich_thi"

    id                   = Column(Integer, primary_key=True, index=True)
    ma_lt                = Column(String(10), unique=True, index=True)  # LICH000001
    ngay_gio_thi         = Column(DateTime, nullable=False)
    so_luong_toi_da      = Column(Integer, nullable=False)
    so_luong_da_dang_ky  = Column(Integer, default=0)
    ma_lcc               = Column(String(10), ForeignKey("loai_chung_chi.ma_lcc"))
    ma_pt                = Column(String(10), ForeignKey("phong_thi.ma_pt"), nullable=True)

    loai_chung_chi  = relationship("LoaiChungChi", back_populates="lich_this")
    phong_thi       = relationship("PhongThi", back_populates="lich_this")
    giam_this       = relationship("NhanVienGiamThiLichThi", back_populates="lich_thi")
    phieu_dang_kys  = relationship("PhieuDangKy", back_populates="lich_thi")
    phieu_du_this   = relationship("PhieuDuThi", back_populates="lich_thi")
    dia_diem        = Column(String(100))

    @property
    def so_luong_con_lai(self):
        return self.so_luong_toi_da - self.so_luong_da_dang_ky


# ═══════════════════════════════════════════════════════════════
# 8. NHAN_VIEN_GIAM_THI_LICH_THI (bảng trung gian N-N)
# ═══════════════════════════════════════════════════════════════
class NhanVienGiamThiLichThi(Base):
    """Phân công giám thị cho từng lịch thi"""
    __tablename__ = "nhan_vien_giam_thi_lich_thi"
    __table_args__ = (
        UniqueConstraint("ma_lt", "ma_nv", name="uq_nvgtlt_lt_nv"),
    )

    id      = Column(Integer, primary_key=True, index=True)
    ma_lt   = Column(String(10), ForeignKey("lich_thi.ma_lt"))
    ma_nv   = Column(String(10), ForeignKey("nhan_vien.ma_nv"))
    vai_tro = Column(String(100))  # Giám thị chính / Hành lang / Thư ký

    lich_thi   = relationship("LichThi", back_populates="giam_this")
    nhan_vien  = relationship("NhanVien", back_populates="lich_thi_giam_this")


# ═══════════════════════════════════════════════════════════════
# 9. PHIEU_DANG_KY
# ═══════════════════════════════════════════════════════════════
class PhieuDangKy(Base):
    """Phiếu đăng ký thi của thí sinh"""
    __tablename__ = "phieu_dang_ky"

    id              = Column(Integer, primary_key=True, index=True)
    ma_pdk          = Column(String(10), unique=True, index=True)  # PHDK000001
    ngay_lap_pdk    = Column(Date, default=func.current_date())
    trang_thai      = Column(String(12))    # Chờ TT / Đã TT / Hủy
    han_thanh_toan  = Column(Date)
    ma_lcc          = Column(String(10), ForeignKey("loai_chung_chi.ma_lcc"))
    ma_lt           = Column(String(10), ForeignKey("lich_thi.ma_lt"))
    ma_kh           = Column(String(10), ForeignKey("khach_hang.ma_kh"), nullable=True)
    ma_ts           = Column(String(10), ForeignKey("thi_sinh.ma_ts"), nullable=True)
    ma_nv_tiep_nhan = Column(String(10), ForeignKey("nhan_vien.ma_nv"), nullable=True)

    loai_chung_chi = relationship("LoaiChungChi", back_populates="phieu_dang_kys")
    lich_thi       = relationship("LichThi", back_populates="phieu_dang_kys")
    khach_hang     = relationship("KhachHang", back_populates="phieu_dang_kys")
    thi_sinh       = relationship("ThiSinh", back_populates="phieu_dang_kys")
    hoa_dons       = relationship("HoaDon", back_populates="phieu_dang_ky")


# ═══════════════════════════════════════════════════════════════
# 10. HOA_DON
# ═══════════════════════════════════════════════════════════════
class HoaDon(Base):
    """Hóa đơn thanh toán lệ phí thi"""
    __tablename__ = "hoa_don"

    id                  = Column(Integer, primary_key=True, index=True)
    ma_hd               = Column(String(12), unique=True, index=True)
    ngay_gio_thanh_toan = Column(DateTime)
    so_tien_thanh_toan  = Column(Float)
    hinh_thuc_thanh_toan = Column(String(50))
    chiet_khau          = Column(Float, default=0)
    ma_pdk              = Column(String(10), ForeignKey("phieu_dang_ky.ma_pdk"), nullable=True)
    ma_nv_ke_toan       = Column(String(10), ForeignKey("nhan_vien.ma_nv"), nullable=True)

    # Các cột mở rộng để dashboard không cần JOIN phức tạp
    ten_chung_chi   = Column(String(100))
    linh_vuc        = Column(String(50))
    tuoi_thi_sinh   = Column(Integer)
    ngay_thi        = Column(Date)
    diem_thi        = Column(Float, nullable=True)
    trang_thai_thi  = Column(String(20), nullable=True)

    phieu_dang_ky = relationship("PhieuDangKy", back_populates="hoa_dons")
    phieu_du_this = relationship("PhieuDuThi", back_populates="hoa_don")


# ═══════════════════════════════════════════════════════════════
# 11. PHIEU_DU_THI
# ═══════════════════════════════════════════════════════════════
class PhieuDuThi(Base):
    """Phiếu dự thi — cấp cho thí sinh sau khi thanh toán"""
    __tablename__ = "phieu_du_thi"

    id              = Column(Integer, primary_key=True, index=True)
    ma_pdt          = Column(String(10), unique=True, index=True)  # PHDT000001
    ngay_phat_hanh  = Column(Date)
    trang_thai      = Column(String(12))    # Hợp lệ / Đã dùng / Hết hạn
    thoi_gian_thi   = Column(DateTime)
    dia_diem_thi    = Column(String(100))
    ma_ts           = Column(String(10), ForeignKey("thi_sinh.ma_ts"))
    ma_lt           = Column(String(10), ForeignKey("lich_thi.ma_lt"))
    ma_hd           = Column(String(12), ForeignKey("hoa_don.ma_hd"), nullable=True)

    thi_sinh    = relationship("ThiSinh", back_populates="phieu_du_this")
    lich_thi    = relationship("LichThi", back_populates="phieu_du_this")
    hoa_don     = relationship("HoaDon", back_populates="phieu_du_this")
    ket_qua_this = relationship("KetQuaThi", back_populates="phieu_du_thi")
    gia_hans    = relationship("PhieuDuThiGiaHan", back_populates="phieu_du_thi")
    yeu_cau_gia_hans = relationship("YeuCauGiaHan", back_populates="phieu_du_thi")


# ═══════════════════════════════════════════════════════════════
# 12. KET_QUA_THI
# ═══════════════════════════════════════════════════════════════
class KetQuaThi(Base):
    """Kết quả thi (điểm số sau khi chấm thi)"""
    __tablename__ = "ket_qua_thi"

    id          = Column(Integer, primary_key=True, index=True)
    ma_kqt      = Column(String(10), unique=True, index=True)  # KQTH000001
    diem_so     = Column(Float)
    ngay_co_diem = Column(Date)
    ma_ts       = Column(String(10), ForeignKey("thi_sinh.ma_ts"))
    ma_lcc      = Column(String(10), ForeignKey("loai_chung_chi.ma_lcc"))
    ma_pdt      = Column(String(10), ForeignKey("phieu_du_thi.ma_pdt"))

    thi_sinh        = relationship("ThiSinh", back_populates="ket_qua_this")
    loai_chung_chi  = relationship("LoaiChungChi", back_populates="ket_qua_this")
    phieu_du_thi    = relationship("PhieuDuThi", back_populates="ket_qua_this")
    chung_chis      = relationship("ChungChi", back_populates="ket_qua_thi")


# ═══════════════════════════════════════════════════════════════
# 13. CHUNG_CHI
# ═══════════════════════════════════════════════════════════════
class ChungChi(Base):
    """Chứng chỉ được cấp cho thí sinh đạt yêu cầu"""
    __tablename__ = "chung_chi"

    id          = Column(Integer, primary_key=True, index=True)
    ma_cc       = Column(String(10), unique=True, index=True)  # CHCH000001
    diem_so     = Column(Float)
    xep_hang    = Column(String(10))    # A / B / C / Band score
    ngay_cap    = Column(Date)
    ngay_het_han = Column(Date)
    trang_thai  = Column(String(12))    # Hiệu lực / Hết hạn / Thu hồi
    ma_kqt      = Column(String(10), ForeignKey("ket_qua_thi.ma_kqt"))
    ma_ts       = Column(String(10), ForeignKey("thi_sinh.ma_ts"))
    ma_lcc      = Column(String(10), ForeignKey("loai_chung_chi.ma_lcc"))

    ket_qua_thi    = relationship("KetQuaThi", back_populates="chung_chis")
    thi_sinh       = relationship("ThiSinh", back_populates="chung_chis")
    loai_chung_chi = relationship("LoaiChungChi", back_populates="chung_chis")


# ═══════════════════════════════════════════════════════════════
# 14. PHIEU_DU_THI_GIA_HAN
# ═══════════════════════════════════════════════════════════════
class PhieuDuThiGiaHan(Base):
    """Gia hạn phiếu dự thi (thí sinh đổi lịch thi)"""
    __tablename__ = "phieu_du_thi_gia_han"

    id              = Column(Integer, primary_key=True, index=True)
    ma_pdtgh        = Column(String(10), unique=True, index=True)  # DTGH000001
    ma_pdt          = Column(String(10), ForeignKey("phieu_du_thi.ma_pdt"))
    so_lan_con_lai  = Column(Integer)
    han_gia_han     = Column(Date)

    phieu_du_thi = relationship("PhieuDuThi", back_populates="gia_hans")


# ═══════════════════════════════════════════════════════════════
# 15. YEU_CAU_GIA_HAN
# ═══════════════════════════════════════════════════════════════
class YeuCauGiaHan(Base):
    """Yêu cầu gia hạn phiếu dự thi từ thí sinh"""
    __tablename__ = "yeu_cau_gia_han"

    id                  = Column(Integer, primary_key=True, index=True)
    ma_ycgh             = Column(String(10), unique=True, index=True)  # YCGH000001
    ngay_yeu_cau_gia_han = Column(Date)
    ly_do_gia_han       = Column(String(100))
    phi_gia_han         = Column(Float)
    ma_pdt              = Column(String(10), ForeignKey("phieu_du_thi.ma_pdt"))

    phieu_du_thi  = relationship("PhieuDuThi", back_populates="yeu_cau_gia_hans")
    hoa_don_gia_hans = relationship("HoaDonGiaHan", back_populates="yeu_cau_gia_han")


# ═══════════════════════════════════════════════════════════════
# 16. HOA_DON_GIA_HAN
# ═══════════════════════════════════════════════════════════════
class HoaDonGiaHan(Base):
    """Hóa đơn thanh toán phí gia hạn phiếu dự thi"""
    __tablename__ = "hoa_don_gia_han"

    id                      = Column(Integer, primary_key=True, index=True)
    ma_hdgh                 = Column(String(10), unique=True, index=True)  # HDGH000001
    ngay_gio_thanh_toan     = Column(DateTime)
    so_tien_thanh_toan      = Column(Float)
    hinh_thuc_thanh_toan    = Column(String(50))
    trang_thai              = Column(String(12))
    ma_pdt                  = Column(String(10), ForeignKey("phieu_du_thi.ma_pdt"))
    ma_ycgh                 = Column(String(10), ForeignKey("yeu_cau_gia_han.ma_ycgh"))
    ma_nv_ke_toan           = Column(String(10), ForeignKey("nhan_vien.ma_nv"), nullable=True)

    yeu_cau_gia_han = relationship("YeuCauGiaHan", back_populates="hoa_don_gia_hans")
