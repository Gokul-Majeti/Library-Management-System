# 📚 Library Management System (MySQL + Stored Procedures)

A MySQL-based Library Management System that enables students to **borrow** and **return** books, with **automatic fine calculation** for late returns. The system ensures **data integrity**, provides **error handling**, and allows tracking of **overdue books and fines**.

---

## 🚀 Features

* ✅ **Borrow books** with availability checks
* ✅ **Return books** with late fine calculation
* ✅ **Prevent duplicate borrowing** of the same book without return
* ✅ **Error handling** for invalid student/book IDs
* ✅ **Track overdue books and fines** with SQL queries
* ✅ **Multiple test cases** for both valid and invalid scenarios

---

## 🛠️ Technologies Used

* **Database**: MySQL
* **Language**: SQL (Stored Procedures)
* **Tool**: MySQL Workbench

---

## 📂 Database Structure

### Tables

* `students` – Stores student details
* `books` – Stores book details with total and available copies
* `borrow_records` – Tracks borrow and return transactions with fines

### ER Diagram

*(Can be generated in MySQL Workbench using the Reverse Engineer feature)*

---

## ⚡ Stored Procedures

### `borrow_book(student_id, book_id)`

* Verifies student and book existence
* Ensures book availability
* Prevents borrowing the same book twice without return
* Inserts borrow date and due date

### `return_book(student_id)`

* Retrieves borrowed books for the student
* Calculates and updates fines if overdue
* Updates available book count

---

## 📜 Example Usage

```sql
-- Student 1 borrows and returns
CALL borrow_book(1, 1);
CALL return_book(1);

-- Student 2 borrows multiple books and returns some
CALL borrow_book(2, 2);
CALL borrow_book(2, 4);
CALL return_book(2);
CALL borrow_book(2, 5);

-- Student 3 borrows a book
CALL borrow_book(3, 3);

-- Invalid operation: Borrow a non-existent book
CALL borrow_book(1, 999);
```

---

## 📌 Additional Queries

```sql
-- Students with pending fines
SELECT br.record_id, s.name AS student_name, b.title, br.borrow_date, br.due_date, br.return_date, br.fine
FROM borrow_records br
JOIN students s ON s.student_id = br.student_id
JOIN books b ON b.book_id = br.book_id
WHERE br.fine > 0;
```
