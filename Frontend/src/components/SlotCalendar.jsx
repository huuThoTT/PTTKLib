import { useState, useEffect } from 'react';
import { getLichThi } from '../services/api';
import './SlotCalendar.css';

const DAYS = ['CN','T2','T3','T4','T5','T6','T7'];

function formatDate(iso) {
  const d = new Date(iso);
  return { day: DAYS[d.getDay()], dd: String(d.getDate()).padStart(2,'0'), mm: String(d.getMonth()+1).padStart(2,'0') };
}

export default function SlotCalendar({ cert, onSelect }) {
  const [data, setData]         = useState(null);
  const [loading, setLoading]   = useState(false);
  const [error, setError]       = useState('');
  const [selected, setSelected] = useState(null);

  useEffect(() => {
    if (!cert) { setData(null); setSelected(null); return; }
    setLoading(true); setError(''); setSelected(null);
    getLichThi(cert)
      .then(d => setData(d))
      .catch(() => setError('Không thể tải lịch thi. Vui lòng thử lại.'))
      .finally(() => setLoading(false));
  }, [cert]);

  if (!cert) return null;
  if (loading) return <div className="slot-placeholder">⏳ Đang tải lịch thi...</div>;
  if (error)   return <div className="slot-placeholder error">{error}</div>;
  if (!data || data.slots.length === 0)
    return <div className="slot-placeholder">Hiện chưa có lịch thi. Vui lòng liên hệ trung tâm.</div>;

  const handleSelect = (slot) => {
    if (slot.is_full) return;
    setSelected(slot.lich_thi_id);
    onSelect(slot.lich_thi_id);
  };

  return (
    <div>
      <p className="slot-note">{data.note}</p>
      <div className="slot-grid">
        {data.slots.map(slot => {
          const pct = Math.round((slot.so_luong_da_dang_ky / slot.so_luong_toi_da) * 100);
          const d   = formatDate(slot.ngay_thi);
          let statusCls = pct >= 100 ? 'full' : pct >= 70 ? 'almost' : 'avail';
          let statusTxt = pct >= 100 ? 'Đã đầy' : `Còn ${slot.so_luong_con_lai}`;
          return (
            <div
              key={slot.lich_thi_id}
              className={`slot-card ${slot.is_full ? 'full' : ''} ${selected === slot.lich_thi_id ? 'selected' : ''}`}
              onClick={() => handleSelect(slot)}
            >
              {slot.is_full && <span className="full-badge">ĐẦY</span>}
              <div className="slot-day">{d.day}</div>
              <div className="slot-date">{d.dd}/{d.mm}</div>
              <div className="slot-bar-wrap">
                <div className={`slot-bar ${statusCls}`} style={{ width: `${pct}%` }} />
              </div>
              <span className={`slot-status ${statusCls}`}>{statusTxt}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
