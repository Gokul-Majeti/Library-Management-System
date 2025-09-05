# 📚 Library Management System (MYSQL)

A MySQL-based Library Management System that enables students to **borrow** and **return** books, with **automatic fine calculation** for late returns. The system ensures **data integrity**, provides **error handling**, and allows tracking of **overdue books and fines**.

---

## 🚀 Features

* ✅ **Borrow books** with availability checks
* ✅ **Return books** with late fine calculation
* ✅ **Prevent duplicate borrowing** of the same book without return
* ✅ **Error handling** for invalid student/book IDs
* ✅ **Track overdue books and fines** with SQL queries

---

## 🛠️ Technologies Used

* **Database**: MySQL
* **Language**: SQL 


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

