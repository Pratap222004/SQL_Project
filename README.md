# 🛒 E-commerce SQL ETL & Database Project

This project is a **full MySQL 8 database** for an e-commerce platform, including:
- Normalized relational schema with 15+ tables
- Data integrity enforced via constraints, triggers, and procedures
- ETL workflow from raw CSV (Olist dataset) → staging → transformed final tables
- Analytical queries for reporting and KPIs

---

## 📊 ER Diagram



<img width="1922" height="1190" alt="image" src="https://github.com/user-attachments/assets/f503e3ed-46f6-47a9-9080-b4b1258058d8" />


---

## 🔄 ETL Flow

The ETL process is **pure SQL** and follows these steps:

1. **Extract**:  
   - Raw Olist CSV files are imported into `stg_*` staging tables using  
     ```sql
     LOAD DATA LOCAL INFILE 
     ```
     or MySQL Workbench Import Wizard.

2. **Transform**:  
   - Data is cleaned, joined, and transformed:
     - Category names translated
     - Product prices calculated from order items
     - Order statuses normalized

3. **Load**:  
   - Final data inserted into production tables:
     - `categories`, `products`, `inventory`
     - `users`, `addresses`, `orders`, `order_items`
     - `payments`, `shipments`, `reviews`

4. **Post-load calculations**:  
   - Triggers & stored procedures recalculate order totals
   - Inventory is updated on order changes

---

## 🗄 Schema Overview

Key tables:
- **users** – Customer accounts
- **addresses** – Shipping addresses linked to users
- **categories** & **products** – Catalog organization
- **inventory** – Product stock tracking
- **carts** & **cart_items** – Pre-order shopping cart
- **orders** & **order_items** – Completed sales
- **payments** – Payment records
- **shipments** – Delivery tracking
- **reviews** – Customer feedback
- **coupons** – Discounts
- **wishlists** – Saved products

---

## 🛠 Key Features

- **Triggers**:
  - Prevent overselling products
  - Auto-update inventory after order insert/delete
  - Auto-calculate `line_total_cents` if not provided
  - Recompute order totals on item changes

- **Stored Procedure**:
  - `sp_recompute_order_totals` — Updates subtotal, tax, and total for a given order

- **Indexes** for performance:
  - e.g., `idx_products_category`, `idx_orders_user`

---

## 📥 Sample Queries & Output
<img width="1953" height="899" alt="image" src="https://github.com/user-attachments/assets/02b45d31-cb24-447a-b4b0-1f088147a464" />

**Get all users**:
```sql
SELECT * FROM users LIMIT 5;
