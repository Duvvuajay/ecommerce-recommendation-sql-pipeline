-- ==============================================================================
-- Module 04: Realistic Sample Data Ingestion (Idempotent Execution)
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- 1. POPULATE USERS (100 Users)
-- ------------------------------------------------------------------------------
INSERT INTO users (user_id, user_name, email, registration_date, city, user_status)
VALUES
(1, 'Arjun Kumar', 'arjun01@example.com', '2026-01-05 10:30:00', 'Hyderabad', 'active'),
(2, 'Priya Sharma', 'priya02@example.com', '2026-01-08 11:15:00', 'Bangalore', 'active'),
(3, 'Rahul Reddy', 'rahul03@example.com', '2026-01-12 09:45:00', 'Warangal', 'active'),
(4, 'Sneha Patel', 'sneha04@example.com', '2026-01-15 14:20:00', 'Mumbai', 'inactive'),
(5, 'Kiran Rao', 'kiran05@example.com', '2026-01-18 16:00:00', 'Chennai', 'active'),
(6, 'Ananya Das', 'ananya06@example.com', '2026-01-20 12:10:00', 'Kolkata', 'active'),
(7, 'Vikram Singh', 'vikram07@example.com', '2026-01-22 08:30:00', 'Delhi', 'inactive'),
(8, 'Meera Nair', 'meera08@example.com', '2026-01-25 13:45:00', 'Kochi', 'active'),
(9, 'Sanjay Verma', 'sanjay09@example.com', '2026-01-28 15:30:00', 'Pune', 'active'),
(10, 'Divya Reddy', 'divya10@example.com', '2026-02-01 10:00:00', 'Vijayawada', 'active'),
(11, 'Akhil Varma', 'akhil11@example.com', '2026-02-02 09:15:00', 'Hyderabad', 'active'),
(12, 'Pooja Reddy', 'pooja12@example.com', '2026-02-03 10:30:00', 'Vijayawada', 'active'),
(13, 'Suresh Kumar', 'suresh13@example.com', '2026-02-04 11:00:00', 'Chennai', 'inactive'),
(14, 'Keerthi Rao', 'keerthi14@example.com', '2026-02-05 12:15:00', 'Bangalore', 'active'),
(15, 'Naveen Kumar', 'naveen15@example.com', '2026-02-06 13:20:00', 'Warangal', 'active'),
(16, 'Lakshmi Devi', 'lakshmi16@example.com', '2026-02-07 14:10:00', 'Hyderabad', 'active'),
(17, 'Rohit Sharma', 'rohit17@example.com', '2026-02-08 15:30:00', 'Mumbai', 'inactive'),
(18, 'Harika Reddy', 'harika18@example.com', '2026-02-09 09:45:00', 'Visakhapatnam', 'active'),
(19, 'Manoj Kumar', 'manoj19@example.com', '2026-02-10 10:20:00', 'Delhi', 'active'),
(20, 'Swathi Nair', 'swathi20@example.com', '2026-02-11 11:35:00', 'Kochi', 'active'),
(21, 'Praveen Rao', 'praveen21@example.com', '2026-02-12 12:40:00', 'Pune', 'active'),
(22, 'Divya Sharma', 'divya22@example.com', '2026-02-13 13:15:00', 'Jaipur', 'inactive'),
(23, 'Sai Krishna', 'saikrishna23@example.com', '2026-02-14 14:25:00', 'Hyderabad', 'active'),
(24, 'Bhavana Patel', 'bhavana24@example.com', '2026-02-15 15:10:00', 'Ahmedabad', 'active'),
(25, 'Tarun Reddy', 'tarun25@example.com', '2026-02-16 09:30:00', 'Warangal', 'active'),
(26, 'Mounika Rao', 'mounika26@example.com', '2026-02-17 10:45:00', 'Vijayawada', 'inactive'),
(27, 'Karthik Iyer', 'karthik27@example.com', '2026-02-18 11:50:00', 'Chennai', 'active'),
(28, 'Sravani Das', 'sravani28@example.com', '2026-02-19 12:30:00', 'Kolkata', 'active'),
(29, 'Abhishek Verma', 'abhishek29@example.com', '2026-02-20 13:40:00', 'Delhi', 'active'),
(30, 'Nithya Menon', 'nithya30@example.com', '2026-02-21 14:20:00', 'Kochi', 'active'),
(31, 'Vamsi Krishna', 'vamsi31@example.com', '2026-02-22 09:10:00', 'Hyderabad', 'active'),
(32, 'Anusha Reddy', 'anusha32@example.com', '2026-02-23 10:25:00', 'Warangal', 'active'),
(33, 'Gowtham Rao', 'gowtham33@example.com', '2026-02-24 11:40:00', 'Bangalore', 'inactive'),
(34, 'Snehal Patil', 'snehal34@example.com', '2026-02-25 12:55:00', 'Pune', 'active'),
(35, 'Chaitanya Kumar', 'chaitanya35@example.com', '2026-02-26 13:30:00', 'Visakhapatnam', 'active'),
(36, 'Deepika Sharma', 'deepika36@example.com', '2026-02-27 14:45:00', 'Jaipur', 'active'),
(37, 'Rakesh Naidu', 'rakesh37@example.com', '2026-02-28 15:20:00', 'Vijayawada', 'inactive'),
(38, 'Sushma Devi', 'sushma38@example.com', '2026-03-01 09:35:00', 'Hyderabad', 'active'),
(39, 'Aditya Rao', 'aditya39@example.com', '2026-03-02 10:50:00', 'Chennai', 'active'),
(40, 'Kavya Nair', 'kavya40@example.com', '2026-03-03 11:15:00', 'Kochi', 'active'),
(41, 'Ravi Teja', 'raviteja41@example.com', '2026-03-04 12:20:00', 'Warangal', 'active'),
(42, 'Meghana Reddy', 'meghana42@example.com', '2026-03-05 13:35:00', 'Hyderabad', 'inactive'),
(43, 'Aravind Kumar', 'aravind43@example.com', '2026-03-06 14:50:00', 'Bangalore', 'active'),
(44, 'Pallavi Shah', 'pallavi44@example.com', '2026-03-07 15:25:00', 'Mumbai', 'active'),
(45, 'Sandeep Yadav', 'sandeep45@example.com', '2026-03-08 09:40:00', 'Delhi', 'active'),
(46, 'Tejaswini Rao', 'tejaswini46@example.com', '2026-03-09 10:55:00', 'Vijayawada', 'active'),
(47, 'Madhav Reddy', 'madhav47@example.com', '2026-03-10 11:10:00', 'Visakhapatnam', 'inactive'),
(48, 'Aishwarya Iyer', 'aishwarya48@example.com', '2026-03-11 12:25:00', 'Chennai', 'active'),
(49, 'Lokesh Kumar', 'lokesh49@example.com', '2026-03-12 13:40:00', 'Hyderabad', 'active'),
(50, 'Shalini Das', 'shalini50@example.com', '2026-03-13 14:55:00', 'Kolkata', 'active'),
(51, 'Pranay Varma', 'pranay51@example.com', '2026-03-14 09:20:00', 'Warangal', 'active'),
(52, 'Nandini Rao', 'nandini52@example.com', '2026-03-15 10:35:00', 'Bangalore', 'inactive'),
(53, 'Harish Kumar', 'harish53@example.com', '2026-03-16 11:50:00', 'Pune', 'active'),
(54, 'Ritika Sharma', 'ritika54@example.com', '2026-03-17 12:15:00', 'Jaipur', 'active'),
(55, 'Sai Charan', 'saicharan55@example.com', '2026-03-18 13:30:00', 'Hyderabad', 'active'),
(56, 'Janani Krishnan', 'janani56@example.com', '2026-03-19 14:45:00', 'Chennai', 'active'),
(57, 'Mahesh Babu', 'mahesh57@example.com', '2026-03-20 15:10:00', 'Vijayawada', 'inactive'),
(58, 'Sindhu Reddy', 'sindhu58@example.com', '2026-03-21 09:25:00', 'Warangal', 'active'),
(59, 'Vivek Patel', 'vivek59@example.com', '2026-03-22 10:40:00', 'Ahmedabad', 'active'),
(60, 'Rohini Nair', 'rohini60@example.com', '2026-03-23 11:55:00', 'Kochi', 'active'),
(61, 'Ajay Prasad', 'ajay61@example.com', '2026-03-24 12:20:00', 'Hyderabad', 'active'),
(62, 'Sowmya Rao', 'sowmya62@example.com', '2026-03-25 13:35:00', 'Bangalore', 'inactive'),
(63, 'Nikhil Sharma', 'nikhil63@example.com', '2026-03-26 14:50:00', 'Delhi', 'active'),
(64, 'Rupa Devi', 'rupa64@example.com', '2026-03-27 15:15:00', 'Visakhapatnam', 'active'),
(65, 'Kiranmayi Reddy', 'kiranmayi65@example.com', '2026-03-28 09:30:00', 'Warangal', 'active'),
(66, 'Dinesh Kumar', 'dinesh66@example.com', '2026-03-29 10:45:00', 'Chennai', 'active'),
(67, 'Swetha Patel', 'swetha67@example.com', '2026-03-30 11:00:00', 'Mumbai', 'inactive'),
(68, 'Varun Teja', 'varun68@example.com', '2026-03-31 12:15:00', 'Hyderabad', 'active'),
(69, 'Amrutha Nair', 'amrutha69@example.com', '2026-04-01 13:30:00', 'Kochi', 'active'),
(70, 'Rajesh Verma', 'rajesh70@example.com', '2026-04-02 14:45:00', 'Pune', 'active'),
(71, 'Sahithi Rao', 'sahithi71@example.com', '2026-04-03 15:10:00', 'Vijayawada', 'active'),
(72, 'Mohan Krishna', 'mohan72@example.com', '2026-04-04 09:25:00', 'Warangal', 'inactive'),
(73, 'Preethi Sharma', 'preethi73@example.com', '2026-04-05 10:40:00', 'Delhi', 'active'),
(74, 'Srinivas Reddy', 'srinivas74@example.com', '2026-04-06 11:55:00', 'Hyderabad', 'active'),
(75, 'Neha Kulkarni', 'neha75@example.com', '2026-04-07 12:20:00', 'Pune', 'active'),
(76, 'Rahul Nair', 'rahul76@example.com', '2026-04-08 13:35:00', 'Kochi', 'inactive'),
(77, 'Lavanya Das', 'lavanya77@example.com', '2026-04-09 14:50:00', 'Kolkata', 'active'),
(78, 'Sathish Kumar', 'sathish78@example.com', '2026-04-10 15:15:00', 'Chennai', 'active'),
(79, 'Krishna Varma', 'krishna79@example.com', '2026-04-11 09:30:00', 'Visakhapatnam', 'active'),
(80, 'Pavani Reddy', 'pavani80@example.com', '2026-04-12 10:45:00', 'Hyderabad', 'active'),
(81, 'Naveena Rao', 'naveena81@example.com', '2026-04-13 11:00:00', 'Warangal', 'inactive'),
(82, 'Akash Patel', 'akash82@example.com', '2026-04-14 12:15:00', 'Ahmedabad', 'active'),
(83, 'Gayathri Iyer', 'gayathri83@example.com', '2026-04-15 13:30:00', 'Chennai', 'active'),
(84, 'Manasa Kumar', 'manasa84@example.com', '2026-04-16 14:45:00', 'Vijayawada', 'active'),
(85, 'Rohit Reddy', 'rohit85@example.com', '2026-04-17 15:10:00', 'Hyderabad', 'inactive'),
(86, 'Bhargavi Rao', 'bhargavi86@example.com', '2026-04-18 09:25:00', 'Bangalore', 'active'),
(87, 'Anil Sharma', 'anil87@example.com', '2026-04-19 10:40:00', 'Jaipur', 'active'),
(88, 'Sravya Nair', 'sravya88@example.com', '2026-04-20 11:55:00', 'Kochi', 'active'),
(89, 'Teja Krishna', 'teja89@example.com', '2026-04-21 12:20:00', 'Warangal', 'active'),
(90, 'Monika Patel', 'monika90@example.com', '2026-04-22 13:35:00', 'Mumbai', 'inactive'),
(91, 'Vishal Kumar', 'vishal91@example.com', '2026-04-23 14:50:00', 'Delhi', 'active'),
(92, 'Srilatha Reddy', 'srilatha92@example.com', '2026-04-24 15:15:00', 'Hyderabad', 'active'),
(93, 'Girish Rao', 'girish93@example.com', '2026-04-25 09:30:00', 'Bangalore', 'active'),
(94, 'Aparna Menon', 'aparna94@example.com', '2026-04-26 10:45:00', 'Kochi', 'active'),
(95, 'Pavan Kumar', 'pavan95@example.com', '2026-04-27 11:00:00', 'Vijayawada', 'inactive'),
(96, 'Sanjana Das', 'sanjana96@example.com', '2026-04-28 12:15:00', 'Kolkata', 'active'),
(97, 'Ramesh Naidu', 'ramesh97@example.com', '2026-04-29 13:30:00', 'Visakhapatnam', 'active'),
(98, 'Keerthana Sharma', 'keerthana98@example.com', '2026-04-30 14:45:00', 'Jaipur', 'active'),
(99, 'Abhinav Reddy', 'abhinav99@example.com', '2026-05-01 15:10:00', 'Warangal', 'active'),
(100, 'Niharika Rao', 'niharika100@example.com', '2026-05-02 09:25:00', 'Hyderabad', 'active')
ON DUPLICATE KEY UPDATE user_name = VALUES(user_name);

-- ------------------------------------------------------------------------------
-- 2. POPULATE PRODUCTS (160 Products across 7 Categories)
-- ------------------------------------------------------------------------------
INSERT INTO products (product_id, product_name, category, price, created_at, product_status)
VALUES
-- ELECTRONICS (30)
(1, 'Samsung Galaxy S24', 'Electronics', 74999.00, '2026-01-05 10:00:00', 'active'),
(2, 'Apple iPhone 15', 'Electronics', 69999.00, '2026-01-06 11:00:00', 'active'),
(3, 'OnePlus 12', 'Electronics', 64999.00, '2026-01-07 12:00:00', 'active'),
(4, 'Redmi Note 13 Pro', 'Electronics', 24999.00, '2026-01-08 13:00:00', 'active'),
(5, 'Samsung Galaxy M35', 'Electronics', 19999.00, '2026-01-09 14:00:00', 'active'),
(6, 'Apple MacBook Air M2', 'Electronics', 89999.00, '2026-01-10 10:00:00', 'active'),
(7, 'HP Pavilion Laptop', 'Electronics', 62999.00, '2026-01-11 11:00:00', 'active'),
(8, 'Dell Inspiron Laptop', 'Electronics', 57999.00, '2026-01-12 12:00:00', 'active'),
(9, 'Lenovo IdeaPad Slim 5', 'Electronics', 54999.00, '2026-01-13 13:00:00', 'active'),
(10, 'ASUS VivoBook 15', 'Electronics', 45999.00, '2026-01-14 14:00:00', 'active'),
(11, 'Sony Wireless Headphones', 'Electronics', 8999.00, '2026-01-15 10:00:00', 'active'),
(12, 'JBL Bluetooth Speaker', 'Electronics', 4999.00, '2026-01-16 11:00:00', 'active'),
(13, 'Boat Rockerz 450', 'Electronics', 1499.00, '2026-01-17 12:00:00', 'active'),
(14, 'Samsung 43 Inch Smart TV', 'Electronics', 32999.00, '2026-01-18 13:00:00', 'active'),
(15, 'LG 55 Inch Smart TV', 'Electronics', 54999.00, '2026-01-19 14:00:00', 'active'),
(16, 'Canon EOS 1500D Camera', 'Electronics', 42999.00, '2026-01-20 10:00:00', 'active'),
(17, 'Nikon DSLR Camera', 'Electronics', 51999.00, '2026-01-21 11:00:00', 'active'),
(18, 'Apple iPad 10th Generation', 'Electronics', 39999.00, '2026-01-22 12:00:00', 'active'),
(19, 'Samsung Galaxy Tab S9', 'Electronics', 52999.00, '2026-01-23 13:00:00', 'active'),
(20, 'Realme Pad 2', 'Electronics', 17999.00, '2026-01-24 14:00:00', 'active'),
(21, 'Logitech Wireless Mouse', 'Electronics', 799.00, '2026-01-25 10:00:00', 'active'),
(22, 'HP Wireless Keyboard', 'Electronics', 1299.00, '2026-01-26 11:00:00', 'active'),
(23, 'Samsung 1TB SSD', 'Electronics', 8999.00, '2026-01-27 12:00:00', 'active'),
(24, 'WD External Hard Drive', 'Electronics', 5499.00, '2026-01-28 13:00:00', 'active'),
(25, 'TP Link WiFi Router', 'Electronics', 2499.00, '2026-01-29 14:00:00', 'active'),
(26, 'Portronics Power Bank', 'Electronics', 1799.00, '2026-01-30 10:00:00', 'active'),
(27, 'Apple AirPods Pro', 'Electronics', 24999.00, '2026-01-31 11:00:00', 'active'),
(28, 'Noise Smart Watch', 'Electronics', 2999.00, '2026-02-01 12:00:00', 'active'),
(29, 'Mi 32 Inch Smart TV', 'Electronics', 16999.00, '2026-02-02 13:00:00', 'inactive'),
(30, 'Boat Airdopes 141', 'Electronics', 1299.00, '2026-02-03 14:00:00', 'inactive'),
-- FASHION (25)
(31, 'Men Cotton Casual Shirt', 'Fashion', 999.00, '2026-02-04 10:00:00', 'active'),
(32, 'Men Slim Fit Jeans', 'Fashion', 1499.00, '2026-02-05 11:00:00', 'active'),
(33, 'Women Floral Kurti', 'Fashion', 899.00, '2026-02-06 12:00:00', 'active'),
(34, 'Women Denim Jeans', 'Fashion', 1299.00, '2026-02-07 13:00:00', 'active'),
(35, 'Men Formal Trousers', 'Fashion', 1199.00, '2026-02-08 14:00:00', 'active'),
(36, 'Women Cotton Saree', 'Fashion', 1999.00, '2026-02-09 10:00:00', 'active'),
(37, 'Men Printed T Shirt', 'Fashion', 599.00, '2026-02-10 11:00:00', 'active'),
(38, 'Women Party Wear Dress', 'Fashion', 2499.00, '2026-02-11 12:00:00', 'active'),
(39, 'Men Leather Jacket', 'Fashion', 3499.00, '2026-02-12 13:00:00', 'active'),
(40, 'Women Winter Sweater', 'Fashion', 1599.00, '2026-02-13 14:00:00', 'active'),
(41, 'Men Track Pants', 'Fashion', 799.00, '2026-02-14 10:00:00', 'active'),
(42, 'Women Leggings', 'Fashion', 499.00, '2026-02-15 11:00:00', 'active'),
(43, 'Men Sports T Shirt', 'Fashion', 699.00, '2026-02-16 12:00:00', 'active'),
(44, 'Women Palazzo Pants', 'Fashion', 899.00, '2026-02-17 13:00:00', 'active'),
(45, 'Men Hooded Sweatshirt', 'Fashion', 1299.00, '2026-02-18 14:00:00', 'active'),
(46, 'Women Long Kurta', 'Fashion', 1199.00, '2026-02-19 10:00:00', 'active'),
(47, 'Men Casual Shorts', 'Fashion', 599.00, '2026-02-20 11:00:00', 'active'),
(48, 'Women Denim Jacket', 'Fashion', 1899.00, '2026-02-21 12:00:00', 'active'),
(49, 'Men Ethnic Kurta', 'Fashion', 1399.00, '2026-02-22 13:00:00', 'active'),
(50, 'Women Anarkali Dress', 'Fashion', 2799.00, '2026-02-23 14:00:00', 'active'),
(51, 'Men Checked Shirt', 'Fashion', 1099.00, '2026-02-24 10:00:00', 'active'),
(52, 'Women Printed Top', 'Fashion', 699.00, '2026-02-25 11:00:00', 'active'),
(53, 'Men Cargo Pants', 'Fashion', 1599.00, '2026-02-26 12:00:00', 'active'),
(54, 'Women Winter Coat', 'Fashion', 2999.00, '2026-02-27 13:00:00', 'inactive'),
(55, 'Men Blazer', 'Fashion', 3999.00, '2026-02-28 14:00:00', 'inactive'),
-- HOME & KITCHEN (20)
(56, 'Prestige Pressure Cooker', 'Home & Kitchen', 2499.00, '2026-03-01 10:00:00', 'active'),
(57, 'Philips Mixer Grinder', 'Home & Kitchen', 3299.00, '2026-03-02 11:00:00', 'active'),
(58, 'Bajaj Electric Kettle', 'Home & Kitchen', 1299.00, '2026-03-03 12:00:00', 'active'),
(59, 'Hawkins Non Stick Pan', 'Home & Kitchen', 999.00, '2026-03-04 13:00:00', 'active'),
(60, 'Milton Water Bottle', 'Home & Kitchen', 499.00, '2026-03-05 14:00:00', 'active'),
(61, 'Cello Dinner Set', 'Home & Kitchen', 1599.00, '2026-03-06 10:00:00', 'active'),
(62, 'Wakefit Memory Foam Pillow', 'Home & Kitchen', 1299.00, '2026-03-07 11:00:00', 'active'),
(63, 'Sleepwell Mattress', 'Home & Kitchen', 8999.00, '2026-03-08 12:00:00', 'active'),
(64, 'Godrej Storage Cabinet', 'Home & Kitchen', 5999.00, '2026-03-09 13:00:00', 'active'),
(65, 'IKEA Study Table', 'Home & Kitchen', 4499.00, '2026-03-10 14:00:00', 'active'),
(66, 'Amazon Basics Office Chair', 'Home & Kitchen', 6999.00, '2026-03-11 10:00:00', 'active'),
(67, 'Philips LED Table Lamp', 'Home & Kitchen', 899.00, '2026-03-12 11:00:00', 'active'),
(68, 'Havells Ceiling Fan', 'Home & Kitchen', 2499.00, '2026-03-13 12:00:00', 'active'),
(69, 'Kent Water Purifier', 'Home & Kitchen', 12999.00, '2026-03-14 13:00:00', 'active'),
(70, 'IFB Front Load Washing Machine', 'Home & Kitchen', 28999.00, '2026-03-15 14:00:00', 'active'),
(71, 'LG Refrigerator', 'Home & Kitchen', 24999.00, '2026-03-16 10:00:00', 'active'),
(72, 'Prestige Induction Cooktop', 'Home & Kitchen', 2199.00, '2026-03-17 11:00:00', 'active'),
(73, 'Pigeon Sandwich Maker', 'Home & Kitchen', 1199.00, '2026-03-18 12:00:00', 'active'),
(74, 'Home Centre Wall Clock', 'Home & Kitchen', 799.00, '2026-03-19 13:00:00', 'inactive'),
(75, 'Borosil Glass Set', 'Home & Kitchen', 699.00, '2026-03-20 14:00:00', 'inactive'),
-- BOOKS (20)
(76, 'Python Programming for Beginners', 'Books', 499.00, '2026-03-21 10:00:00', 'active'),
(77, 'Learning SQL Database Design', 'Books', 599.00, '2026-03-22 11:00:00', 'active'),
(78, 'Machine Learning with Python', 'Books', 899.00, '2026-03-23 12:00:00', 'active'),
(79, 'Deep Learning Fundamentals', 'Books', 999.00, '2026-03-24 13:00:00', 'active'),
(80, 'Data Structures and Algorithms', 'Books', 699.00, '2026-03-25 14:00:00', 'active'),
(81, 'Introduction to Artificial Intelligence', 'Books', 799.00, '2026-03-26 10:00:00', 'active'),
(82, 'Rich Dad Poor Dad', 'Books', 299.00, '2026-03-27 11:00:00', 'active'),
(83, 'Atomic Habits', 'Books', 399.00, '2026-03-28 12:00:00', 'active'),
(84, 'The Psychology of Money', 'Books', 349.00, '2026-03-29 13:00:00', 'active'),
(85, 'Think and Grow Rich', 'Books', 249.00, '2026-03-30 14:00:00', 'active'),
(86, 'Clean Code', 'Books', 799.00, '2026-03-31 10:00:00', 'active'),
(87, 'The Pragmatic Programmer', 'Books', 899.00, '2026-04-01 11:00:00', 'active'),
(88, 'Computer Networks Fundamentals', 'Books', 649.00, '2026-04-02 12:00:00', 'active'),
(89, 'Operating System Concepts', 'Books', 999.00, '2026-04-03 13:00:00', 'active'),
(90, 'Database System Concepts', 'Books', 1099.00, '2026-04-04 14:00:00', 'active'),
(91, 'Introduction to Statistics', 'Books', 549.00, '2026-04-05 10:00:00', 'active'),
(92, 'The Alchemist', 'Books', 299.00, '2026-04-06 11:00:00', 'active'),
(93, 'Wings of Fire', 'Books', 250.00, '2026-04-07 12:00:00', 'active'),
(94, 'Effective Java', 'Books', 899.00, '2026-04-08 13:00:00', 'inactive'),
(95, 'HTML CSS and JavaScript Guide', 'Books', 499.00, '2026-04-09 14:00:00', 'inactive'),
-- SPORTS (15)
(96, 'Yonex Badminton Racket', 'Sports', 1999.00, '2026-04-10 10:00:00', 'active'),
(97, 'Cosco Football', 'Sports', 899.00, '2026-04-11 11:00:00', 'active'),
(98, 'Nivia Basketball', 'Sports', 1199.00, '2026-04-12 12:00:00', 'active'),
(99, 'Strauss Cricket Bat', 'Sports', 2499.00, '2026-04-13 13:00:00', 'active'),
(100, 'SG Cricket Helmet', 'Sports', 1599.00, '2026-04-14 14:00:00', 'active'),
(101, 'Boldfit Yoga Mat', 'Sports', 799.00, '2026-04-15 10:00:00', 'active'),
(102, 'Decathlon Dumbbell Set', 'Sports', 2499.00, '2026-04-16 11:00:00', 'active'),
(103, 'Kobo Resistance Bands', 'Sports', 499.00, '2026-04-17 12:00:00', 'active'),
(104, 'Nivia Running Shoes', 'Sports', 2299.00, '2026-04-18 13:00:00', 'active'),
(105, 'Adidas Sports Bag', 'Sports', 1799.00, '2026-04-19 14:00:00', 'active'),
(106, 'Speedo Swimming Goggles', 'Sports', 999.00, '2026-04-20 10:00:00', 'active'),
(107, 'Vector X Volleyball', 'Sports', 799.00, '2026-04-21 11:00:00', 'active'),
(108, 'Cosco Skipping Rope', 'Sports', 299.00, '2026-04-22 12:00:00', 'active'),
(109, 'Fitness Exercise Cycle', 'Sports', 12999.00, '2026-04-23 13:00:00', 'inactive'),
(110, 'Cricket Practice Stumps', 'Sports', 699.00, '2026-04-24 14:00:00', 'inactive'),
-- BEAUTY & PERSONAL CARE (15)
(111, 'Lakme Sunscreen SPF 50', 'Beauty & Personal Care', 499.00, '2026-04-25 10:00:00', 'active'),
(112, 'Nivea Body Lotion', 'Beauty & Personal Care', 299.00, '2026-04-26 11:00:00', 'active'),
(113, 'Mamaearth Face Wash', 'Beauty & Personal Care', 249.00, '2026-04-27 12:00:00', 'active'),
(114, 'Minimalist Vitamin C Serum', 'Beauty & Personal Care', 699.00, '2026-04-28 13:00:00', 'active'),
(115, 'Maybelline Lipstick', 'Beauty & Personal Care', 399.00, '2026-04-29 14:00:00', 'active'),
(116, 'LOreal Shampoo', 'Beauty & Personal Care', 349.00, '2026-04-30 10:00:00', 'active'),
(117, 'Dove Conditioner', 'Beauty & Personal Care', 279.00, '2026-05-01 11:00:00', 'active'),
(118, 'Himalaya Face Cream', 'Beauty & Personal Care', 199.00, '2026-05-02 12:00:00', 'active'),
(119, 'Philips Hair Dryer', 'Beauty & Personal Care', 1499.00, '2026-05-03 13:00:00', 'active'),
(120, 'Vega Hair Straightener', 'Beauty & Personal Care', 1799.00, '2026-05-04 14:00:00', 'active'),
(121, 'Gillette Shaving Kit', 'Beauty & Personal Care', 599.00, '2026-05-05 10:00:00', 'active'),
(122, 'Cetaphil Gentle Cleanser', 'Beauty & Personal Care', 499.00, '2026-05-06 11:00:00', 'active'),
(123, 'Biotique Face Scrub', 'Beauty & Personal Care', 199.00, '2026-05-07 12:00:00', 'active'),
(124, 'Mamaearth Hair Oil', 'Beauty & Personal Care', 349.00, '2026-05-08 13:00:00', 'inactive'),
(125, 'Lakme Compact Powder', 'Beauty & Personal Care', 299.00, '2026-05-09 14:00:00', 'inactive'),
-- ACCESSORIES (25)
(126, 'Wildcraft Laptop Backpack', 'Accessories', 1999.00, '2026-05-10 10:00:00', 'active'),
(127, 'Fossil Analog Watch', 'Accessories', 6999.00, '2026-05-11 11:00:00', 'active'),
(128, 'Ray Ban Sunglasses', 'Accessories', 4999.00, '2026-05-12 12:00:00', 'active'),
(129, 'Leather Office Wallet', 'Accessories', 999.00, '2026-05-13 13:00:00', 'active'),
(130, 'Casio Digital Watch', 'Accessories', 1499.00, '2026-05-14 14:00:00', 'active'),
(131, 'American Tourister Trolley Bag', 'Accessories', 4999.00, '2026-05-15 10:00:00', 'active'),
(132, 'Skybags College Backpack', 'Accessories', 1299.00, '2026-05-16 11:00:00', 'active'),
(133, 'Fastrack Sunglasses', 'Accessories', 1199.00, '2026-05-17 12:00:00', 'active'),
(134, 'Leather Laptop Sleeve', 'Accessories', 899.00, '2026-05-18 13:00:00', 'active'),
(135, 'Woodland Leather Belt', 'Accessories', 999.00, '2026-05-19 14:00:00', 'active'),
(136, 'Titan Analog Watch', 'Accessories', 3499.00, '2026-05-20 10:00:00', 'active'),
(137, 'Travel Neck Pillow', 'Accessories', 599.00, '2026-05-21 11:00:00', 'active'),
(138, 'Safari Cabin Suitcase', 'Accessories', 2999.00, '2026-05-22 12:00:00', 'active'),
(139, 'Noise Smart Watch Strap', 'Accessories', 499.00, '2026-05-23 13:00:00', 'inactive'),
(140, 'Canvas Messenger Bag', 'Accessories', 1499.00, '2026-05-24 14:00:00', 'inactive'),
(141, 'Premium Leather Laptop Bag', 'Accessories', 2499.00, '2026-05-25 10:00:00', 'active'),
(142, 'Stainless Steel Water Bottle', 'Accessories', 699.00, '2026-05-26 11:00:00', 'active'),
(143, 'Men Classic Leather Wallet', 'Accessories', 899.00, '2026-05-27 12:00:00', 'active'),
(144, 'Women Handbag', 'Accessories', 1999.00, '2026-05-28 13:00:00', 'active'),
(145, 'Bluetooth Tracker Tag', 'Accessories', 1299.00, '2026-05-29 14:00:00', 'active'),
(146, 'Travel Duffel Bag', 'Accessories', 1799.00, '2026-05-30 10:00:00', 'active'),
(147, 'Polarized Sports Sunglasses', 'Accessories', 1499.00, '2026-05-31 11:00:00', 'active'),
(148, 'Adjustable Laptop Stand', 'Accessories', 999.00, '2026-06-01 12:00:00', 'active'),
(149, 'Premium Card Holder', 'Accessories', 599.00, '2026-06-02 13:00:00', 'inactive'),
(150, 'Smart Watch Protective Case', 'Accessories', 399.00, '2026-06-03 14:00:00', 'active')
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name);

-- ------------------------------------------------------------------------------
-- 3. POPULATE PRODUCT PROPERTIES (450 Content-Based Metadata entries)
-- ------------------------------------------------------------------------------
INSERT INTO product_properties (product_id, property_name, property_value)
SELECT
    p.product_id,
    CASE
        WHEN p.category = 'Electronics' THEN ELT(n.n, 'Brand', 'Warranty', 'Connectivity')
        WHEN p.category = 'Fashion' THEN ELT(n.n, 'Brand', 'Size', 'Material')
        WHEN p.category = 'Books' THEN ELT(n.n, 'Author', 'Language', 'Format')
        WHEN p.category = 'Home & Kitchen' THEN ELT(n.n, 'Material', 'Color', 'Capacity')
        WHEN p.category = 'Sports' THEN ELT(n.n, 'Brand', 'Sport Type', 'Material')
        WHEN p.category = 'Beauty & Personal Care' THEN ELT(n.n, 'Brand', 'Skin Type', 'Volume')
        ELSE ELT(n.n, 'Brand', 'Material', 'Color')
    END,
    CASE
        WHEN p.category = 'Electronics' THEN
            ELT(MOD(p.product_id+n.n,5)+1, 'Samsung','Sony','Dell','HP','Lenovo')
        WHEN p.category = 'Fashion' AND n.n = 1 THEN
            ELT(MOD(p.product_id,5)+1, 'Nike','Adidas','Puma','Levis','Allen Solly')
        WHEN p.category = 'Fashion' AND n.n = 2 THEN
            ELT(MOD(p.product_id,5)+1, 'S','M','L','XL','XXL')
        WHEN p.category = 'Fashion' THEN
            ELT(MOD(p.product_id,4)+1, 'Cotton','Polyester','Denim','Cotton Blend')
        WHEN p.category = 'Books' AND n.n = 1 THEN
            ELT(MOD(p.product_id,5)+1, 'R. K. Narayan','Chetan Bhagat','A. P. J. Abdul Kalam','George Orwell','Paulo Coelho')
        WHEN p.category = 'Books' AND n.n = 2 THEN 'English'
        WHEN p.category = 'Books' THEN 'Paperback'
        WHEN p.category = 'Home & Kitchen' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Stainless Steel','Plastic','Glass','Ceramic')
        WHEN p.category = 'Home & Kitchen' AND n.n = 2 THEN
            ELT(MOD(p.product_id,4)+1, 'Black','White','Silver','Blue')
        WHEN p.category = 'Home & Kitchen' THEN '1 Litre'
        WHEN p.category = 'Sports' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Nike','Adidas','Puma','Decathlon')
        WHEN p.category = 'Sports' AND n.n = 2 THEN 'Fitness'
        WHEN p.category = 'Sports' THEN 'Rubber'
        WHEN p.category = 'Beauty & Personal Care' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Nivea','Dove','Lakme','Mamaearth')
        WHEN p.category = 'Beauty & Personal Care' AND n.n = 2 THEN 'All Skin Types'
        WHEN p.category = 'Beauty & Personal Care' THEN '100 ml'
        ELSE
            ELT(MOD(p.product_id,4)+1, 'Boat','Noise','Portronics','Amazon Basics')
    END
FROM products p
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
WHERE NOT EXISTS (SELECT 1 FROM product_properties pp WHERE pp.product_id = p.product_id);

-- ------------------------------------------------------------------------------
-- 4. POPULATE PRODUCT AVAILABILITY (SCD Type 2 Historical Records)
-- ------------------------------------------------------------------------------
INSERT INTO product_availability (product_id, stock_quantity, availability_status, effective_from, effective_to)
SELECT
    p.product_id,
    CASE WHEN s.snapshot = 1 THEN 10 + MOD(p.product_id * 7, 80) ELSE MOD(p.product_id * 13, 60) END,
    CASE WHEN MOD(p.product_id * 13, 60) = 0 AND s.snapshot = 2 THEN 'out_of_stock' ELSE 'available' END,
    CASE WHEN s.snapshot = 1 THEN DATE_SUB(NOW(), INTERVAL 30 DAY) ELSE DATE_SUB(NOW(), INTERVAL 15 DAY) END,
    CASE WHEN s.snapshot = 1 THEN DATE_SUB(NOW(), INTERVAL 15 DAY) ELSE NULL END
FROM products p
CROSS JOIN (SELECT 1 AS snapshot UNION ALL SELECT 2) s
WHERE NOT EXISTS (SELECT 1 FROM product_availability pa WHERE pa.product_id = p.product_id);

-- ------------------------------------------------------------------------------
-- 5. POPULATE USER EVENTS (1000 Telemetry Actions with Ingestion Duplicates)
-- ------------------------------------------------------------------------------
INSERT INTO user_events (source_event_id, user_id, product_id, event_type, event_timestamp, ingestion_timestamp)
SELECT
    CONCAT('SRC-', x.n + 1),
    1 + MOD(x.n, 100),
    1 + MOD(x.n * 7, 150),
    CASE
        WHEN MOD(x.n, 100) < 45 THEN 'impression'
        WHEN MOD(x.n, 100) < 75 THEN 'view'
        WHEN MOD(x.n, 100) < 90 THEN 'click'
        WHEN MOD(x.n, 100) < 97 THEN 'add_to_cart'
        ELSE 'wishlist'
    END,
    DATE_SUB(NOW(), INTERVAL MOD(x.n, 30) DAY),
    DATE_ADD(DATE_SUB(NOW(), INTERVAL MOD(x.n, 30) DAY), INTERVAL 5 MINUTE)
FROM (
    SELECT a.d * 100 + b.d * 10 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
) x
WHERE NOT EXISTS (SELECT 1 FROM user_events WHERE event_id = 1);

-- Deliberately insert repeated ingestion records to test deduplication pipeline
INSERT INTO user_events (source_event_id, user_id, product_id, event_type, event_timestamp, ingestion_timestamp)
SELECT
    source_event_id,
    user_id,
    product_id,
    event_type,
    event_timestamp,
    DATE_ADD(ingestion_timestamp, INTERVAL 10 MINUTE)
FROM user_events
WHERE event_id IN (10, 20, 30, 40, 50)
  AND (SELECT COUNT(*) FROM user_events WHERE source_event_id = 'SRC-11') <= 1;

-- ------------------------------------------------------------------------------
-- 6. POPULATE ORDERS & ORDER ITEMS (200 Orders)
-- ------------------------------------------------------------------------------
INSERT INTO orders (user_id, order_date, order_status, total_amount)
SELECT
    1 + MOD(x.n * 3, 100),
    DATE_SUB(NOW(), INTERVAL (MOD(x.n, 45) + 1) DAY),
    CASE
        WHEN MOD(x.n, 10) <= 6 THEN 'delivered'
        WHEN MOD(x.n, 10) = 7 THEN 'shipped'
        WHEN MOD(x.n, 10) = 8 THEN 'confirmed'
        ELSE 'pending'
    END,
    0.00
FROM (
    SELECT a.d * 20 + b.d * 2 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1) c
) x
WHERE x.n < 200
  AND NOT EXISTS (SELECT 1 FROM orders WHERE order_id = 1);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    CASE WHEN x.n < 200 THEN x.n + 1 ELSE x.n - 199 END,
    p.product_id,
    1 + MOD(x.n, 3),
    p.price
FROM (
    SELECT a.d * 100 + b.d * 10 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2) c
) x
JOIN products p ON p.product_id = 1 + MOD(x.n * 7, 150)
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_item_id = 1);

-- Synchronize total order amount
UPDATE orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS calculated_total
    FROM order_items
    GROUP BY order_id
) oi ON o.order_id = oi.order_id
SET o.total_amount = oi.calculated_total;

-- ------------------------------------------------------------------------------
-- 7. POPULATE RETURNS (30 Return Records)
-- ------------------------------------------------------------------------------
INSERT INTO returns (order_item_id, return_date, return_quantity, return_reason)
SELECT
    oi.order_item_id,
    DATE_ADD(o.order_date, INTERVAL 2 DAY),
    1,
    ELT(MOD(oi.order_item_id, 5) + 1, 'damaged', 'wrong_item', 'size_or_fit', 'changed_mind', 'other')
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND oi.quantity >= 1
  AND NOT EXISTS (SELECT 1 FROM returns WHERE return_id = 1)
ORDER BY oi.order_item_id
LIMIT 30;

-- Verification of loaded data
SELECT 'users' AS table_name, COUNT(*) AS total_rows FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'product_properties', COUNT(*) FROM product_properties
UNION ALL SELECT 'product_availability', COUNT(*) FROM product_availability
UNION ALL SELECT 'user_events', COUNT(*) FROM user_events
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'returns', COUNT(*) FROM returns;
