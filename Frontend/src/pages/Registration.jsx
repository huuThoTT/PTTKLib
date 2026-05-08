import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import SlotCalendar from '../components/SlotCalendar';
import { postDangKy } from '../services/api';
import './Registration.css';

const EXAMS = [
  { value: 'IELTS', label: 'IELTS Academic / General Training', price: 4500000 },
  { value: 'TOEIC', label: 'TOEIC 2 kỹ năng (Nghe & Đọc)', price: 1200000 },
  { value: 'VSTEP', label: 'VSTEP (B1, B2, C1)', price: 1800000 },
  { value: 'MOS', label: 'Tin học quốc tế MOS', price: 850000 },
  { value: 'IC3', label: 'Tin học cơ bản IC3', price: 750000 },
];

const LOCATIONS = ['ACCI TP. Hồ Chí Minh', 'ACCI Hà Nội', 'ACCI Đà Nẵng'];
const PAYMENTS = ['Chuyển khoản', 'Tiền mặt', 'Momo', 'VNPay'];

const fmtVND = (n) => new Intl.NumberFormat('vi-VN').format(n) + ' VNĐ';

export default function Registration() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    ho_ten: '', ngay_sinh: '', cccd: '', so_dien_thoai: '', email: '',
    ma_lcc: '', hinh_thuc_tt: 'Chuyển khoản',
  });
  const [selectedExam, setSelectedExam] = useState(null);
  const [selectedSlotId, setSelectedSlotId] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [successData, setSuccessData] = useState(null);
  const [error, setError] = useState('');

  const handleExamChange = (e) => {
    const exam = EXAMS.find(x => x.value === e.target.value) || null;
    setSelectedExam(exam);
    setSelectedSlotId(null);
    setForm(f => ({ ...f, ma_lcc: e.target.value }));
  };

  const set = (field) => (e) => setForm(f => ({ ...f, [field]: e.target.value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selectedSlotId) {
      setError('Vui lòng chọn một ngày thi trước khi tiếp tục.');
      return;
    }
    setSubmitting(true);
    setError('');
    try {
      const response = await axios.post('http://localhost:8001/api/dang-ky', { ...form, lich_thi_id: selectedSlotId });
      setSuccessData(response.data); console.log("Đăng ký thành công!", response.data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      setSubmitting(false);
    }
  };

  if (successData) {
    return (
      <div className="reg-page">
        <Navbar />
        <div className="success-overlay">
          <div className="success-card">
            <div className="success-icon">✅</div>
            <h2>Đăng ký thành công!</h2>
            <p>Phiếu đăng ký của bạn đã được ghi nhận. Vui lòng kiểm tra email để xem hướng dẫn thanh toán.</p>
            <p className="success-code">Mã phiếu: <strong>{successData.ma_pdk}</strong></p>
            <button className="btn-primary" onClick={() => navigate('/')}>Quay về trang chủ</button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="reg-page">
      <Navbar />
      <main className="reg-main">
        <div className="reg-card">
          <div className="reg-header">
            <h1>Đăng Ký Dự Thi</h1>
            <p>Vui lòng điền đầy đủ và chính xác thông tin. Các trường có dấu <span className="req">*</span> là bắt buộc.</p>
          </div>

          <form onSubmit={handleSubmit} noValidate>
            {/* Section 1: Thông tin bài thi */}
            <div className="form-section">
              <div className="section-title"><span className="step-num">1</span>Thông tin bài thi</div>
              <div className="field">
                <label>Chọn bài thi <span className="req">*</span></label>
                <select value={form.ma_lcc} onChange={handleExamChange} required>
                  <option value="">-- Vui lòng chọn --</option>
                  {EXAMS.map(e => <option key={e.value} value={e.value}>{e.label}</option>)}
                </select>
              </div>

              <div className="field">
                <label>Lịch thi mong muốn <span className="req">*</span></label>
                <SlotCalendar cert={form.ma_lcc} onSelect={setSelectedSlotId} />
                {!form.ma_lcc && <span className="hint">Chọn bài thi để xem lịch thi có sẵn</span>}
              </div>

              <div className="field">
                <label>Địa điểm thi</label>
                <select>
                  {LOCATIONS.map(l => <option key={l}>{l}</option>)}
                </select>
              </div>
            </div>

            {/* Section 2: Thông tin cá nhân */}
            <div className="form-section">
              <div className="section-title"><span className="step-num">2</span>Thông tin cá nhân</div>
              <div className="field-grid">
                <div className="field">
                  <label>Họ và tên (In hoa không dấu) <span className="req">*</span></label>
                  <input placeholder="NGUYEN VAN A" value={form.ho_ten} onChange={set('ho_ten')} required />
                </div>
                <div className="field">
                  <label>Ngày sinh <span className="req">*</span></label>
                  <input type="date" value={form.ngay_sinh} onChange={set('ngay_sinh')} required />
                </div>
                <div className="field">
                  <label>Số CMND/CCCD <span className="req">*</span></label>
                  <input placeholder="012345678901" maxLength={12} value={form.cccd} onChange={set('cccd')} required />
                </div>
                <div className="field">
                  <label>Số điện thoại <span className="req">*</span></label>
                  <input type="tel" placeholder="0901234567" value={form.so_dien_thoai} onChange={set('so_dien_thoai')} required />
                </div>
                <div className="field full">
                  <label>Email <span className="req">*</span></label>
                  <input type="email" placeholder="example@email.com" value={form.email} onChange={set('email')} required />
                </div>
              </div>
            </div>

            {/* Section 3: Thanh toán */}
            <div className="form-section">
              <div className="section-title"><span className="step-num">3</span>Phương thức thanh toán</div>
              <div className="payment-grid">
                {PAYMENTS.map(p => (
                  <label key={p} className={`payment-option ${form.hinh_thuc_tt === p ? 'selected' : ''}`}>
                    <input type="radio" name="payment" value={p} checked={form.hinh_thuc_tt === p} onChange={set('hinh_thuc_tt')} />
                    {p}
                  </label>
                ))}
              </div>
            </div>

            {/* Price Summary */}
            <div className="price-summary">
              <div className="price-row"><span>Lệ phí thi</span><span>{selectedExam ? fmtVND(selectedExam.price) : '0 VNĐ'}</span></div>
              <div className="price-row total"><span>Tổng cộng</span><strong>{selectedExam ? fmtVND(selectedExam.price) : '0 VNĐ'}</strong></div>
            </div>

            {error && <div className="form-error">⚠️ {error}</div>}

            <button type="submit" className="btn-submit" disabled={submitting}>
              {submitting ? 'Đang xử lý...' : 'Xác nhận đăng ký'}
            </button>
          </form>
        </div>
      </main>
    </div>
  );
}
