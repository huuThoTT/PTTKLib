import { Link, useLocation } from 'react-router-dom';
import './Navbar.css';

export default function Navbar() {
  const { pathname } = useLocation();
  return (
    <header className="navbar">
      <div className="nav-container">
        <Link to="/" className="nav-logo">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="#0052cc" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/>
          </svg>
          <span>ACCI<strong>Center</strong></span>
        </Link>
        <nav className="nav-links">
          <Link to="/" className={pathname === '/' ? 'active' : ''}>Trang chủ</Link>
          <a href="#">Lịch thi</a>
          <a href="#">Tra cứu điểm</a>
          <Link to="/dang-ky" className={`nav-btn ${pathname === '/dang-ky' ? 'active' : ''}`}>
            Đăng ký thi
          </Link>
        </nav>
      </div>
    </header>
  );
}
