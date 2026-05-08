from sqlalchemy.orm import Session
from fastapi import Depends
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine
import models
from database import get_db



# Tạo tất cả bảng trong PostgreSQL (nếu chưa có)
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ACCI Center API",
    description="Backend API cho hệ thống quản lý trung tâm chứng chỉ ACCI. "
                "Được xây dựng bằng Python FastAPI + PostgreSQL.",
    version="1.0.0",
)

# CORS: Cho phép Frontend (localhost:8000) gọi API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8000", "http://127.0.0.1:8000", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Đăng ký các router
from routers import lich_thi, dang_ky, dashboard
app.include_router(lich_thi.router)
app.include_router(dang_ky.router)
app.include_router(dashboard.router)


@app.get("/", tags=["Health"])
def root():
    return {
        "message": "ACCI Center API đang chạy!",
        "docs": "/docs",
        "version": "1.0.0",
    }

@app.get("/test-db")
def test_db(db: Session = Depends(get_db)):
    result = db.query(models.LoaiChungChi).all()
    return result
