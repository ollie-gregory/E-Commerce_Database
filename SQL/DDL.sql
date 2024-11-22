-- DDL for the database schema with length constraints and NOT NULL requirements

CREATE TABLE CUSTOMER (
  cst_email VARCHAR(255) PRIMARY KEY NOT NULL,
  cst_name VARCHAR(100) NOT NULL,
  cst_password VARCHAR(100) NOT NULL,
  cst_birth_date DATE NOT NULL,
  cst_phone VARCHAR(15),
  building VARCHAR(255),
  street VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100),
  post_code VARCHAR(20)
);

CREATE TABLE PAYMENT_METHOD (
  payment_method_id INTEGER PRIMARY KEY,
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('CREDIT_CARD', 'GIFT_CARD')),
  cst_email VARCHAR(255),
  is_default BOOLEAN,
  expiry_date DATE,
  FOREIGN KEY (cst_email) REFERENCES CUSTOMER (cst_email)
);

CREATE TABLE CREDIT_CARD (
  card_id INTEGER PRIMARY KEY,
  card_number VARCHAR(16) NOT NULL,
  card_name VARCHAR(100) NOT NULL,
  cvv INTEGER NOT NULL,
  FOREIGN KEY (card_id) REFERENCES PAYMENT_METHOD (payment_method_id)
);

CREATE TABLE GIFT_CARD (
  card_id INTEGER PRIMARY KEY,
  serial_number VARCHAR(30) NOT NULL,
  initial_amount REAL,
  current_balance REAL,
  FOREIGN KEY (card_id) REFERENCES PAYMENT_METHOD (payment_method_id)
);

CREATE TABLE PRODUCT (
  p_number INTEGER PRIMARY KEY,
  p_name VARCHAR(100) NOT NULL,
  p_stock INTEGER NOT NULL,
  p_category VARCHAR(50),
  p_warranty_length INTEGER,
  p_price REAL NOT NULL,
  p_weight REAL,
  p_dimensions VARCHAR(50),
  p_colour VARCHAR(50),
  p_description VARCHAR(255),
  p_brand VARCHAR(50),
  is_unavailable BOOLEAN
);

CREATE TABLE BASKET (
  basket_id INTEGER PRIMARY KEY,
  cst_email VARCHAR(255) NOT NULL,
  FOREIGN KEY (cst_email) REFERENCES CUSTOMER (cst_email)
);

CREATE TABLE BASKET_PRODUCT (
  basket_id INTEGER,
  p_number INTEGER,
  bsk_quantity INTEGER NOT NULL,
  PRIMARY KEY (basket_id, p_number),
  FOREIGN KEY (basket_id) REFERENCES BASKET (basket_id),
  FOREIGN KEY (p_number) REFERENCES PRODUCT (p_number)
);

CREATE TABLE ORDERS (
  o_number INTEGER PRIMARY KEY,
  cst_email VARCHAR(255) NOT NULL,
  o_date DATE NOT NULL,
  o_total REAL NOT NULL,
  o_deduction REAL,
  o_grand_total REAL NOT NULL,
  payment_method_id INTEGER,
  FOREIGN KEY (cst_email) REFERENCES CUSTOMER (cst_email),
  FOREIGN KEY (payment_method_id) REFERENCES PAYMENT_METHOD (payment_method_id)
);

CREATE TABLE ORDER_PRODUCT (
  o_number INTEGER,
  p_number INTEGER,
  p_o_quantity INTEGER NOT NULL,
  p_o_subtotal REAL NOT NULL,
  PRIMARY KEY (o_number, p_number),
  FOREIGN KEY (o_number) REFERENCES ORDERS (o_number),
  FOREIGN KEY (p_number) REFERENCES PRODUCT (p_number)
);

CREATE TABLE DELIVERY (
  tracking_number INTEGER PRIMARY KEY,
  o_number INTEGER NOT NULL,
  delivery_date DATE,
  delivery_status VARCHAR(20) NOT NULL CHECK (delivery_status IN ('Delivered', 'Postponed', 'Cancelled', 'Pending')),
  delivery_building VARCHAR(255),
  delivery_street VARCHAR(255),
  delivery_city VARCHAR(100),
  delivery_country VARCHAR(100),
  delivery_post_code VARCHAR(20),
  FOREIGN KEY (o_number) REFERENCES ORDERS (o_number)
);

CREATE TABLE REVIEW (
  r_number INTEGER PRIMARY KEY,
  r_ranking INTEGER NOT NULL,
  r_text VARCHAR(1000),
  r_date DATE NOT NULL,
  cst_email VARCHAR(255) NOT NULL,
  p_number INTEGER NOT NULL,
  FOREIGN KEY (cst_email) REFERENCES CUSTOMER (cst_email),
  FOREIGN KEY (p_number) REFERENCES PRODUCT (p_number)
);

CREATE TABLE ORDER_RETURNS (
  rt_ticket_number INTEGER PRIMARY KEY,
  o_number INTEGER NOT NULL,
  rt_refund_total REAL NOT NULL,
  rt_start_date DATE NOT NULL,
  rt_due_date DATE,
  rt_status VARCHAR(20) NOT NULL CHECK (rt_status IN ('Completed', 'Cancelled', 'Denied', 'Pending')),
  FOREIGN KEY (o_number) REFERENCES ORDERS (o_number)
);