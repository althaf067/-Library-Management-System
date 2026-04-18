**Library Management System**

File: library-management/library_management.sql


**Schema**

publishers → books ← authors
                ↓                
           book_copies           
                ↓                
members → loans → fines

staff  ───↑

**Tables**

Table               Purpose

publishers:          Book publishers

categories:          Book genres/categories

authors:             Author registry

books:               Book catalog with ISBN

book_copies:         Individual physical copies with status

members:             Library members (Standard/Premium/Student/Senior)

staff:               Librarians and assistants

loans:               Borrow records with due dates

fines:               Auto-generated overdue fines

**Key Features**

● issue_book(book_id, member_id, staff_id, days) — Finds available copy, creates loan, marks copy as Loaned

● return_book(loan_id) — Marks return, frees copy, calculates fine at ₹0.50/day

● Views: v_active_loans, v_book_availability, v_member_history

**Sample Queries**

**-- Check book availability --**
SELECT * FROM v_book_availability;

**-- Members with pending fines --**
SELECT * FROM v_member_history WHERE outstanding_fines > 0;

**-- Issue a book --**
SELECT issue_book(2, 3, 1, 14);

**-- Return and auto-fine --**
SELECT return_book(2);
