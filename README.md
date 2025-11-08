# Big Data Analytics - Kimia Farma x Rakamin Academy
# Analisis Kinerja Bisnis Kimia Farma (2020-2023)

Repositori ini berisi hasil proyek tugas akhir untuk **Project-Based Internship: Big Data Analytics** yang diselenggarakan oleh **Rakamin Academy** dan **Kimia Farma**. Tujuan dari proyek ini adalah untuk mengevaluasi kinerja bisnis Kimia Farma selama periode 2020 hingga 2023. Analisis ini mencakup impor data, transformasi data menggunakan SQL di BigQuery, dan visualisasi data dalam dashboard interaktif di Google Looker Studio.

---

## 📖 Tentang Program

> Program Project Based Internship kolaborasi Rakamin Academy dan Kimia Farma Big Data Analytics merupakan program pengembangan diri dan akselerasi karier yang diperuntukkan bagi kalian yang tertarik untuk mendalami posisi Big Data Analytics di perusahaan Kimia Farma. Program ini memberikan akses pembelajaran dasar berupa Article Review (materi bacaan) dan Company Coaching Video (video learning) untuk memperkenalkan kalian dengan kompetensi dan keahlian yang harus dimiliki oleh Big Data Analytics di perusahaan. Selain materi, akan ada pengujian atas hasil pembelajaran kalian berupa soal-soal Task di setiap minggunya dan diakhiri dengan pembuatan tugas akhir yang akan menjadi portofolio kalian pada program ini.

## 🎯 Tantangan Proyek (Project Challenge)

Tugas utama dalam proyek ini adalah:

1.  **Importing Dataset to BigQuery**: Mengimpor 4 dataset CSV yang disediakan (`kf_final_transaction`, `kf_product`, `kf_kantor_cabang`, `kf_inventory`) ke dalam Google BigQuery.
2.  **Membuat Tabel Analisa**: Melakukan transformasi data menggunakan SQL untuk membuat satu tabel analisa teragregasi. Tabel ini harus berisi metrik bisnis utama seperti `nett_sales` dan `nett_profit`, serta `persentase_gross_laba` yang dihitung berdasarkan aturan bisnis.
3.  **Create Dashboard Performance Analytics**: Membangun dashboard kinerja interaktif di Google Looker Studio berdasarkan tabel analisa yang telah dibuat.

## 🛠️ Tools yang Digunakan

Proyek ini memanfaatkan alat-alat berikut:

* **Google BigQuery**: Untuk penyimpanan data (data warehouse) dan transformasi data (ETL) menggunakan SQL.
* **Google Looker Studio**: Untuk visualisasi data dan pembuatan dashboard interaktif.
* **GitHub**: Untuk menyimpan *query* SQL dan dokumentasi proyek.

## 🔄 Alur Kerja Proyek (Workflow)

Alur kerja analisis data yang diterapkan adalah sebagai berikut:

1.  **Impor Data**: Membuat proyek baru di Google Cloud (`Rakamin_KF_Analytics`) dan dataset (`kimia_farma`). Kemudian, mengimpor 4 file CSV ke dalam dataset tersebut.
2.  **Transformasi Data (SQL)**: Membuat tabel baru (`tabel_analisa`) dengan menggabungkan data dari tabel transaksi, produk, dan kantor cabang. *Common Table Expressions* (CTEs) digunakan untuk memecah *query*:
    * `joined_tables`: Menggabungkan 3 tabel utama.
    * `calculated_laba`: Menerapkan logika `CASE WHEN` untuk menghitung `persentase_gross_laba` berdasarkan aturan *tiering* harga produk.
    * `SELECT` Terakhir: Menghitung `nett_sales` (harga setelah diskon) dan `nett_profit` (nett_sales dikali persentase laba).
3.  **Visualisasi Data**: Menghubungkan `tabel_analisa` dari BigQuery ke Google Looker Studio untuk membangun dashboard kinerja.

# SQL Query: Pembuatan tabel_analisa

Query SQL berikut digunakan di Google BigQuery untuk membuat tabel analisa utama (`tabel_analisa`) yang menggabungkan data dari empat tabel sumber dan menghitung metrik bisnis utama.

Query ini menggunakan *Common Table Expressions* (CTEs) untuk mempermudah pembacaan, sesuai dengan alur kerja yang dipresentasikan.

```sql
CREATE OR REPLACE TABLE kimia_farma.tabel_analisa AS (
  WITH
    -- CTE 1: Menggabungkan tabel transaksi, produk, dan cabang
    joined_tables AS (
      SELECT
        t.transaction_id,
        t.date,
        t.branch_id,
        c.branch_name,
        c.kota,
        c.provinsi,
        c.rating AS rating_cabang,
        t.customer_name,
        t.product_id,
        p.product_name,
        t.price AS actual_price,
        t.discount_percentage,
        t.rating AS rating_transaksi
      FROM
        `kimia_farma.kf_final_transaction` AS t
        LEFT JOIN `kimia_farma.kf_product` AS p ON t.product_id = p.product_id
        LEFT JOIN `kimia_farma.kf_kantor_cabang` AS c ON t.branch_id = c.branch_id
    ),
    
    -- CTE 2: Menghitung persentase gross laba berdasarkan aturan harga
    -- Aturan bisnis diambil dari dokumen challenge 
    calculated_laba AS (
      SELECT
        *,
        CASE
          WHEN actual_price <= 50000 THEN 0.10
          WHEN actual_price > 50000 AND actual_price <= 100000 THEN 0.15
          WHEN actual_price > 100000 AND actual_price <= 300000 THEN 0.20
          WHEN actual_price > 300000 AND actual_price <= 500000 THEN 0.25
          WHEN actual_price > 500000 THEN 0.30
        END AS persentase_gross_laba
      FROM
        joined_tables
    )
    
    -- Final SELECT: Menghitung nett_sales dan nett_profit
    SELECT
      transaction_id,
      date,
      branch_id,
      branch_name,
      kota,
      provinsi,
      rating_cabang,
      customer_name,
      product_id,
      product_name,
      actual_price,
      discount_percentage,
      persentase_gross_laba,
      
      -- Menghitung nett_sales: harga setelah diskon
      (actual_price * (1 - discount_percentage)) AS nett_sales,
      
      -- Menghitung nett_profit: nett_sales * persentase laba
      ((actual_price * (1 - discount_percentage)) * persentase_gross_laba) AS nett_profit,
      
      rating_transaksi
    FROM
      calculated_laba
);
```

## 📊 Hasil Dashboard & Temuan Utama

Dashboard interaktif menyajikan analisis kinerja dari tahun 2020-2023.

**➡️ Link Dashboard:** [**https://lookerstudio.google.com/reporting/752f526a-7784-48b4-8ce7-76a943be7987**](https://lookerstudio.google.com/reporting/752f526a-7784-48b4-8ce7-76a943be7987)

![Image](https://github.com/user-attachments/assets/a5241f61-bf31-4f96-ad98-f85f5559ce1f)

### Kesimpulan Utama

1.  **Kinerja Stabil**: Kinerja bisnis Kimia Farma sangat stabil dan kuat selama 2020-2023, dengan total profit mencapai >Rp91 Miliar dan rata-rata rating kepuasan pelanggan 4.0.
2.  **Dominasi Jawa Barat**: Jawa Barat adalah pasar terbesar dan paling krusial, mendominasi secara absolut baik dalam total transaksi (198.7K) maupun total penjualan (Rp94.9 Miliar), menunjukkan kesenjangan kinerja yang sangat besar dengan provinsi lain.
3.  **Profitabilitas Merata**: Profitabilitas tersebar sangat merata di antara tiga kategori cabang (Apotek, Klinik & Apotek, Klinik-Apotek-Lab), di mana masing-masing berkontribusi sekitar 33%.
4.  **Mismatch Rating**: Terdapat indikasi *mismatch* antara persepsi cabang (Rating Cabang) dan pengalaman transaksi (Rating Transaksi) di beberapa wilayah seperti Jambi dan Papua Barat.
