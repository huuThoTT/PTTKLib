"""
seed_data.py
Nhập 1500 dòng dữ liệu từ WebApp/data.csv vào PostgreSQL (bảng hoa_don).
Đồng thời tạo dữ liệu mẫu cho loai_chung_chi và lich_thi.

Cách chạy:
    cd Backend
    python seed_data.py
"""

import sys
import os
import pandas as pd
from datetime import datetime, timedelta
import random

sys.path.insert(0, os.path.dirname(__file__))

from database import SessionLocal, engine
import models

# Tạo bảng nếu chưa có
models.Base.metadata.create_all(bind=engine)

CSV_PATH = os.path.join(os.path.dirname(__file__), "../WebApp/data.csv")


def seed_loai_chung_chi(db):
    print("📚 Seeding loai_chung_chi...")
    certs = [
        {"ma_lcc": "IELTS",  "ten_loai": "IELTS Academic / General", "linh_vuc": "Ngoại Ngữ", "hoc_phi": 4500000, "diem_chuan": 5.0},
        {"ma_lcc": "TOEIC",  "ten_loai": "TOEIC 2 kỹ năng",          "linh_vuc": "Ngoại Ngữ", "hoc_phi": 1200000, "diem_chuan": 550},
        {"ma_lcc": "VSTEP",  "ten_loai": "VSTEP (B1, B2, C1)",        "linh_vuc": "Ngoại Ngữ", "hoc_phi": 1800000, "diem_chuan": 4.0},
        {"ma_lcc": "MOS",    "ten_loai": "Microsoft Office Specialist","linh_vuc": "Tin Học",   "hoc_phi": 850000,  "diem_chuan": 700},
        {"ma_lcc": "IC3",    "ten_loai": "Tin học cơ bản IC3",         "linh_vuc": "Tin Học",   "hoc_phi": 750000,  "diem_chuan": 700},
    ]
    for c in certs:
        exists = db.query(models.LoaiChungChi).filter_by(ma_lcc=c["ma_lcc"]).first()
        if not exists:
            db.add(models.LoaiChungChi(**c))
    db.commit()
    print("   ✅ Xong loai_chung_chi")


def seed_lich_thi(db):
    print("📅 Seeding lich_thi...")
    schedules = {
        "IELTS": {"capacity": 25, "days_offset": [7, 14, 21, 28, 35, 42, 49, 56]},
        "TOEIC": {"capacity": 40, "days_offset": [7, 14, 21, 28, 35, 42, 49, 56]},
        "VSTEP": {"capacity": 50, "days_offset": [30, 60, 90, 120]},
        "MOS":   {"capacity": 20, "days_offset": [3, 7, 10, 14, 17, 21, 24, 28]},
        "IC3":   {"capacity": 15, "days_offset": [4, 8, 11, 15, 18, 22, 25, 29]},
    }
    base = datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)

    for ma_lcc, cfg in schedules.items():
        for offset in cfg["days_offset"]:
            ngay = base + timedelta(days=offset)
            # Simulate some slots already taken
            registered = random.randint(0, cfg["capacity"])
            if offset <= 14:  # Closer dates are more full
                registered = min(cfg["capacity"], int(cfg["capacity"] * random.uniform(0.6, 1.0)))

            exists = db.query(models.LichThi).filter_by(
                ma_lcc=ma_lcc, ngay_gio_thi=ngay
            ).first()
            if not exists:
                ma_lt = f"LICH{str(ma_lcc[:3]).upper()}{offset:03d}"
                db.add(models.LichThi(
                    ma_lt                = ma_lt,
                    ngay_gio_thi        = ngay,
                    so_luong_toi_da     = cfg["capacity"],
                    so_luong_da_dang_ky = registered,
                    ma_lcc              = ma_lcc,
                ))
    db.commit()
    print("   ✅ Xong lich_thi")


def seed_hoa_don(db):
    print("💳 Seeding hoa_don từ CSV...")
    if not os.path.exists(CSV_PATH):
        print(f"   ⚠️  Không tìm thấy file: {CSV_PATH}")
        return

    # Đọc CSV
    df = pd.read_csv(CSV_PATH)

    # Map tên chứng chỉ trong CSV sang ma_lcc
    cert_map = {
        "IELTS": "IELTS", "TOEIC": "TOEIC", "VSTEP": "VSTEP",
        "MOS Excel": "MOS", "MOS Word": "MOS", "IC3": "IC3",
    }

    existing_count = db.query(models.HoaDon).count()
    if existing_count > 0:
        print(f"   ℹ️  Đã có {existing_count} bản ghi, bỏ qua seed.")
        return

    records = []
    for _, row in df.iterrows():
        records.append(models.HoaDon(
            ma_hd                   = row["MaGiaoDich"],
            ngay_gio_thanh_toan     = datetime.strptime(row["NgayThanhToan"], "%Y-%m-%d"),
            so_tien_thanh_toan      = float(row["DoanhThuThucTe"]),
            hinh_thuc_thanh_toan    = row["PhuongThucThanhToan"],
            chiet_khau              = float(row["PhanTramGiamGia"]),
            ten_chung_chi           = row["TenChungChi"],
            linh_vuc                = row["LinhVuc"],
            tuoi_thi_sinh           = int(row["DoTuoiThiSinh"]),
            ngay_thi                = datetime.strptime(row["NgayThi"], "%Y-%m-%d").date(),
            diem_thi                = float(row["DiemThi"]),
            trang_thai_thi          = row["TrangThaiThi"],
        ))

    db.bulk_save_objects(records)
    db.commit()
    print(f"   ✅ Đã nhập {len(records)} dòng hoa_don từ CSV")


if __name__ == "__main__":
    print("🚀 Bắt đầu seed dữ liệu vào PostgreSQL...\n")
    db = SessionLocal()
    try:
        seed_loai_chung_chi(db)
        seed_lich_thi(db)
        seed_hoa_don(db)
        print("\n🎉 Seed dữ liệu hoàn tất!")
    except Exception as e:
        print(f"\n❌ Lỗi: {e}")
        db.rollback()
        raise
    finally:
        db.close()
