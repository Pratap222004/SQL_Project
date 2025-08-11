
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

CREATE TABLE users (
  user_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  email          VARCHAR(255) NOT NULL UNIQUE,
  password_hash  CHAR(60) NOT NULL,
  full_name      VARCHAR(120) NOT NULL,
  phone          VARCHAR(20),
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE addresses (
  address_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL,
  label          VARCHAR(50) DEFAULT 'Home',
  line1          VARCHAR(255) NOT NULL,
  line2          VARCHAR(255),
  city           VARCHAR(80) NOT NULL,
  state          VARCHAR(80) NOT NULL,
  postal_code    VARCHAR(20) NOT NULL,
  country        VARCHAR(80) NOT NULL DEFAULT 'India',
  is_default     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE categories (
  category_id    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  parent_id      BIGINT UNSIGNED,
  name           VARCHAR(120) NOT NULL,
  slug           VARCHAR(160) NOT NULL UNIQUE,
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  category_id    BIGINT UNSIGNED NOT NULL,
  name           VARCHAR(200) NOT NULL,
  slug           VARCHAR(220) NOT NULL UNIQUE,
  description    TEXT,
  price_cents    INT UNSIGNED NOT NULL,
  currency       CHAR(3) NOT NULL DEFAULT 'INR',
  active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE product_images (
  image_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  product_id     BIGINT UNSIGNED NOT NULL,
  url            VARCHAR(500) NOT NULL,
  is_primary     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE inventory (
  product_id     BIGINT UNSIGNED PRIMARY KEY,
  quantity_on_hand INT NOT NULL DEFAULT 0,
  reorder_level    INT NOT NULL DEFAULT 5,
  CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE carts (
  cart_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  cart_item_id   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  cart_id        BIGINT UNSIGNED NOT NULL,
  product_id     BIGINT UNSIGNED NOT NULL,
  quantity       INT NOT NULL CHECK (quantity > 0),
  unit_price_cents INT UNSIGNED NOT NULL,
  added_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_cart_product (cart_id, product_id),
  CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE orders (
  order_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL,
  shipping_address_id BIGINT UNSIGNED NOT NULL,
  status         ENUM('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  subtotal_cents INT UNSIGNED NOT NULL DEFAULT 0,
  discount_cents INT UNSIGNED NOT NULL DEFAULT 0,
  tax_cents      INT UNSIGNED NOT NULL DEFAULT 0,
  shipping_cents INT UNSIGNED NOT NULL DEFAULT 0,
  total_cents    INT UNSIGNED NOT NULL DEFAULT 0,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CONSTRAINT fk_orders_address FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE order_items (
  order_item_id  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id       BIGINT UNSIGNED NOT NULL,
  product_id     BIGINT UNSIGNED NOT NULL,
  quantity       INT NOT NULL CHECK (quantity > 0),
  unit_price_cents INT UNSIGNED NOT NULL,
  line_total_cents INT UNSIGNED NOT NULL,
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE payments (
  payment_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id       BIGINT UNSIGNED NOT NULL,
  provider       ENUM('RAZORPAY','STRIPE','PAYPAL','COD') NOT NULL,
  status         ENUM('INITIATED','AUTHORIZED','CAPTURED','FAILED','REFUNDED') NOT NULL,
  amount_cents   INT UNSIGNED NOT NULL,
  currency       CHAR(3) NOT NULL DEFAULT 'INR',
  transaction_ref VARCHAR(80),
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE shipments (
  shipment_id    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_id       BIGINT UNSIGNED NOT NULL,
  carrier        VARCHAR(80),
  tracking_no    VARCHAR(100),
  shipped_at     DATETIME,
  delivered_at   DATETIME,
  CONSTRAINT fk_shipments_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reviews (
  review_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  product_id     BIGINT UNSIGNED NOT NULL,
  user_id        BIGINT UNSIGNED NOT NULL,
  rating         TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title          VARCHAR(150),
  body           TEXT,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review_user_product (product_id, user_id),
  CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE coupons (
  coupon_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code           VARCHAR(40) NOT NULL UNIQUE,
  description    VARCHAR(200),
  percent_off    DECIMAL(5,2), -- e.g., 10.00 for 10%
  amount_off_cents INT UNSIGNED,
  valid_from     DATE,
  valid_to       DATE,
  min_subtotal_cents INT UNSIGNED DEFAULT 0,
  max_uses       INT,
  uses_count     INT NOT NULL DEFAULT 0,
  CHECK (percent_off IS NOT NULL OR amount_off_cents IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE order_coupons (
  order_id       BIGINT UNSIGNED NOT NULL,
  coupon_id      BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (order_id, coupon_id),
  CONSTRAINT fk_order_coupons_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_coupons_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Wishlists
CREATE TABLE wishlists (
  wishlist_id    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL,
  name           VARCHAR(120) NOT NULL DEFAULT 'My Wishlist',
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE wishlist_items (
  wishlist_item_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  wishlist_id    BIGINT UNSIGNED NOT NULL,
  product_id     BIGINT UNSIGNED NOT NULL,
  UNIQUE KEY uq_wishlist_product (wishlist_id, product_id),
  CONSTRAINT fk_wishlist_items_wishlist FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
  CONSTRAINT fk_wishlist_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(active);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_inventory_qoh ON inventory(quantity_on_hand);

DELIMITER $$
CREATE TRIGGER trg_before_order_items_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
  DECLARE current_stock INT;
  SELECT quantity_on_hand INTO current_stock FROM inventory WHERE product_id = NEW.product_id FOR UPDATE;
  IF current_stock IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventory record not found for product.';
  END IF;
  IF NEW.quantity > current_stock THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for product.';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_after_order_items_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  UPDATE inventory SET quantity_on_hand = quantity_on_hand - NEW.quantity
  WHERE product_id = NEW.product_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_after_order_items_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
  UPDATE inventory SET quantity_on_hand = quantity_on_hand + OLD.quantity
  WHERE product_id = OLD.product_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_before_order_items_line_total
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
  IF NEW.line_total_cents IS NULL OR NEW.line_total_cents = 0 THEN
    SET NEW.line_total_cents = NEW.quantity * NEW.unit_price_cents;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_recompute_order_totals(IN p_order_id BIGINT UNSIGNED)
BEGIN
  DECLARE v_subtotal INT DEFAULT 0;
  SELECT IFNULL(SUM(line_total_cents),0) INTO v_subtotal
  FROM order_items WHERE order_id = p_order_id;
  UPDATE orders
    SET subtotal_cents = v_subtotal,
        tax_cents = ROUND(v_subtotal * 0.18), -- 18% GST example
        total_cents = v_subtotal + ROUND(v_subtotal * 0.18) + shipping_cents - discount_cents
  WHERE order_id = p_order_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_after_order_items_ai
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  CALL sp_recompute_order_totals(NEW.order_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_after_order_items_ad
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
  CALL sp_recompute_order_totals(OLD.order_id);
END$$
DELIMITER ;

USE ecommerce_db;

-- Allow local file imports (might require admin)
SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS stg_customers;
CREATE TABLE stg_customers (
  customer_id VARCHAR(50),
  customer_unique_id VARCHAR(50),
  customer_zip_code_prefix VARCHAR(20),
  customer_city VARCHAR(80),
  customer_state VARCHAR(10)
);

DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders (
  order_id VARCHAR(50),
  customer_id VARCHAR(50),
  order_status VARCHAR(30),
  order_purchase_timestamp DATETIME,
  order_approved_at DATETIME,
  order_delivered_carrier_date DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME
);

DROP TABLE IF EXISTS stg_order_items;
CREATE TABLE stg_order_items (
  order_id VARCHAR(50),
  order_item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date DATETIME,
  price DECIMAL(10,2),
  freight_value DECIMAL(10,2)
);

DROP TABLE IF EXISTS stg_products;
CREATE TABLE stg_products (
  product_id VARCHAR(50),
  product_category_name VARCHAR(100),
  product_name_lenght INT,
  product_description_lenght INT,
  product_photos_qty INT,
  product_weight_g INT,
  product_length_cm INT,
  product_height_cm INT,
  product_width_cm INT
);

-- Category translations (pt → en)
DROP TABLE IF EXISTS stg_category_translation;
CREATE TABLE stg_category_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);

-- Payments
DROP TABLE IF EXISTS stg_payments;
CREATE TABLE stg_payments (
  order_id VARCHAR(50),
  payment_sequential INT,
  payment_type VARCHAR(30),
  payment_installments INT,
  payment_value DECIMAL(10,2)
);

-- Reviews
DROP TABLE IF EXISTS stg_reviews;
CREATE TABLE stg_reviews (
  review_id VARCHAR(50),
  order_id VARCHAR(50),
  review_score INT,
  review_comment_title VARCHAR(255),
  review_comment_message TEXT,
  review_creation_date DATETIME,
  review_answer_timestamp DATETIME
);


INSERT IGNORE INTO categories (name, slug)
SELECT DISTINCT
  COALESCE(t.product_category_name_english, p.product_category_name) AS name,
  LOWER(REPLACE(COALESCE(t.product_category_name_english, p.product_category_name),' ','-')) AS slug
FROM stg_products p
LEFT JOIN stg_category_translation t USING (product_category_name)
WHERE COALESCE(t.product_category_name_english, p.product_category_name) IS NOT NULL;

-- Products (price from order_items avg → cents)
INSERT IGNORE INTO products (category_id, name, slug, description, price_cents, currency, active)
SELECT 
  c.category_id,
  CONCAT('Product ', p.product_id) AS name,
  CONCAT('olist-', p.product_id) AS slug,
  NULL,
  COALESCE(ROUND(AVG(oi.price)*100), 49900),
  'BRL',
  TRUE
FROM stg_products p
LEFT JOIN stg_category_translation t USING (product_category_name)
LEFT JOIN categories c
  ON c.slug = LOWER(REPLACE(COALESCE(t.product_category_name_english, p.product_category_name),' ','-'))
LEFT JOIN stg_order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, c.category_id;

-- Inventory (big stock so triggers won’t fail on inserts)
INSERT IGNORE INTO inventory (product_id, quantity_on_hand, reorder_level)
SELECT product_id, 1000000, 10 FROM products;


INSERT IGNORE INTO users (email, password_hash, full_name, phone)
SELECT 
  CONCAT(LEFT(customer_id,8),'@olist.local'),
  RPAD('x',60,'x'),
  CONCAT('Customer ', RIGHT(customer_id,6)),
  '0000000000'
FROM stg_customers;

INSERT IGNORE INTO addresses (user_id, label, line1, city, state, postal_code, country, is_default)
SELECT u.user_id, 'Home', 'N/A', c.customer_city, c.customer_state, c.customer_zip_code_prefix, 'Brazil', TRUE
FROM stg_customers c
JOIN users u ON u.email = CONCAT(LEFT(c.customer_id,8),'@olist.local');

DROP TEMPORARY TABLE IF EXISTS tmp_order_map;
CREATE TEMPORARY TABLE tmp_order_map AS
SELECT 
  o.order_id,
  u.user_id,
  a.address_id AS shipping_address_id,
  CASE
    WHEN o.order_status IN ('invoiced','processing','shipped') THEN 'SHIPPED'
    WHEN o.order_status = 'delivered' THEN 'DELIVERED'
    WHEN o.order_status = 'canceled' THEN 'CANCELLED'
    WHEN o.order_approved_at IS NULL THEN 'PENDING'
    ELSE 'PAID'
  END AS status,
  0 AS subtotal_cents, 0 AS discount_cents, 0 AS tax_cents, 0 AS shipping_cents, 0 AS total_cents,
  o.order_purchase_timestamp AS created_at
FROM stg_orders o
JOIN stg_customers c USING (customer_id)
JOIN users u ON u.email = CONCAT(LEFT(c.customer_id,8),'@olist.local')
JOIN addresses a ON a.user_id = u.user_id AND a.is_default = TRUE;

INSERT IGNORE INTO orders
(user_id, shipping_address_id, status, subtotal_cents, discount_cents, tax_cents, shipping_cents, total_cents, created_at)
SELECT user_id, shipping_address_id, status, subtotal_cents, discount_cents, tax_cents, shipping_cents, total_cents, created_at
FROM tmp_order_map;

INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price_cents, line_total_cents)
SELECT 
  o2.order_id,
  p.product_id,
  1,
  ROUND(oi.price*100),
  ROUND(oi.price*100)
FROM stg_order_items oi
JOIN products p ON p.slug = CONCAT('olist-', oi.product_id)
JOIN stg_orders o ON o.order_id = oi.order_id
JOIN stg_customers c USING (customer_id)
JOIN users u ON u.email = CONCAT(LEFT(c.customer_id,8),'@olist.local')
JOIN orders o2 ON o2.user_id = u.user_id AND o2.created_at = o.order_purchase_timestamp;

UPDATE orders o
JOIN (
  SELECT o2.order_id, ROUND(SUM(oi.freight_value)*100) AS ship
  FROM stg_order_items oi
  JOIN stg_orders so ON so.order_id = oi.order_id
  JOIN stg_customers sc ON sc.customer_id = so.customer_id
  JOIN users u ON u.email = CONCAT(LEFT(sc.customer_id,8),'@olist.local')
  JOIN orders o2 ON o2.user_id = u.user_id AND o2.created_at = so.order_purchase_timestamp
  GROUP BY o2.order_id
) x ON x.order_id = o.order_id
SET o.shipping_cents = x.ship;

-- compute subtotals & totals (tax=0 for historical data)
UPDATE orders o
JOIN (
  SELECT order_id, IFNULL(SUM(line_total_cents),0) AS sub
  FROM order_items GROUP BY order_id
) s ON s.order_id = o.order_id
SET o.subtotal_cents = s.sub,
    o.tax_cents = 0,
    o.total_cents = s.sub + o.shipping_cents;

INSERT IGNORE INTO payments (order_id, provider, status, amount_cents, currency, transaction_ref)
SELECT 
  o2.order_id,
  CASE LOWER(p.payment_type)
    WHEN 'credit_card' THEN 'STRIPE'
    WHEN 'boleto' THEN 'PAYPAL'
    WHEN 'voucher' THEN 'PAYPAL'
    WHEN 'debit_card' THEN 'STRIPE'
    ELSE 'COD'
  END,
  'CAPTURED',
  ROUND(p.payment_value*100),
  'BRL',
  NULL
FROM stg_payments p
JOIN stg_orders so ON so.order_id = p.order_id
JOIN stg_customers sc ON sc.customer_id = so.customer_id
JOIN users u ON u.email = CONCAT(LEFT(sc.customer_id,8),'@olist.local')
JOIN orders o2 ON o2.user_id = u.user_id AND o2.created_at = so.order_purchase_timestamp;

-- Shipments
INSERT IGNORE INTO shipments (order_id, carrier, tracking_no, shipped_at, delivered_at)
SELECT 
  o2.order_id,
  NULL, NULL,
  so.order_delivered_carrier_date,
  so.order_delivered_customer_date
FROM stg_orders so
JOIN stg_customers sc USING (customer_id)
JOIN users u ON u.email = CONCAT(LEFT(sc.customer_id,8),'@olist.local')
JOIN orders o2 ON o2.user_id = u.user_id AND o2.created_at = so.order_purchase_timestamp;

-- Reviews
INSERT IGNORE INTO reviews (product_id, user_id, rating, title, body, created_at)
SELECT 
  p.product_id,
  u.user_id,
  COALESCE(r.review_score,3),
  LEFT(COALESCE(r.review_comment_title,''),150),
  r.review_comment_message,
  r.review_creation_date
FROM stg_reviews r
JOIN stg_orders so ON so.order_id = r.order_id
JOIN stg_order_items oi ON oi.order_id = so.order_id
JOIN products p ON p.slug = CONCAT('olist-', oi.product_id)
JOIN stg_customers sc ON sc.customer_id = so.customer_id
JOIN users u ON u.email = CONCAT(LEFT(sc.customer_id,8),'@olist.local');

select * from users;
select * from products;















