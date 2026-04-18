-- ============================================================
--  PROJECT 1: LIBRARY MANAGEMENT SYSTEM
--  Description: Manages books, members, loans, fines & staff
-- ============================================================

-- Drop existing tables (safe re-run)
DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS members CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

-- ─────────────────────────────────────────────
--  TABLES
-- ─────────────────────────────────────────────

CREATE TABLE publishers (
    publisher_id   SERIAL PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    address        TEXT,
    phone          VARCHAR(20),
    email          VARCHAR(100)
);

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(80) NOT NULL UNIQUE,
    description   TEXT
);

CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(60) NOT NULL,
    last_name   VARCHAR(60) NOT NULL,
    birth_date  DATE,
    nationality VARCHAR(60)
);

CREATE TABLE books (
    book_id       SERIAL PRIMARY KEY,
    isbn          VARCHAR(20) UNIQUE NOT NULL,
    title         VARCHAR(255) NOT NULL,
    author_id     INT REFERENCES authors(author_id) ON DELETE SET NULL,
    publisher_id  INT REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    category_id   INT REFERENCES categories(category_id) ON DELETE SET NULL,
    publish_year  INT,
    language      VARCHAR(40) DEFAULT 'English',
    total_copies  INT NOT NULL DEFAULT 1 CHECK (total_copies >= 0),
    shelf_location VARCHAR(20)
);

CREATE TABLE book_copies (
    copy_id    SERIAL PRIMARY KEY,
    book_id    INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    status     VARCHAR(20) NOT NULL DEFAULT 'Available'
                  CHECK (status IN ('Available','Loaned','Lost','Damaged')),
    condition  VARCHAR(20) DEFAULT 'Good'
);

CREATE TABLE members (
    member_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(60) NOT NULL,
    last_name       VARCHAR(60) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    address         TEXT,
    join_date       DATE NOT NULL DEFAULT CURRENT_DATE,
    membership_type VARCHAR(20) DEFAULT 'Standard'
                       CHECK (membership_type IN ('Standard','Premium','Student','Senior')),
    active          BOOLEAN DEFAULT TRUE
);

CREATE TABLE staff (
    staff_id    SERIAL PRIMARY KEY,
    first_name  VARCHAR(60) NOT NULL,
    last_name   VARCHAR(60) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    role        VARCHAR(40) DEFAULT 'Librarian',
    hire_date   DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE loans (
    loan_id      SERIAL PRIMARY KEY,
    copy_id      INT NOT NULL REFERENCES book_copies(copy_id),
    member_id    INT NOT NULL REFERENCES members(member_id),
    staff_id     INT REFERENCES staff(staff_id),
    loan_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,
    status       VARCHAR(20) DEFAULT 'Active'
                    CHECK (status IN ('Active','Returned','Overdue'))
);

CREATE TABLE fines (
    fine_id      SERIAL PRIMARY KEY,
    loan_id      INT NOT NULL REFERENCES loans(loan_id),
    amount       NUMERIC(8,2) NOT NULL CHECK (amount >= 0),
    issued_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    paid_date    DATE,
    paid         BOOLEAN DEFAULT FALSE
);

-- ─────────────────────────────────────────────
--  INDEXES
-- ─────────────────────────────────────────────

CREATE INDEX idx_books_title       ON books(title);
CREATE INDEX idx_books_author      ON books(author_id);
CREATE INDEX idx_loans_member      ON loans(member_id);
CREATE INDEX idx_loans_status      ON loans(status);
CREATE INDEX idx_book_copies_book  ON book_copies(book_id);

-- ─────────────────────────────────────────────
--  SAMPLE DATA
-- ─────────────────────────────────────────────

INSERT INTO publishers (name, address, phone, email) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '+1-212-782-9000', 'info@penguinrandomhouse.com'),
('HarperCollins',        '195 Broadway, New York, NY',  '+1-212-207-7000', 'contact@harpercollins.com'),
('Oxford University Press','Great Clarendon St, Oxford','44-1865-556767','oup@oup.com'),
('Simon & Schuster',     '1230 Ave of Americas, NY',    '+1-212-698-7000','sands@simonandschuster.com'),
('MIT Press',            '55 Hayward St, Cambridge, MA','+1-617-253-5646','mitpress@mit.edu');

INSERT INTO categories (name, description) VALUES
('Fiction',       'Novels and short story collections'),
('Science',       'Natural sciences and research'),
('History',       'World and regional history'),
('Technology',    'Computers, engineering and IT'),
('Biography',     'Life stories of notable individuals'),
('Philosophy',    'Philosophical works and essays'),
('Children',      'Books for young readers');

INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('George',   'Orwell',     '1903-06-25','British'),
('Yuval',    'Harari',     '1976-02-24','Israeli'),
('J.K.',     'Rowling',    '1965-07-31','British'),
('Isaac',    'Asimov',     '1920-01-02','American'),
('Toni',     'Morrison',   '1931-02-18','American'),
('Agatha',   'Christie',   '1890-09-15','British'),
('Stephen',  'Hawking',    '1942-01-08','British');

INSERT INTO books (isbn, title, author_id, publisher_id, category_id, publish_year, total_copies, shelf_location) VALUES
('978-0451524935','1984',                           1,1,1,1949,5,'A1'),
('978-0062316110','Sapiens',                        2,2,2,2015,4,'B3'),
('978-0439708180','Harry Potter and the Sorcerers Stone',3,1,1,1997,6,'A2'),
('978-0553293357','Foundation',                     4,4,1,1951,3,'A4'),
('978-0307268600','Beloved',                        5,1,1,1987,2,'A5'),
('978-0062350282','A Brief History of Time',        7,2,2,1988,4,'B1'),
('978-0062073488','And Then There Were None',       6,2,1,1939,3,'A3');

INSERT INTO book_copies (book_id, status, condition) VALUES
(1,'Available','Good'),(1,'Available','Good'),(1,'Loaned','Good'),(1,'Available','Fair'),(1,'Available','Good'),
(2,'Available','Good'),(2,'Loaned','Good'),(2,'Available','New'),(2,'Available','Good'),
(3,'Available','Good'),(3,'Available','Good'),(3,'Loaned','Good'),(3,'Available','Good'),(3,'Available','Fair'),(3,'Available','Good'),
(4,'Available','Good'),(4,'Available','Good'),(4,'Loaned','Old'),
(5,'Available','Good'),(5,'Loaned','Good'),
(6,'Available','New'),(6,'Available','Good'),(6,'Available','Good'),(6,'Loaned','Good'),
(7,'Available','Good'),(7,'Available','Good'),(7,'Loaned','Good');

INSERT INTO members (first_name, last_name, email, phone, membership_type) VALUES
('Alice',   'Johnson',  'alice.j@email.com',   '+1-555-1001','Premium'),
('Bob',     'Smith',    'bob.smith@email.com',  '+1-555-1002','Standard'),
('Carol',   'Williams', 'carol.w@email.com',    '+1-555-1003','Student'),
('David',   'Brown',    'david.b@email.com',    '+1-555-1004','Standard'),
('Emma',    'Davis',    'emma.d@email.com',     '+1-555-1005','Senior'),
('Frank',   'Miller',   'frank.m@email.com',    '+1-555-1006','Student'),
('Grace',   'Wilson',   'grace.w@email.com',    '+1-555-1007','Premium');

INSERT INTO staff (first_name, last_name, email, role, hire_date) VALUES
('Laura',  'Perez',   'laura.p@library.org',  'Head Librarian','2018-03-15'),
('Mark',   'Taylor',  'mark.t@library.org',   'Librarian',     '2020-06-01'),
('Sandra', 'Lee',     'sandra.l@library.org', 'Assistant',     '2022-09-10');

INSERT INTO loans (copy_id, member_id, staff_id, loan_date, due_date, return_date, status) VALUES
(3, 1, 1, CURRENT_DATE - 10, CURRENT_DATE + 4,  NULL,             'Active'),
(8, 2, 2, CURRENT_DATE - 20, CURRENT_DATE - 6,  NULL,             'Overdue'),
(12,3, 1, CURRENT_DATE - 5,  CURRENT_DATE + 9,  NULL,             'Active'),
(18,4, 3, CURRENT_DATE - 30, CURRENT_DATE - 16, CURRENT_DATE - 3, 'Returned'),
(20,5, 2, CURRENT_DATE - 3,  CURRENT_DATE + 11, NULL,             'Active'),
(24,6, 1, CURRENT_DATE - 25, CURRENT_DATE - 11, NULL,             'Overdue'),
(27,7, 3, CURRENT_DATE - 8,  CURRENT_DATE + 6,  NULL,             'Active');

INSERT INTO fines (loan_id, amount, issued_date, paid) VALUES
(2, 6.00,  CURRENT_DATE, FALSE),
(6, 11.00, CURRENT_DATE, FALSE);

-- ─────────────────────────────────────────────
--  VIEWS
-- ─────────────────────────────────────────────

CREATE OR REPLACE VIEW v_active_loans AS
SELECT
    l.loan_id,
    b.title,
    a.first_name || ' ' || a.last_name AS author,
    m.first_name || ' ' || m.last_name AS member,
    m.email AS member_email,
    l.loan_date,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue,
    l.status
FROM loans l
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b        ON bc.book_id = b.book_id
JOIN authors a      ON b.author_id = a.author_id
JOIN members m      ON l.member_id = m.member_id
WHERE l.status IN ('Active','Overdue');

CREATE OR REPLACE VIEW v_book_availability AS
SELECT
    b.book_id,
    b.title,
    a.first_name || ' ' || a.last_name AS author,
    c.name AS category,
    b.total_copies,
    COUNT(bc.copy_id) FILTER (WHERE bc.status = 'Available') AS available_copies,
    COUNT(bc.copy_id) FILTER (WHERE bc.status = 'Loaned')    AS loaned_copies
FROM books b
JOIN authors a     ON b.author_id = a.author_id
JOIN categories c  ON b.category_id = c.category_id
JOIN book_copies bc ON b.book_id = bc.book_id
GROUP BY b.book_id, b.title, a.first_name, a.last_name, c.name, b.total_copies;

CREATE OR REPLACE VIEW v_member_history AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_type,
    COUNT(l.loan_id)                           AS total_loans,
    COUNT(l.loan_id) FILTER (WHERE l.status='Active')   AS active_loans,
    COUNT(l.loan_id) FILTER (WHERE l.status='Overdue')  AS overdue_loans,
    COALESCE(SUM(f.amount) FILTER (WHERE NOT f.paid), 0) AS outstanding_fines
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id   = f.fine_id
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type;

-- ─────────────────────────────────────────────
--  STORED PROCEDURES / FUNCTIONS
-- ─────────────────────────────────────────────

-- Issue a book to a member
CREATE OR REPLACE FUNCTION issue_book(
    p_book_id   INT,
    p_member_id INT,
    p_staff_id  INT,
    p_days      INT DEFAULT 14
) RETURNS TEXT AS $$
DECLARE
    v_copy_id INT;
BEGIN
    SELECT copy_id INTO v_copy_id
    FROM book_copies
    WHERE book_id = p_book_id AND status = 'Available'
    LIMIT 1;

    IF v_copy_id IS NULL THEN
        RETURN 'ERROR: No available copy for this book.';
    END IF;

    INSERT INTO loans(copy_id, member_id, staff_id, loan_date, due_date)
    VALUES (v_copy_id, p_member_id, p_staff_id, CURRENT_DATE, CURRENT_DATE + p_days);

    UPDATE book_copies SET status = 'Loaned' WHERE copy_id = v_copy_id;

    RETURN 'SUCCESS: Book issued. Due date: ' || (CURRENT_DATE + p_days)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Return a book and auto-calculate fine
CREATE OR REPLACE FUNCTION return_book(p_loan_id INT) RETURNS TEXT AS $$
DECLARE
    v_due_date  DATE;
    v_copy_id   INT;
    v_overdue   INT;
    v_fine      NUMERIC(8,2);
BEGIN
    SELECT due_date, copy_id INTO v_due_date, v_copy_id
    FROM loans WHERE loan_id = p_loan_id;

    IF v_due_date IS NULL THEN
        RETURN 'ERROR: Loan not found.';
    END IF;

    UPDATE loans
    SET return_date = CURRENT_DATE,
        status = 'Returned'
    WHERE loan_id = p_loan_id;

    UPDATE book_copies SET status = 'Available' WHERE copy_id = v_copy_id;

    v_overdue := GREATEST(0, CURRENT_DATE - v_due_date);
    IF v_overdue > 0 THEN
        v_fine := v_overdue * 0.50;
        INSERT INTO fines(loan_id, amount) VALUES(p_loan_id, v_fine);
        RETURN 'Returned. Fine issued: $' || v_fine::TEXT || ' (' || v_overdue || ' days overdue)';
    END IF;

    RETURN 'Book returned successfully. No fines.';
END;
$$ LANGUAGE plpgsql;

-- ─────────────────────────────────────────────
--  SAMPLE QUERIES
-- ─────────────────────────────────────────────

-- 1. All currently active/overdue loans
-- SELECT * FROM v_active_loans;

-- 2. Book availability summary
-- SELECT * FROM v_book_availability;

-- 3. Members with outstanding fines
-- SELECT * FROM v_member_history WHERE outstanding_fines > 0;

-- 4. Most borrowed books
-- SELECT b.title, COUNT(l.loan_id) AS times_borrowed
-- FROM books b
-- JOIN book_copies bc ON b.book_id = bc.book_id
-- JOIN loans l        ON bc.copy_id = l.copy_id
-- GROUP BY b.title ORDER BY times_borrowed DESC;

-- 5. Issue a book  (book_id=2, member_id=3, staff_id=1, 14 days)
-- SELECT issue_book(2, 3, 1, 14);

-- 6. Return a book and check for fines
-- SELECT return_book(1);
