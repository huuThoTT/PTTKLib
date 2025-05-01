using PTTK_07.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PTTK_07.Forms
{
    public partial class CapChungChi : Form
    {
        private string maKetQuaThi;
        public CapChungChi()
        {
            InitializeComponent();
            this.Load += GV_CapChungChi_Load;
        }
        private void GV_CapChungChi_Load(object sender, EventArgs e)
        {
            LayDanhSachKetQuaThi();
            LayThiSinh(maKetQuaThi);
            LayKhachHang(maKetQuaThi);
            LayLoaiChungChi(maKetQuaThi);
        }
        private void LayDanhSachKetQuaThi()
        {
            try
            {
                var kqt = new DB().Select(
                "SELECT MaKQT, SoBaoDanh, DiemSo, NgayCoDiem, MaTS, MaLCC, MaPDT FROM KET_QUA_THI");

                DataTable dt = new DataTable();
                dt.Load(kqt);

                gvKetQuaThi.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayKhachHang(string maKetQuaThi)
        {
            try
            {
                if (maKetQuaThi == null)
                {
                    maKetQuaThi = "M";
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_KHACH_HANG_NVNL
                var ts = new DB().SelectFunction("F_MaKQT_to_KHACH_HANG_NVNL", maKetQuaThi);
                //using (var ts = db.SelectFunction("F_MaKQT_to_KHACH_HANG_NVNL", v_maKQT))
                {
                    if (ts != null)
                    {
                        // Tạo DataTable và load dữ liệu từ SqlDataReader
                        DataTable dt = new DataTable();
                        dt.Load(ts);

                        // Gán DataTable làm nguồn dữ liệu cho GridView
                        gvKhachHang.DataSource = dt;
                    }
                    else
                    {
                        MessageBox.Show("Không tìm thấy dữ liệu.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayThiSinh(string maKetQuaThi)
        {
            try
            {
                if (maKetQuaThi == null)
                {
                    maKetQuaThi = "M";
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_THI_SINH_NVNL
                var ts = new DB().SelectFunction("F_MaKQT_to_THI_SINH_NVNL", maKetQuaThi);
                {
                    if (ts != null)
                    {
                        // Tạo DataTable và load dữ liệu từ SqlDataReader
                        DataTable dt = new DataTable();
                        dt.Load(ts);

                        // Gán DataTable làm nguồn dữ liệu cho GridView
                        gvThiSinh.DataSource = dt;
                    }
                    else
                    {
                        MessageBox.Show("Không tìm thấy dữ liệu.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayLoaiChungChi(string maKetQuaThi)
        {
            try
            {
                if (maKetQuaThi == null)
                {
                    maKetQuaThi = "M";
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_LOAI_CHUNG_CHI_NVNL
                var ts = new DB().SelectFunction("F_MaKQT_to_LOAI_CHUNG_CHI_NVNL", maKetQuaThi);
                {
                    if (ts != null)
                    {
                        // Tạo DataTable và load dữ liệu từ SqlDataReader
                        DataTable dt = new DataTable();
                        dt.Load(ts);

                        // Gán DataTable làm nguồn dữ liệu cho GridView
                        gvLoaiChungChi.DataSource = dt;
                    }
                    else
                    {
                        MessageBox.Show("Không tìm thấy dữ liệu.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnTim_Click(object sender, EventArgs e)
        {
            maKetQuaThi = txtMaKQT.Text.Trim();
            if (!string.IsNullOrWhiteSpace(maKetQuaThi))
            {
                LayThiSinh(maKetQuaThi);
                LayKhachHang(maKetQuaThi);
                LayLoaiChungChi(maKetQuaThi);
            }
        }

        private void btnHuyTimMaKQT_Click(object sender, EventArgs e)
        {
            maKetQuaThi = "M";
            LayThiSinh(maKetQuaThi);
            LayKhachHang(maKetQuaThi);
            LayLoaiChungChi(maKetQuaThi);
        }

        private void btnNhapDiemSo_Click(object sender, EventArgs e)
        {
            // Lấy giá trị từ NumericUpDown hoặc TextBox
            float diemSoNum;
            try
            {
                // Giả sử numDiemSo là NumericUpDown
                diemSoNum = Convert.ToSingle(numDiemSo.Value);
            }
            catch
            {
                // Nếu numDiemSo là TextBox, thử parse
                if (!float.TryParse(numDiemSo.Text.Trim(), out diemSoNum))
                {
                    MessageBox.Show("Điểm số không hợp lệ.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }

            // Kiểm tra đầu vào
            if (string.IsNullOrWhiteSpace(maKetQuaThi))
            {
                MessageBox.Show("Vui lòng nhập Mã Kết Quả Thi.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (diemSoNum < 0 || diemSoNum > 100)
            {
                MessageBox.Show("Điểm số không hợp lệ. Vui lòng nhập số từ 0 đến 100.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                // Tạo đối tượng DB và danh sách tham số
                var db = new DB();
                var parameters = new Dictionary<string, object>
        {
            { "@v_makqt", maKetQuaThi },
            { "@v_diemso", diemSoNum }
        };

                // Gọi PROCEDURE
                bool success = db.ExecuteProcedure("P_UPDATE_KET_QUA_THI_NVNL", parameters);

                // Xử lý kết quả
                if (success)
                {
                    MessageBox.Show("Cập nhật điểm số thành công.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    // Làm mới GridView
                    LayDanhSachKetQuaThi();
                }
                else
                {
                    MessageBox.Show("Cập nhật điểm số thất bại.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
