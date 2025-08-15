-- 1. Create database
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

-- 2. Students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    contact_number VARCHAR(15)
);

-- 3. Books table with multiple copies
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1
);

-- 4. Borrow records
CREATE TABLE borrow_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 5. Sample students
INSERT INTO students (name, department, contact_number) VALUES
('Rahul Sharma', 'CSE', '9876543210'),
('Priya Verma', 'ECE', '9123456789'),
('Amit Singh', 'MECH', '9988776655'),
('Sneha Reddy', 'EEE', '9876123450'),
('Ravi Kumar', 'CIVIL', '9001122334'),
('Anjali Mehta', 'IT', '9088776655'),
('Karan Johar', 'CSE', '9776655443'),
('Pooja Gupta', 'ECE', '9445566778'),
('Arjun Nair', 'MECH', '9556677889'),
('Meera Iyer', 'EEE', '9223344556');

-- 6. Books with copies
INSERT INTO books (title, author, total_copies, available_copies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 5, 5),
('1984', 'George Orwell', 3, 3),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 10, 10),
('Pride and Prejudice', 'Jane Austen', 4, 4),
('The Catcher in the Rye', 'J.D. Salinger', 6, 6),
('The Hobbit', 'J.R.R. Tolkien', 8, 8),
('The Da Vinci Code', 'Dan Brown', 5, 5),
('A Brief History of Time', 'Stephen Hawking', 2, 2),
('The Alchemist', 'Paulo Coelho', 7, 7),
('Wings of Fire', 'A.P.J. Abdul Kalam', 6, 6);

-- 7. Borrow procedure
DELIMITER $$
CREATE PROCEDURE borrow_book(IN p_student_id INT, IN p_book_id INT)
BEGIN
    DECLARE available_count INT;
    DECLARE already_borrowed INT;

    -- Check student exists
    IF NOT EXISTS (SELECT 1 FROM students WHERE student_id = p_student_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    -- Get available copies
    SELECT available_copies INTO available_count
    FROM books
    WHERE book_id = p_book_id;

    IF available_count IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book does not exist';
    END IF;

    -- Check availability
    IF available_count <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No copies available';
    END IF;

    -- Check if already borrowed by this student
    SELECT COUNT(*) INTO already_borrowed
    FROM borrow_records
    WHERE student_id = p_student_id
      AND book_id = p_book_id
      AND return_date IS NULL;

    IF already_borrowed > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student already borrowed this book and has not returned it';
    END IF;

    -- Decrease available copies
    UPDATE books
    SET available_copies = available_copies - 1
    WHERE book_id = p_book_id;

    -- Insert borrow record
    INSERT INTO borrow_records (student_id, book_id, borrow_date, due_date)
    VALUES (p_student_id, p_book_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
END$$
DELIMITER ;

-- 8. Return procedure
DELIMITER $$
CREATE PROCEDURE return_book(IN p_record_id INT)
BEGIN
    DECLARE late_days INT;
    DECLARE book_id_val INT;

    -- Update return date
    UPDATE borrow_records
    SET return_date = CURDATE()
    WHERE record_id = p_record_id
      AND return_date IS NULL;

    -- Get book ID for updating copies
    SELECT book_id INTO book_id_val
    FROM borrow_records
    WHERE record_id = p_record_id;

    -- Increase available copies
    UPDATE books
    SET available_copies = available_copies + 1
    WHERE book_id = book_id_val;

    -- Calculate fine
    SELECT DATEDIFF(return_date, due_date) INTO late_days
    FROM borrow_records
    WHERE record_id = p_record_id;

    IF late_days > 0 THEN
        UPDATE borrow_records
        SET fine = late_days * 5
        WHERE record_id = p_record_id;
    END IF;
END$$
DELIMITER ;

-- ✅ Example Usage of borrow_book and return_book (Highly Mixed Order)

-- Rahul borrows first
CALL borrow_book(1, 1);       

-- Priya borrows one
CALL borrow_book(2, 2);       

-- Amit borrows
CALL borrow_book(3, 3);       

-- Sneha borrows
CALL borrow_book(4, 7);       

-- Rahul returns
CALL return_book(1);          

-- Ravi borrows two back-to-back
CALL borrow_book(5, 8);       
CALL borrow_book(5, 9);       

-- Priya borrows again before returning previous
CALL borrow_book(2, 4);       

-- Sneha returns
CALL return_book(4);          

-- Amit borrows again
CALL borrow_book(3, 6);       

-- Ravi returns one
CALL return_book(5);          

-- Anjali borrows
CALL borrow_book(6, 10);      

-- Priya returns one book
CALL return_book(2);          

-- Priya borrows again
CALL borrow_book(2, 5);       

-- Ravi returns second book
CALL return_book(5);          


-- ❌ Failing Test Cases (Error Handling) --

-- 1. Borrow a non-existent book (Expected: ERROR 'Book does not exist')
-- CALL borrow_book(1, 999);  

-- 2. Borrow with a non-existent student (Expected: ERROR 'Student does not exist')
-- CALL borrow_book(999, 1);  

-- 3. Borrow a book that is already borrowed and unavailable (Expected: ERROR 'Book is not available')
-- CALL borrow_book(2, 2); 
-- CALL borrow_book(3, 2); 

-- 4. Borrow the same book twice without returning' (Expected: ERROR 'Student already borrowed this book and has not returned it')
-- CALL borrow_book(1, 4);  
-- CALL borrow_book(1, 4);  

-- 5. Return a book when the student has no borrowed books (Expected: ERROR 'No borrowed books found for this student')
-- CALL return_book(4);  


-- View borrow history
SELECT r.record_id, s.name AS student_name, b.title, r.borrow_date, r.due_date, r.return_date, r.fine
FROM borrow_records r
JOIN books b ON r.book_id = b.book_id
JOIN students s ON r.student_id = s.student_id;

-- View Students with fine
SELECT br.record_id , s.name as student_name, b.title , br.borrow_date ,br.due_date, br.return_date,br.fine
FROM borrow_records br
JOIN students S ON s.student_id=br.student_id
JOIN books b ON b.book_id=br.book_id
WHERE br.fine>0