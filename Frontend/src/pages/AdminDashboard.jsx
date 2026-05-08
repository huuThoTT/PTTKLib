import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
} from 'recharts';
import {
  getDashboardStats, getDashboardRevenue,
  getDashboardCerts, getDashboardTx,
} from '../services/api';
import './AdminDashboard.css';

const CERT_COLORS = ['#00f0ff','#7000ff','#10b981','#f59e0b','#ef4444','#3b82f6'];
const fmtVND = (n) => new Intl.NumberFormat('vi-VN').format(n);

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [stats, setStats]   = useState(null);
  const [revenue, setRevenue] = useState([]);
  const [certs, setCerts]   = useState([]);
  const [txns, setTxns]     = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      getDashboardStats(), getDashboardRevenue(),
      getDashboardCerts(), getDashboardTx(),
    ]).then(([s, r, c, t]) => {
      setStats(s); setRevenue(r); setCerts(c); setTxns(t);
    }).finally(() => setLoading(false));
  }, []);

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-logo">
          <div className="logo-icon">🛡</div>
          <span>ACCI<strong>Center</strong></span>
        </div>
        <nav className="sidebar-nav">
          <a href="#" className="nav-item active">📊 Dashboard</a>
          <a href="#" className="nav-item">👤 Candidates</a>
          <a href="#" className="nav-item">📋 Certificates</a>
          <a href="#" className="nav-item">💳 Transactions</a>
        </nav>
        <div className="sidebar-footer">
          <img src="https://i.pravatar.cc/40?img=11" alt="Admin" className="avatar" />
          <div><strong>Thai Son</strong><span>Business Analyst</span></div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="admin-main">
        <div className="admin-topbar">
          <h1>Overview Analytics</h1>
          <p>Real-time insights from your certificate center.</p>
          <button className="back-btn" onClick={() => navigate('/')}>← Trang chủ</button>
        </div>

        {loading ? (
          <div className="loading">⏳ Đang tải dữ liệu từ API...</div>
        ) : (
          <>
            {/* KPI Cards */}
            <div className="kpi-grid">
              <KpiCard icon="💰" label="Tổng doanh thu (VNĐ)" value={fmtVND(stats?.tong_doanh_thu)} trend="+12.5%" />
              <KpiCard icon="👥" label="Tổng thí sinh"        value={fmtVND(stats?.tong_thi_sinh)}  trend="+5.2%" />
              <KpiCard icon="📈" label="Tỉ lệ đạt"            value={`${stats?.ty_le_dat}%`}         trend="+1.1%" />
              <KpiCard icon="🏆" label="Chứng chỉ hot nhất"   value={stats?.chung_chi_hot_nhat}       sub="By Revenue" />
            </div>

            {/* Charts Row */}
            <div className="charts-row">
              {/* Revenue Line Chart */}
              <div className="chart-card wide">
                <h3>Revenue Overview (Monthly)</h3>
                <ResponsiveContainer width="100%" height={260}>
                  <LineChart data={revenue} margin={{ top: 10, right: 20, left: 10, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.07)" />
                    <XAxis dataKey="thang" tick={{ fontSize: 11 }} />
                    <YAxis tickFormatter={v => (v/1e6).toFixed(0)+'M'} tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(v) => [fmtVND(v) + ' VNĐ', 'Doanh thu']} />
                    <Line type="monotone" dataKey="doanh_thu" stroke="#00f0ff" strokeWidth={2} dot={{ r: 3 }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              {/* Cert Pie Chart */}
              <div className="chart-card narrow">
                <h3>Registrations by Certificate</h3>
                <ResponsiveContainer width="100%" height={260}>
                  <PieChart>
                    <Pie data={certs} dataKey="so_luong" nameKey="ten_chung_chi"
                      cx="50%" cy="50%" innerRadius={60} outerRadius={90}>
                      {certs.map((_, i) => <Cell key={i} fill={CERT_COLORS[i % CERT_COLORS.length]} />)}
                    </Pie>
                    <Legend formatter={(v) => v} wrapperStyle={{ fontSize: 12 }} />
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Transactions Table */}
            <div className="table-card">
              <h3>Recent Transactions</h3>
              <table className="tx-table">
                <thead>
                  <tr>
                    <th>Mã GD</th><th>Ngày</th><th>Chứng chỉ</th>
                    <th>Hình thức TT</th><th>Số tiền</th><th>Kết quả</th>
                  </tr>
                </thead>
                <tbody>
                  {txns.map(t => (
                    <tr key={t.ma_giao_dich}>
                      <td><strong>{t.ma_giao_dich}</strong></td>
                      <td>{t.ngay_thanh_toan}</td>
                      <td>{t.ten_chung_chi}</td>
                      <td>{t.hinh_thuc_tt}</td>
                      <td>{fmtVND(t.so_tien)}</td>
                      <td><span className={`badge ${t.trang_thai_thi === 'Đạt' ? 'dat' : 'fail'}`}>{t.trang_thai_thi}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </main>
    </div>
  );
}

function KpiCard({ icon, label, value, trend, sub }) {
  return (
    <div className="kpi-card">
      <div className="kpi-icon">{icon}</div>
      <div className="kpi-body">
        <span className="kpi-label">{label}</span>
        <strong className="kpi-value">{value}</strong>
        {trend && <span className="kpi-trend">↑ {trend}</span>}
        {sub   && <span className="kpi-sub">{sub}</span>}
      </div>
    </div>
  );
}
