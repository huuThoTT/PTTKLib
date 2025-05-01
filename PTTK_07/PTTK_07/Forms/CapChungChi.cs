using PTTK_07.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;

namespace PTTK_07.Forms
{
    public partial class CapChungChi : Form
    {
        private string maKetQuaThi;
        private string maThiSinh_ChungChi;
        public CapChungChi()
        {
            InitializeComponent();
            this.Load += GV_CapChungChi_Load_NVNL;
            this.Load += GV_CapChungChi_Load_NVTN;
        }
        private void GV_CapChungChi_Load_NVNL(object sender, EventArgs e)
        {
            LayDanhSachKetQuaThi_NVNL(maKetQuaThi);
            LayThiSinh_NVNL(maKetQuaThi);
            LayKhachHang_NVNL(maKetQuaThi);
            LayLoaiChungChi_NVNL(maKetQuaThi);
        }
        private void GV_CapChungChi_Load_NVTN(object sender, EventArgs e)
        {
            LayDanhSachChungChi_NVTN(maKetQuaThi);
        }
        private void LayDanhSachKetQuaThi_NVNL(string maKetQuaThi)
        {
            //try
            //{
            //    var kqt = new DB().Select(
            //    "SELECT MaKQT, SoBaoDanh, DiemSo, NgayCoDiem, MaTS, MaLCC, MaPDT FROM KET_QUA_THI");

            //    DataTable dt = new DataTable();
            //    dt.Load(kqt);

            //    gvKetQuaThi.DataSource = dt;
            //}
            //catch (Exception ex)
            //{
            //    MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            //}
            try
            {
                if (maKetQuaThi == null || maKetQuaThi == "M")
                {
                    var kqt_all = new DB().Select(
                    "SELECT MaKQT, SoBaoDanh, DiemSo, NgayCoDiem, MaTS, MaLCC, MaPDT FROM KET_QUA_THI");

                    DataTable dt = new DataTable();
                    dt.Load(kqt_all);

                    gvKetQuaThi.DataSource = dt;
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_KET_QUA_THI_NVNL
                else if (maKetQuaThi != null)
                {
                    var kqt = new DB().SelectFunction("F_MaKQT_to_KET_QUA_THI_NVNL", maKetQuaThi);
                    {
                        if (kqt != null)
                        {
                            // Tạo DataTable và load dữ liệu từ SqlDataReader
                            DataTable dt = new DataTable();
                            dt.Load(kqt);

                            // Gán DataTable làm nguồn dữ liệu cho GridView
                            gvKetQuaThi.DataSource = dt;
                            if (gvKetQuaThi.Columns.Count > 0)
                            {
                            }
                        }
                        else
                        {
                            MessageBox.Show("Không tìm thấy dữ liệu.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayKhachHang_NVNL(string maKetQuaThi)
        {
            try
            {
                if (maKetQuaThi == null)
                {
                    maKetQuaThi = "M";
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_KHACH_HANG_NVNL
                var kh = new DB().SelectFunction("F_MaKQT_to_KHACH_HANG_NVNL", maKetQuaThi);
                //using (var kh = db.SelectFunction("F_MaKQT_to_KHACH_HANG_NVNL", v_maKQT))
                {
                    if (kh != null)
                    {
                        // Tạo DataTable và load dữ liệu từ SqlDataReader
                        DataTable dt = new DataTable();
                        dt.Load(kh);

                        // Gán DataTable làm nguồn dữ liệu cho GridView
                        gvKhachHang.DataSource = dt;
                        if (gvKhachHang.Columns.Count > 0)
                        {
                            // Đổi độ rộng cột
                            if (gvKhachHang.Columns["Mã khách hàng"] != null)
                            {
                                gvKhachHang.Columns["Mã khách hàng"].Width = 110;
                            }
                            if (gvKhachHang.Columns["Tên khách hàng"] != null)
                            {
                                gvKhachHang.Columns["Tên khách hàng"].Width = 120;
                            }
                            if (gvKhachHang.Columns["Loại khách hàng"] != null)
                            {
                                gvKhachHang.Columns["Loại khách hàng"].Width = 120;
                            }
                        }
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
        private void LayThiSinh_NVNL(string maKetQuaThi)
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
                        if (gvThiSinh.Columns.Count > 0)
                        {
                            // Đổi độ rộng cột
                            if (gvThiSinh.Columns["Căn cước công dân"] != null)
                            {
                                gvThiSinh.Columns["Căn cước công dân"].Width = 130;
                            }
                            if (gvThiSinh.Columns["Mã khách hàng"] != null)
                            {
                                gvThiSinh.Columns["Mã khách hàng"].Width = 110;
                            }
                        }
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
        private void LayLoaiChungChi_NVNL(string maKetQuaThi)
        {
            try
            {
                if (maKetQuaThi == null)
                {
                    maKetQuaThi = "M";
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaKQT_to_LOAI_CHUNG_CHI_NVNL
                var lcc = new DB().SelectFunction("F_MaKQT_to_LOAI_CHUNG_CHI_NVNL", maKetQuaThi);
                {
                    if (lcc != null)
                    {
                        // Tạo DataTable và load dữ liệu từ SqlDataReader
                        DataTable dt = new DataTable();
                        dt.Load(lcc);

                        // Gán DataTable làm nguồn dữ liệu cho GridView
                        gvLoaiChungChi.DataSource = dt;
                        if (gvLoaiChungChi.Columns.Count > 0)
                        {
                            // Đổi độ rộng cột
                            if (gvLoaiChungChi.Columns["Mã loại chứng chỉ"] != null)
                            {
                                gvLoaiChungChi.Columns["Mã loại chứng chỉ"].Width = 120;
                            }
                            if (gvLoaiChungChi.Columns["Tên loại chứng chỉ"] != null)
                            {
                                gvLoaiChungChi.Columns["Tên loại chứng chỉ"].Width = 120;
                            }
                            if (gvLoaiChungChi.Columns["Lĩnh vực chứng chỉ"] != null)
                            {
                                gvLoaiChungChi.Columns["Lĩnh vực chứng chỉ"].Width = 130;
                            }
                            if (gvLoaiChungChi.Columns["Thời hạn (tháng)"] != null)
                            {
                                gvLoaiChungChi.Columns["Thời hạn (tháng)"].Width = 110;
                            }
                        }
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
                LayDanhSachKetQuaThi_NVNL(maKetQuaThi);
                LayThiSinh_NVNL(maKetQuaThi);
                LayKhachHang_NVNL(maKetQuaThi);
                LayLoaiChungChi_NVNL(maKetQuaThi);
            }
        }

        private void btnHuyTimMaKQT_Click(object sender, EventArgs e)
        {
            maKetQuaThi = "M";
            LayDanhSachKetQuaThi_NVNL(maKetQuaThi);
            LayThiSinh_NVNL(maKetQuaThi);
            LayKhachHang_NVNL(maKetQuaThi);
            LayLoaiChungChi_NVNL(maKetQuaThi);
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
                    LayDanhSachKetQuaThi_NVNL(null);
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
        private void LayDanhSachChungChi_NVTN(string maThiSinh_ChungChi)
        {
            try
            {
                if (maThiSinh_ChungChi == null)
                {
                    maThiSinh_ChungChi = "M";
                    //var cc_all = new DB().Select(
                    //"SELECT * FROM CHUNG_CHI");

                    //DataTable dt = new DataTable();
                    //dt.Load(cc_all);

                    //gvChungChi.DataSource = dt;
                    // Đổi độ rộng cột
                    //if (gvChungChi.Columns["Mã loại chứng chỉ"] != null)
                    //{
                    //    gvChungChi.Columns["Mã loại chứng chỉ"].Width = 120;
                    //}
                }
                // Gọi phương thức SelectFunction từ DatabaseHelper để truy xuất function F_MaTS_to_CHUNG_CHI_NVNL
                //else if (maThiSinh_ChungChi != null)
                var cc = new DB().SelectFunction("F_MaTS_to_CHUNG_CHI_NVNL", maThiSinh_ChungChi);
                {
                    //var cc = new DB().SelectFunction("F_MaTS_to_CHUNG_CHI_NVNL", maThiSinh_ChungChi);
                    {
                        if (cc != null)
                        {
                            // Tạo DataTable và load dữ liệu từ SqlDataReader
                            DataTable dt = new DataTable();
                            dt.Load(cc);

                            // Gán DataTable làm nguồn dữ liệu cho GridView
                            gvChungChi.DataSource = dt;
                            if (gvChungChi.Columns.Count > 0)
                            {
                                // Đổi độ rộng cột
                                if (gvChungChi.Columns["Mã loại chứng chỉ"] != null)
                                {
                                    gvChungChi.Columns["Mã loại chứng chỉ"].Width = 120;
                                }
                            }
                        }
                        else
                        {
                            MessageBox.Show("Không tìm thấy dữ liệu.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void btnTimMaTS_ChungChi_Click(object sender, EventArgs e)
        {
            maThiSinh_ChungChi = txtMaTS_ChungChi.Text.Trim();
            if (!string.IsNullOrWhiteSpace(maThiSinh_ChungChi))
            {
                LayDanhSachChungChi_NVTN(maThiSinh_ChungChi);
            }
        }

        private void btnHuyMaTS_ChungChi_Click(object sender, EventArgs e)
        {
            maThiSinh_ChungChi = "M";
            LayDanhSachChungChi_NVTN(maThiSinh_ChungChi);
        }
    }
}
