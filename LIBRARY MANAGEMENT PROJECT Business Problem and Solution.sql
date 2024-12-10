SELECT * FROM books;

SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


-- -------------------------Problem Statement ---------------------------------------------------

-- 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"


INSERT INTO books(isbn,book_title, category, rental_price, status,author,publisher)
VALUES 
	( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
);

SELECT * FROM books;



-- 2. Update an existing Member's Address "125 Main St"

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members;


-- 3. Delete a Record from the Issued Status Table -- 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;
SELECT * FROM return_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121'


--4. Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status;

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'


-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT * FROM members;

SELECT 
	issued_emp_id,
	COUNT(issued_id) AS total_book_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(issued_id) > 1;


-- 6: Create Summary Tables: 
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**


CREATE TABLE book_cnt 
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

select *FROM book_cnt;

-- 7. Retrieve All Books in a Classic Category:

SELECT * 
FROM books
WHERE category = 'Classic';

SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- 8: Find Total Rental Income by Category

SELECT 
	DISTINCT(category)
FROM books;

SELECT 
	b.category,
	SUM (b.rental_price),
	COUNT(*)
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;


-- 9. List Members Who Registered in the Last 180 Days:


SELECT * FROM books;

INSERT INTO members(member_id, member_name,member_address,reg_date)
VALUES 
	('C118','san','145 Main St', '2024-06-01'),
	('C119','john','133 Main St', '2024-05-01');
SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';


-- 10. List Employees with Their Branch Manager's Name and their branch details:

SELECT * FROM branch;

SELECT 
	emp1.*,
	b.branch_id,
	emp2.emp_name AS manager
FROM employees AS emp1
JOIN branch AS b
ON emp1.branch_id = b.branch_id
JOIN employees AS emp2
ON emp2.emp_id = b.manager_id;


-- 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 usd:

CREATE TABLE books_price_greater_seven
AS
SELECT * 
FROM books
WHERE rental_price > 7;

SELECT *
FROM books_price_greater_seven


-- 12. Retrieve the List of Books Not Yet Returned
SELECT * FROM members;
SELECT * FROM branch;
SELECT * FROM employees;

SELECT 
	DISTINCT ist.issued_book_name 
FROM issued_status AS ist
LEFT JOIN return_status AS rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL;


-- -----------------------------------------------------------------------------------------------------
-- -----------------------------ADVANCE BUSINESS PROBLEM -----------------------------------------

/*
13. 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members ==books ==return_status	
-- filter boks which is return
-- overdue > 30

SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

SELECT 
	ist.issued_member_id, 
	m.member_name,
	bk.book_title,
	ist.issued_date,
	-- rs.return_date,
	CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status AS ist
JOIN members AS m
	ON m.member_id =ist.issued_book_name 
JOIN books AS bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
		AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

/*    
14. Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

SELECT * 
FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';


SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2'

SELECT * 
FROM return_status
where issued_id = 'IS130';


INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
VALUES
	('RS125','IS130',current_date,'Good');

SELECT * 
FROM return_status
where issued_id = 'IS130';

-- ----------------store Procedure----------------------------------


CREATE OR REPLACE PROCEDURE PROC_add_return_records(IN_return_id VARCHAR(10), IN_issued_id VARCHAR(10),IN_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	var_isbn varchar(50);
	var_book_name varchar(80);
BEGIN
	-- all your loic and code
	-- insert base on user input
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	VALUES
	(IN_return_id, IN_issued_id,CURRENT_DATE,IN_book_quality);

	
	SELECT 
		issued_book_isbn,
		issued_book_name
		into 
		var_isbn,
		var_book_name
	FROM issued_status
	WHERE issued_id = IN_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = var_isbn;


	RAISE NOTICE 'Thank you for returning the book: %', var_book_name ;
END;
$$


-- TESTING 

SELECT * 
FROM books
WHERE isbn ='978-0-307-58837-1' ;

SELECT * 
FROM issued_status
WHERE issued_id = 'IS135';

SELECT * 
FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';


SELECT * 
FROM return_status
WHERE issued_id = 'IS135';

DELETE FROM return_status
WHERE issued_id = 'IS135';


-- CALLING fUCTION
CALL PROC_add_return_records('RS138','IS135','Good');

SELECT * 
FROM books
WHERE isbn ='978-0-330-25864-8'
	
UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8';	

/*
15. Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

CREATE TABLE branch_reports 
as
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_book_issued,
	COUNT(rs.return_id) AS number_of_book_return,
	SUM(bk.rental_price) AS total_revenue
FROM issued_status as ist
JOIN employees AS e
	ON e.emp_id = ist.issued_emp_id
JOIN branch as b
	ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
JOIN books as bk
	ON ist.issued_book_isbn = bk.isbn
GROUP BY 1,2;





/* 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


CREATE TABLE active_members 
AS
SELECT * 
FROM members
WHERE member_id IN (SELECT 
						DISTINCT issued_member_id 
					FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month');


select *
from active_members;
 /*
 17. Find Employees with the Most Book Issues Processed
 Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/
 
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e
	ON e.emp_id = ist.issued_emp_id
JOIN branch as b
	ON e.branch_id = b.branch_id
GROUP BY 1,2
;

/*
18 Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.
*/





/*
19 Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

SELECT * FROM books;

SELECT * FROM issued_status;

-- ---------------------------
CREATE OR REPLACE PROCEDURE PROC_issue_book(IN_issued_id VARCHAR(10), IN_issued_member_id VARCHAR(30), IN_issued_book_isbn VARCHAR(30),IN_issued_emp_id VARCHAR(30))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variable
	v_status VARCHAR (10);

BEGIN
-- all the code
	--checking if the book is available 'yes'
	SELECT 
		status
		INTO
		v_status
	FROM books
	WHERE isbn = IN_issued_book_isbn;

	IF v_status = 'yes' THEN

		INSERT INTO issued_status (issued_id, issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
	
		VALUES
			(IN_issued_id,IN_issued_member_id,CURRENT_DATE,IN_issued_book_isbn );

		UPDATE books
		SET status = 'no'
		WHERE isbn = IN_issued_book_isbn;
		

		RAISE NOTICE 'Book records added sucessfully for book_isbn : %', IN_issued_book_isbn;

	ELSE
		RAISE NOTICE 'Sorry you have requested is unavalable book_isbn : %', IN_issued_book_isbn;
	END IF;

END;
$$


-- TESTING
-- CALLING THE STORE PROCEDURE
SELECT * FROM books;

CALL PROC_issue_book ('IS155','C108','978-0-553-29698-2','E104');

CALL PROC_issue_book ('IS156','C108','978-0-375-41398-8','E104');

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';
/*
20. Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
*/



















