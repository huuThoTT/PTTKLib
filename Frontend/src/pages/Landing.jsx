import { Link } from 'react-router-dom';
import Navbar from '../components/Navbar';
import './Landing.css';
//import ielstIcon from './assets/ielts.png'
import { useState, useEffect } from 'react';
import axios from 'axios';

const CERTS = [
  //  { icon: ielstIcon, name: 'IELTS', desc: 'Chứng chỉ tiếng Anh quốc tế', price: '4.500.000 VNĐ', badge: 'Phổ biến nhất' },
  { icon: '🎧', name: 'TOEIC', desc: 'Tiếng Anh thương mại 2 kỹ năng', price: '1.200.000 VNĐ', badge: 'Hot' },
  { icon: '📜', name: 'VSTEP', desc: 'Ngoại ngữ chuẩn Việt Nam (B1–C1)', price: '1.800.000 VNĐ', badge: '' },
  { icon: '💻', name: 'MOS', desc: 'Microsoft Office Specialist', price: '850.000 VNĐ', badge: '' },
  { icon: '🖥️', name: 'IC3', desc: 'Tin học cơ bản quốc tế', price: '750.000 VNĐ', badge: '' },
];


export default function Landing() {
  const [dbCerts, setDbCerts] = useState([]);

  useEffect(() => {
    // Hàm lấy dữ liệu
    const fetchData = async () => {
      try {
        const response = await axios.get('http://localhost:8001/test-db');
        setDbCerts(response.data);
        console.log("Dữ liệu từ DB: ", response.data);
      } catch (error) {
        console.error("Lỗi khi gọi API test-db: ", error)
      }
    };
    fetchData();
  }, []);
  return (
    <div className="landing">
      <Navbar />

      {/* Hero */}
      <section className="hero">
        <div className="hero-content">
          <div className="hero-left">
            <span className="hero-badge">Đối tác chính thức của IIG &amp; IDP</span>
            <h1>Chinh Phục Chứng Chỉ<br />Quốc Tế Cùng ACCI</h1>
            <p className="hero-sub">
              Nền tảng đăng ký thi trực tuyến tiện lợi, an toàn và nhanh chóng.
              Cam kết cung cấp môi trường thi chuẩn quốc tế cho mọi thí sinh.
            </p>
            <div className="hero-actions">
              <Link to="/dang-ky" className="btn-primary">Đăng Ký Thi Ngay →</Link>
              <a href="#certs" className="btn-secondary">Xem Lịch Thi</a>
            </div>
            <div className="hero-stats">
              <div><strong>50K+</strong><span>Thí sinh</span></div>
              <div><strong>98%</strong><span>Hài lòng</span></div>
              <div><strong>15+</strong><span>Cơ sở thi</span></div>
            </div>
          </div>
          <div className="hero-right">
            <img
              src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600&q=80"
              alt="Học sinh thi chứng chỉ"
              className="hero-img"
            />
            <div className="hero-float-card">
              <span className="float-icon">✅</span>
              <div>
                <strong>Đăng ký thành công</strong>
                <span>Nguyễn Văn A – IELTS Academic</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Certificate Cards */}
      <section className="certs-section" id="certs">
        <div className="section-container">
          <h2>Các Chứng Chỉ Tại ACCI</h2>
          <p className="section-sub">Chọn chứng chỉ phù hợp và đăng ký ngay hôm nay</p>
          <div className="certs-grid">
            {dbCerts.map(c => (
              <Link to="/dang-ky" key={c.ma_lcc} className="cert-card" style={{ textDecoration: 'none' }}>
                <div className="cert-icon">
                  {c.hinh_anh ? (
                    <img src={c.hinh_anh} alt={c.ten_loai} style={{ width: '100%', height: '100%' }} />
                  ) : (
                    <div style={{ fontSize: '40px' }}>🌐</div>
                  )}
                </div>
                {/* Không còn nút, không còn chữ ở đây nữa */}
              </Link>
            ))}
          </div>
        </div>
      </section >

      {/* Footer */}
      < footer className="footer" >
        <div className="footer-inner">
          <span>© 2024 ACCI Center. All rights reserved.</span>
          <a href="/admin" className="footer-admin-link">⚙ Admin</a>
        </div>
      </footer >
    </div >
  );
}
