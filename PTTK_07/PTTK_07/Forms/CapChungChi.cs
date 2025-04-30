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
        private void LayKhachHang()
        {
            try
            {
                var kh= new DB().Select(
                "SELECT MaKH, TenKH, LoaiKH, SDT, DiaChi, Email FROM KHACH_HANG");

                DataTable dt = new DataTable();
                dt.Load(kh);

                gvKhachHang.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayThiSinh()
        {
            try
            {
                var ts = new DB().Select("SELECT MaTS, TenTS, NgaySinh, CCCD, MaKH FROM THI_SINH");

                DataTable dt = new DataTable();
                dt.Load(ts);

                gvThiSinh.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void LayLoaiSachChungChi()
        {
            try
            {
                var lcc = new DB().Select("SELECT MaLCC, TenLoaiChungChi, LinhVucChungChi, DiemChuan, ThoiHan FROM LOAI_CHUNG_CHI");

                DataTable dt = new DataTable();
                dt.Load(lcc);

                gvLoaiChungChi.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnTim_Click(object sender, EventArgs e)
        {
            maKetQuaThi = txtMaKQT.Text.Trim();
        }
    }
}
