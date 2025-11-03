/* ===============================
   CREATE DATABASE TABLES
   Fraud Risk Analysis Project
================================= */

/* 1️⃣ TABLE: Musteriler (Customers) */
CREATE TABLE Musteriler (
    customer_id        NUMBER(10)      NOT NULL,
    first_name         VARCHAR2(100 CHAR),
    last_name          VARCHAR2(100 CHAR),
    date_of_birth      DATE,
    city               VARCHAR2(50 CHAR),
    country            VARCHAR2(50 CHAR),
    registration_date  TIMESTAMP,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

COMMENT ON TABLE Musteriler IS 'Bankın unikal müştəriləri haqqında məlumatları saxlayır.';
COMMENT ON COLUMN Musteriler.customer_id IS 'Müştərinin unikal nömrəsi (PK).';


/* 2️⃣ TABLE: Saticilar (Merchants) */
CREATE TABLE Saticilar (
    merchant_id        NUMBER(10)     NOT NULL,
    merchant_name      VARCHAR2(100 CHAR),
    merchant_category  VARCHAR2(50 CHAR),
    merchant_country   VARCHAR2(50 CHAR),
    CONSTRAINT pk_merchants PRIMARY KEY (merchant_id)
);

COMMENT ON TABLE Saticilar IS 'Ödənişlərin qəbul edildiyi ticarət və xidmət obyektləri.';
COMMENT ON COLUMN Saticilar.merchant_id IS 'Satıcının unikal nömrəsi (PK).';


/* 3️⃣ TABLE: Kartlar (Cards) */
CREATE TABLE Kartlar (
    card_id        NUMBER(10)     NOT NULL,
    customer_id    NUMBER(10)     NOT NULL,
    card_number    VARCHAR2(25 CHAR),
    card_type      VARCHAR2(20 CHAR),
    credit_limit   NUMBER(10,2),
    card_status    VARCHAR2(20 CHAR),
    issue_date     DATE,
    CONSTRAINT pk_cards PRIMARY KEY (card_id),
    CONSTRAINT fk_cards_customers FOREIGN KEY (customer_id)
        REFERENCES Musteriler(customer_id),
    CONSTRAINT chk_card_status CHECK (card_status IN ('Active', 'Stolen'))
);

COMMENT ON TABLE Kartlar IS 'Müştərilərə aid olan kredit/debet kartları.';
COMMENT ON COLUMN Kartlar.customer_id IS 'Müştəri ID-si (FK).';
COMMENT ON COLUMN Kartlar.card_status IS 'Active və ya Stolen statusu.';


/* 4️⃣ TABLE: Tranzaksiyalar (Transactions) */
CREATE TABLE Tranzaksiyalar (
    transaction_id        NUMBER(19)     NOT NULL,
    card_id               NUMBER(10)     NOT NULL,
    merchant_id           NUMBER(10)     NOT NULL,
    transaction_amount    NUMBER(10,2),
    transaction_datetime  TIMESTAMP,
    transaction_location  VARCHAR2(100 CHAR),
    transaction_status    VARCHAR2(20 CHAR),
    is_fraud              NUMBER(1)      NOT NULL,
    CONSTRAINT pk_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_transactions_cards FOREIGN KEY (card_id)
        REFERENCES Kartlar(card_id),
    CONSTRAINT fk_transactions_merchants FOREIGN KEY (merchant_id)
        REFERENCES Saticilar(merchant_id),
    CONSTRAINT chk_is_fraud CHECK (is_fraud IN (0,1))
);

COMMENT ON TABLE Tranzaksiyalar IS 'Bütün maliyyə əməliyyatlarının qeydi.';
COMMENT ON COLUMN Tranzaksiyalar.is_fraud IS '1 = fraud, 0 = normal';

COMMIT;
