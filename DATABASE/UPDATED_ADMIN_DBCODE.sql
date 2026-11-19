-- =====================================================
-- ecodb_full_setup.sql  -  DROPS and recreates the whole database
-- Schema + categories + admins + 30 products + images, in one run.
-- =====================================================
drop database if exists ecodb;
CREATE DATABASE ecodb;
use ecodb;

drop table if exists sys_user;
CREATE TABLE sys_user(
user_id			BIGINT		 							NOT NULL auto_increment,
first_name		VARCHAR(50)  							NOT NULL,
last_name		VARCHAR(50)  							NOT NULL,
email 			VARCHAR(100) 							NOT NULL unique,
password  	 	VARCHAR(100) 							NOT NULL,
phone 			VARCHAR(20) 							NOT NULL unique,
register_date	timestamp not null default now(),
role 			ENUM('ROLE_Customer','ROLE_ADMIN')	NOT NULL,
image           VARCHAR(255),

CONSTRAINT user_pk PRIMARY KEY (user_id)

);

drop table if exists customer;
CREATE TABLE customer(
customer_id		BIGINT				NOT NULL,
points			double DEFAULT 0,
CONSTRAINT customer_PK PRIMARY KEY (customer_id),
CONSTRAINT customer_FK FOREIGN KEY (customer_id) REFERENCES sys_user (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists sys_admin;
CREATE TABLE sys_admin(
admin_id		BIGINT		NOT NULL,
is_active		boolean		default true,
CONSTRAINT admin_PK PRIMARY KEY (admin_id),
CONSTRAINT admin_FK FOREIGN KEY (admin_id) REFERENCES sys_user (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists credit_card;
CREATE TABLE credit_card(
card_id			BIGINT				NOT NULL auto_increment,
user_id			BIGINT				NOT NULL,
provider		VARCHAR(50)			NOT NULL,
account_number	VARCHAR(50)			NOT NULL,
expire_date		TIMESTAMP			NOT NULL,
is_default		BOOLEAN				NOT NULL,
CONSTRAINT card_PK PRIMARY KEY (card_id),
CONSTRAINT card_FK FOREIGN KEY (user_id) REFERENCES sys_user (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists address;
CREATE TABLE address(
address_id		BIGINT 				NOT NULL auto_increment,
customer_id		BIGINT				NOT NULL,
street			VARCHAR(100) 		NOT NULL,
city			VARCHAR(50) 		NOT NULL,
state			VARCHAR(50) 		NOT NULL,
zipcode         VARCHAR(20),
address_type	ENUM('WORK','HOME') NOT NULL,
is_default      BOOLEAN             DEFAULT false,
CONSTRAINT address_PK PRIMARY KEY (address_id),
CONSTRAINT address_FK FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists category;
CREATE TABLE category(
category_id		BIGINT		NOT NULL auto_increment,
category_name	VARCHAR(50)	NOT NULL,
CONSTRAINT category_pk PRIMARY KEY (category_id)
);

drop table if exists promotion;
CREATE TABLE promotion(
promotion_id		BIGINT		NOT NULL auto_increment,
promo_name			VARCHAR(50)	NOT NULL,
promo_description	VARCHAR(255),
discount			DECIMAL(5,2)	NOT NULL,
start_date			TIMESTAMP	NOT NULL,
end_date			TIMESTAMP	NOT NULL,
CONSTRAINT promotion_PK PRIMARY KEY (promotion_id)
);

drop table if exists promotion_category;
CREATE TABLE promotion_category(
category_id		BIGINT		NOT NULL,
promotion_id	BIGINT		NOT NULL,
CONSTRAINT promotion_category_PK PRIMARY KEY (category_id,promotion_id),
CONSTRAINT promotion_category_FK1 FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT promotion_category_FK2 FOREIGN KEY (promotion_id) REFERENCES promotion (promotion_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists product;
CREATE TABLE product(
product_id		BIGINT 		NOT NULL auto_increment,
admin_id		BIGINT		NOT NULL,
category_id		BIGINT		NOT NULL,
product_name    VARCHAR(100) NOT NULL,
price			double		NOT NULL,
is_available	boolean		default true,
creation_date	timestamp	default now(),
pro_description VARCHAR(1000),
details         TEXT,
quantity_in_stock INT       DEFAULT 0,
size            VARCHAR(50),
color           VARCHAR(50),
CONSTRAINT product_pk PRIMARY KEY (product_id),
CONSTRAINT product_fk1 FOREIGN KEY (admin_id) REFERENCES sys_admin (admin_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT product_fk2 FOREIGN KEY (category_id) REFERENCES category (category_id) ON UPDATE CASCADE
);

-- New table for product images
drop table if exists product_image;
CREATE TABLE product_image(
image_id		BIGINT		NOT NULL auto_increment,
product_id		BIGINT		NOT NULL,
image_url		VARCHAR(255)	NOT NULL,
is_main			BOOLEAN		DEFAULT false,
CONSTRAINT image_pk PRIMARY KEY (image_id),
CONSTRAINT image_fk FOREIGN KEY (product_id) REFERENCES product (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists shopping_cart;
CREATE TABLE shopping_cart(
cart_id			BIGINT		NOT NULL auto_increment,
customer_id		BIGINT		NOT NULL UNIQUE,
cart_status		ENUM('Active','Completed') DEFAULT 'Active',
created_at      TIMESTAMP   DEFAULT NOW(),
updated_at      TIMESTAMP   DEFAULT NOW() ON UPDATE NOW(),
CONSTRAINT cart_PK PRIMARY KEY (cart_id),
CONSTRAINT cart_FK FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists cart_item;
CREATE TABLE cart_item(
cart_id			BIGINT		NOT NULL,
product_id		BIGINT		NOT NULL,
quantity		INT			NOT NULL DEFAULT 1 CHECK (quantity > 0),
CONSTRAINT cart_item_PK	PRIMARY KEY (cart_id, product_id),
CONSTRAINT cart_item_FK1 FOREIGN KEY (cart_id) REFERENCES shopping_cart (cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT cart_item_FK2 FOREIGN KEY (product_id) REFERENCES product (product_id) ON UPDATE CASCADE ON DELETE CASCADE
);

drop table if exists sys_order;
CREATE TABLE sys_order(
order_id		BIGINT		NOT NULL auto_increment,
customer_id		BIGINT		NOT NULL,
total_price		DOUBLE		NOT NULL,
creation_date	timestamp	default now(),
order_status	ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
payment_status  ENUM('Pending','Completed','Failed','Refunded') DEFAULT 'Pending',
shipping_address_id BIGINT,
billing_address_id BIGINT,
CONSTRAINT order_PK PRIMARY KEY (order_id),
CONSTRAINT order_FK1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT order_FK2 FOREIGN KEY (shipping_address_id) REFERENCES address (address_id) ON DELETE SET NULL ON UPDATE CASCADE,
CONSTRAINT order_FK3 FOREIGN KEY (billing_address_id) REFERENCES address (address_id) ON DELETE SET NULL ON UPDATE CASCADE
);

drop table if exists order_item;
CREATE TABLE order_item (
order_id 		BIGINT 		NOT NULL,
product_id 		BIGINT 		NOT NULL,
quantity 		INT NOT NULL CHECK (quantity > 0),
price_at_purchase DOUBLE    NOT NULL,
CONSTRAINT order_item_PK PRIMARY KEY (order_id, product_id),
CONSTRAINT order_item_FK1 FOREIGN KEY (order_id) REFERENCES sys_order (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT order_item_FK2 FOREIGN KEY (product_id) REFERENCES product (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists shipment;
CREATE TABLE shipment(
shipment_id		BIGINT		NOT NULL auto_increment,
order_id		BIGINT		NOT NULL UNIQUE,
is_delivered	BOOLEAN		DEFAULT false,
tracking_number VARCHAR(50),
carrier         VARCHAR(50),
expected_time	TIMESTAMP,
actual_delivery_time TIMESTAMP,
CONSTRAINT shipment_pk PRIMARY KEY (shipment_id),	
CONSTRAINT shipment_fk1 FOREIGN KEY (order_id) REFERENCES sys_order (order_id) ON UPDATE CASCADE ON DELETE CASCADE
);

drop table if exists product_review;
CREATE TABLE product_review(
review_id		BIGINT		NOT NULL auto_increment,
customer_id		BIGINT		NOT NULL,
product_id		BIGINT		NOT NULL,
title			VARCHAR(100)	NOT NULL,
review_text		VARCHAR(1000) NOT NULL,
rating          INT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
recommended		BOOLEAN		NOT NULL,
review_date     TIMESTAMP   DEFAULT now(),
CONSTRAINT review_pk PRIMARY KEY (review_id),	
CONSTRAINT review_fk1 FOREIGN KEY (product_id) REFERENCES product (product_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT review_fk2 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists wish_list;
CREATE TABLE wish_list(
wish_item_id	BIGINT		NOT NULL auto_increment,
customer_id		BIGINT		NOT NULL,
product_id		BIGINT		NOT NULL,
added_date      TIMESTAMP   DEFAULT NOW(),
CONSTRAINT wish_list_pk PRIMARY KEY (wish_item_id),	
CONSTRAINT wish_list_fk1 FOREIGN KEY (product_id) REFERENCES product (product_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT wish_list_fk2 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT wish_list_unique UNIQUE (customer_id, product_id)
);

drop table if exists feedback;
CREATE TABLE feedback(
feedback_id		BIGINT		NOT NULL auto_increment,
customer_id		BIGINT		NOT NULL,
feedback_text	VARCHAR(1000)	NOT NULL,
feedback_date	TIMESTAMP	DEFAULT NOW(),
is_satisfied	BOOLEAN		NOT NULL,
CONSTRAINT feedback_pk PRIMARY KEY (feedback_id),
CONSTRAINT feedback_fk FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- CATEGORIES (ids match the frontend categories page)
-- =====================================================
INSERT INTO category (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Groceries'),
(3, 'Clothes');

-- =====================================================
-- ADMINS (ids 1 and 2). Password for both: admin123 (stored as a BCrypt hash).
-- =====================================================
INSERT INTO sys_user (user_id, first_name, last_name, email, password, phone, role) VALUES
(1, 'Admin', 'One', 'admin1@ecodb.com', '$2a$10$LsxNf/PqSVhg5Va2nmHyXOkiFVFgAimPe9sSj97pmlk9qHKZn/VIG', '1234567891', 'ROLE_ADMIN'),
(2, 'Admin', 'Two', 'admin2@ecodb.com', '$2a$10$LsxNf/PqSVhg5Va2nmHyXOkiFVFgAimPe9sSj97pmlk9qHKZn/VIG', '1234567892', 'ROLE_ADMIN');
INSERT INTO sys_admin (admin_id) VALUES (1), (2);

-- =====================================================
-- PRODUCTS + IMAGES
-- Image files must be in <backend>/uploads/products/
-- =====================================================
-- Product owner: admin with id 2 (must exist in sys_admin)
SET @admin := 2;
-- Stored in product_image.image_url. The frontend adds "<backend>/uploads/" itself,
-- so only the part AFTER "uploads/" is stored here.
SET @prefix := 'products/';

-- ---------------------- CLOTHES (category 3) ----------------------
INSERT INTO product (admin_id, category_id, product_name, price, is_available, pro_description, details, quantity_in_stock, size, color) VALUES
(@admin, 3, 'Classic White T-Shirt', 19.99, true, 'Soft cotton crew-neck tee.', 'Material: 100% organic cotton. Machine washable.', 120, 'M', 'White'),
(@admin, 3, 'Slim Fit Blue Jeans', 49.99, true, 'Stretch denim slim fit jeans.', 'Material: 98% cotton, 2% elastane.', 80, '32', 'Blue'),
(@admin, 3, 'Black Hoodie', 44.5, true, 'Warm fleece-lined pullover hoodie.', 'Kangaroo pocket, adjustable drawstring.', 65, 'L', 'Black'),
(@admin, 3, 'Summer Floral Dress', 39.9, true, 'Light and breezy knee-length dress.', 'Material: viscose. Hand wash recommended.', 40, 'S', 'Pink'),
(@admin, 3, 'Leather Jacket', 129.0, true, 'Genuine leather biker jacket.', 'Zip closure, two inner pockets.', 25, 'L', 'Brown'),
(@admin, 3, 'Running Sneakers', 69.99, true, 'Breathable lightweight running shoes.', 'Cushioned sole, mesh upper.', 90, '42', 'Grey'),
(@admin, 3, 'Wool Winter Scarf', 15.75, true, 'Thick knitted wool scarf.', '180cm long, unisex.', 150, 'One Size', 'Red'),
(@admin, 3, 'Cotton Boxer Pack (3)', 17.25, true, 'Pack of three cotton boxers.', 'Elastic waistband, tag-free.', 200, 'M', 'Mixed'),
(@admin, 3, 'Denim Jacket', 59.0, true, 'Classic washed denim jacket.', 'Button closure, two chest pockets.', 45, 'M', 'Blue'),
(@admin, 3, 'Cotton Polo Shirt', 24.99, true, 'Breathable piqué polo shirt.', 'Ribbed collar, three-button placket.', 110, 'L', 'Navy');

-- ---------------------- GROCERIES (category 2) ----------------------
INSERT INTO product (admin_id, category_id, product_name, price, is_available, pro_description, details, quantity_in_stock, size, color) VALUES
(@admin, 2, 'Organic Bananas 1kg', 2.49, true, 'Fresh organic bananas.', 'Origin: local farms. Store at room temperature.', 300, '1 kg', NULL),
(@admin, 2, 'Extra Virgin Olive Oil 1L', 12.99, true, 'Cold-pressed olive oil.', 'Acidity below 0.8%. Keep away from sunlight.', 120, '1 L', NULL),
(@admin, 2, 'Basmati Rice 5kg', 14.5, true, 'Premium long-grain basmati rice.', 'Aged 2 years, non-sticky.', 90, '5 kg', NULL),
(@admin, 2, 'Whole Wheat Bread', 1.99, true, 'Freshly baked whole wheat loaf.', 'No preservatives. Best within 3 days.', 75, '500 g', NULL),
(@admin, 2, 'Fresh Whole Milk 1L', 1.59, true, 'Pasteurized whole milk.', 'Keep refrigerated at 2-6 C.', 180, '1 L', NULL),
(@admin, 2, 'Free-Range Eggs (12)', 3.99, true, 'Dozen free-range eggs.', 'Grade A, size M.', 140, '12 pcs', NULL),
(@admin, 2, 'Roasted Arabica Coffee 250g', 8.75, true, 'Medium roast ground coffee.', 'Notes of chocolate and caramel.', 100, '250 g', NULL),
(@admin, 2, 'Mixed Nuts 500g', 9.6, true, 'Almonds, cashews and walnuts.', 'Unsalted, vacuum sealed.', 85, '500 g', NULL),
(@admin, 2, 'Greek Yogurt 500g', 3.25, true, 'Thick and creamy plain yogurt.', 'High protein, no added sugar. Keep refrigerated.', 130, '500 g', NULL),
(@admin, 2, 'Spaghetti Pasta 500g', 1.49, true, 'Durum wheat spaghetti.', 'Cooks in 9 minutes.', 220, '500 g', NULL);

-- ---------------------- ELECTRONICS (category 1) ----------------------
INSERT INTO product (admin_id, category_id, product_name, price, is_available, pro_description, details, quantity_in_stock, size, color) VALUES
(@admin, 1, 'Wireless Bluetooth Headphones', 59.99, true, 'Over-ear headphones with noise isolation.', 'Bluetooth 5.3, 30h battery, USB-C charging.', 70, NULL, 'Black'),
(@admin, 1, 'Smartphone 128GB', 399.0, true, '6.5" AMOLED display smartphone.', '8GB RAM, 128GB storage, 50MP camera.', 35, NULL, 'Blue'),
(@admin, 1, 'Laptop 15.6" Core i5', 749.99, true, 'Everyday productivity laptop.', '16GB RAM, 512GB SSD, Full HD display.', 20, NULL, 'Silver'),
(@admin, 1, 'Smart Watch Series X', 89.9, true, 'Fitness tracking smart watch.', 'Heart-rate monitor, GPS, water resistant.', 55, NULL, 'Black'),
(@admin, 1, 'Portable Power Bank 20000mAh', 24.99, true, 'Fast-charging power bank.', 'Dual USB + USB-C, 22.5W output.', 160, NULL, 'White'),
(@admin, 1, '27" 4K Monitor', 279.0, true, 'IPS 4K UHD monitor.', '60Hz, HDMI + DisplayPort, adjustable stand.', 30, NULL, 'Black'),
(@admin, 1, 'Mechanical Keyboard RGB', 54.5, true, 'Hot-swappable mechanical keyboard.', 'Blue switches, RGB backlight, USB-C.', 60, NULL, 'Black'),
(@admin, 1, 'Wireless Mouse', 14.99, true, 'Ergonomic 2.4GHz wireless mouse.', 'Adjustable DPI, silent clicks.', 210, NULL, 'Grey'),
(@admin, 1, 'Bluetooth Speaker', 34.99, true, 'Portable waterproof speaker.', '12h battery, IPX7, built-in mic.', 95, NULL, 'Black'),
(@admin, 1, 'Full HD Webcam', 39.9, true, '1080p webcam with microphone.', 'Auto light correction, USB plug and play.', 75, NULL, 'Black');

-- =====================================================
-- IMAGES: one main image per product, matched by product name
-- =====================================================
DROP TEMPORARY TABLE IF EXISTS seed_images;
CREATE TEMPORARY TABLE seed_images (product_name VARCHAR(100) NOT NULL, file_name VARCHAR(255) NOT NULL);
INSERT INTO seed_images (product_name, file_name) VALUES
('Classic White T-Shirt', 'classic-white-t-shirt.jpg'),
('Slim Fit Blue Jeans', 'slim-fit-blue-jeans.jpg'),
('Black Hoodie', 'black-hoodie.jpg'),
('Summer Floral Dress', 'summer-floral-dress.jpg'),
('Leather Jacket', 'leather-jacket.jpg'),
('Running Sneakers', 'running-sneakers.jpg'),
('Wool Winter Scarf', 'wool-winter-scarf.jpg'),
('Cotton Boxer Pack (3)', 'cotton-boxer-pack-3.jpg'),
('Denim Jacket', 'denim-jacket.jpg'),
('Cotton Polo Shirt', 'cotton-polo-shirt.jpg'),
('Organic Bananas 1kg', 'organic-bananas-1kg.jpg'),
('Extra Virgin Olive Oil 1L', 'extra-virgin-olive-oil-1l.jpg'),
('Basmati Rice 5kg', 'basmati-rice-5kg.jpg'),
('Whole Wheat Bread', 'whole-wheat-bread.jpg'),
('Fresh Whole Milk 1L', 'fresh-whole-milk-1l.jpg'),
('Free-Range Eggs (12)', 'free-range-eggs-12.jpg'),
('Roasted Arabica Coffee 250g', 'roasted-arabica-coffee-250g.jpg'),
('Mixed Nuts 500g', 'mixed-nuts-500g.jpg'),
('Greek Yogurt 500g', 'greek-yogurt-500g.jpg'),
('Spaghetti Pasta 500g', 'spaghetti-pasta-500g.jpg'),
('Wireless Bluetooth Headphones', 'wireless-bluetooth-headphones.jpg'),
('Smartphone 128GB', 'smartphone-128gb.jpg'),
('Laptop 15.6" Core i5', 'laptop-15-6-core-i5.jpg'),
('Smart Watch Series X', 'smart-watch-series-x.jpg'),
('Portable Power Bank 20000mAh', 'portable-power-bank-20000mah.jpg'),
('27" 4K Monitor', '27-4k-monitor.jpg'),
('Mechanical Keyboard RGB', 'mechanical-keyboard-rgb.jpg'),
('Wireless Mouse', 'wireless-mouse.jpg'),
('Bluetooth Speaker', 'bluetooth-speaker.jpg'),
('Full HD Webcam', 'full-hd-webcam.jpg');

INSERT INTO product_image (product_id, image_url, is_main)
SELECT p.product_id, CONCAT(@prefix, s.file_name), true
FROM seed_images s
JOIN product p ON p.product_name = s.product_name
WHERE NOT EXISTS (SELECT 1 FROM product_image i WHERE i.product_id = p.product_id);

-- Check
SELECT c.category_name, COUNT(DISTINCT p.product_id) AS products, COUNT(i.image_id) AS images
FROM category c
LEFT JOIN product p ON p.category_id = c.category_id
LEFT JOIN product_image i ON i.product_id = p.product_id
GROUP BY c.category_name;