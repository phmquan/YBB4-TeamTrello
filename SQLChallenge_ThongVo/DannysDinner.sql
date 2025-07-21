-- Tạo bảng members
CREATE TABLE members (
  customer_id VARCHAR(1) PRIMARY KEY,
  join_date DATE
);

-- Tạo bảng menu
CREATE TABLE menu (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(5),
  price INT
);

-- Tạo bảng sales (chưa có ràng buộc)
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

-- Insert dữ liệu vào members (đã thêm 'C')
INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('C', NULL);  

-- Insert dữ liệu vào menu
INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Insert dữ liệu vào sales
INSERT INTO sales (customer_id, order_date, product_id) VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Thêm khóa ngoại từ sales → members
ALTER TABLE sales
ADD CONSTRAINT fk_sales_customer
FOREIGN KEY (customer_id)
REFERENCES members(customer_id);

-- Thêm khóa ngoại từ sales → menu
ALTER TABLE sales
ADD CONSTRAINT fk_sales_product
FOREIGN KEY (product_id)
REFERENCES menu(product_id);


