CREATE TABLE kimia_farma.tabel_analisa AS (
  WITH
    -- Menggabungkan tabel transaksi, produk, dan cabang
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

    -- Menghitung persentase gross laba berdasarkan aturan harga
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

  -- Menghitung nett_sales dan nett_profit
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
    -- Mengitung nett_sales: harga setelah diskon 
    (actual_price * (1 - discount_percentage)) AS nett_sales,
    -- Mengitung nett_profit: nett_sales dikali persentase laba 
    ((actual_price * (1 - discount_percentage)) * persentase_gross_laba) AS nett_profit,
    rating_transaksi
  FROM
    calculated_laba
);