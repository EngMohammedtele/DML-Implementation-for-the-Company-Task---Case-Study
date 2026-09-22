
CREATE DATABASE CompanyTask;

USE CompanyTask;

--1) DDL
CREATE TABLE EMPLOYEE
(
    Ssn VARCHAR(9) PRIMARY KEY,
    Fname NVARCHAR(50) NOT NULL,
    Lname NVARCHAR(50) NOT NULL,
    Bdate DATE,
    Address NVARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    Super_ssn VARCHAR(9),
    FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn)
);

CREATE TABLE DEPARTMENT
(
    Dnumber INT PRIMARY KEY,
    Dname NVARCHAR(100) NOT NULL,
    Mgr_ssn VARCHAR(9),
    Mgr_start_date DATE,
    FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn)
);

CREATE TABLE DEPT_LOCATIONS
(
    Dnumber INT,
    Dlocation NVARCHAR(100),
    PRIMARY KEY (Dnumber, Dlocation),
    FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber)
);

CREATE TABLE PROJECT
(
    Pnumber INT PRIMARY KEY,
    Pname NVARCHAR(100) NOT NULL,
    Plocation NVARCHAR(100),
    Dnum INT,
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

CREATE TABLE WORKS_ON
(
    Essn VARCHAR(9),
    Pno INT,
    Hours DECIMAL(5,2),
    PRIMARY KEY (Essn, Pno),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
    FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber)
);

CREATE TABLE DEPENDENT
(
    Essn VARCHAR(9),
    Dependent_name NVARCHAR(50),
    Sex CHAR(1),
    Bdate DATE,
    Relationship NVARCHAR(20),
    PRIMARY KEY (Essn, Dependent_name),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn)
);

ALTER TABLE EMPLOYEE
ADD Dno INT FOREIGN KEY REFERENCES DEPARTMENT(Dnumber);


-- 2) DML
-- Task 1: INSERT
-- Insert employees first so the department managers already exist.
INSERT INTO EMPLOYEE (Ssn, Fname, Lname, Bdate, Address, Sex, Salary, Super_ssn)
VALUES ('888665555', 'James', 'Borg', '1937-11-10', '450 Stone, Houston TX', 'M', 55000, NULL);

INSERT INTO EMPLOYEE (Ssn, Fname, Lname, Bdate, Address, Sex, Salary, Super_ssn)
VALUES ('333445555', 'Franklin', 'Wong', '1955-12-08', '638 Voss, Houston TX', 'M', 40000, '888665555'),
       ('987654321', 'Jennifer', 'Wallace', '1941-06-20', '291 Berry, Bellaire TX', 'F', 43000, '888665555');

INSERT INTO EMPLOYEE (Ssn, Fname, Lname, Bdate, Address, Sex, Salary, Super_ssn)
VALUES ('123456789', 'John', 'Smith', '1965-01-09', '731 Fondren, Houston TX', 'M', 30000, '333445555'),
       ('999887777', 'Alicia', 'Zelaya', '1968-07-19', '3321 Castle, Spring TX', 'F', 25000, '987654321');

INSERT INTO DEPARTMENT (Dnumber, Dname, Mgr_ssn, Mgr_start_date)
VALUES (1, 'Headquarters', '888665555', '1981-06-19'),
       (2, 'Marketing', '987654321', '1998-01-01'),
       (3, 'Finance', '999887777', '2005-03-15'),
       (4, 'Administration', '987654321', '1995-01-01'),
       (5, 'Research', '333445555', '1988-05-22');

-- Set each employee's department now that the departments exist.
UPDATE EMPLOYEE SET Dno = 1 WHERE Ssn = '888665555';
UPDATE EMPLOYEE SET Dno = 5 WHERE Ssn = '333445555';
UPDATE EMPLOYEE SET Dno = 4 WHERE Ssn = '987654321';
UPDATE EMPLOYEE SET Dno = 5 WHERE Ssn = '123456789';
UPDATE EMPLOYEE SET Dno = 4 WHERE Ssn = '999887777';

INSERT INTO DEPT_LOCATIONS (Dnumber, Dlocation)
VALUES (1, 'Muscat'), (2, 'Dubai'), (3, 'Riyadh'), (4, 'Manama'), (5, 'Doha');

INSERT INTO PROJECT (Pnumber, Pname, Plocation, Dnum)
VALUES (1, 'ProductX', 'Muscat', 5),
       (2, 'ProductY', 'Dubai', 5),
       (3, 'ProductZ', 'Riyadh', 5),
       (10, 'Computerization', 'Manama', 4),
       (20, 'Reorganization', 'Doha', 1);

INSERT INTO WORKS_ON (Essn, Pno, Hours)
VALUES ('123456789', 1, 32.5),
       ('123456789', 2, 7.5),
       ('333445555', 2, 10.0),
       ('333445555', 3, 10.0),
       ('999887777', 10, 10.0);

INSERT INTO DEPENDENT (Essn, Dependent_name, Sex, Bdate, Relationship)
VALUES ('333445555', 'Alice', 'F', '1986-04-05', 'Daughter'),
       ('333445555', 'Theodore', 'M', '1983-10-25', 'Son'),
       ('333445555', 'Joy', 'F', '1958-05-03', 'Spouse'),
       ('987654321', 'Abner', 'M', '1942-02-28', 'Spouse'),
       ('123456789', 'Michael', 'M', '1988-01-04', 'Son');


-- Task 2: UPDATE
UPDATE EMPLOYEE
SET Salary = Salary * 1.10
WHERE Dno = 5;

UPDATE PROJECT
SET Plocation = 'Muscat'
WHERE Pnumber = 2;

UPDATE EMPLOYEE
SET Salary = 35000
WHERE Ssn = '123456789';

UPDATE DEPARTMENT
SET Dname = 'Financial Management'
WHERE Dnumber = 3;


-- Task 3: DELETE
DELETE FROM DEPENDENT
WHERE Dependent_name = 'Michael';

DELETE FROM WORKS_ON
WHERE Essn = '999887777' AND Pno = 10;

DELETE FROM PROJECT
WHERE Pnumber = 20;

DELETE FROM EMPLOYEE
WHERE Ssn = '123456789';


-- Task 4: Employee and department
SELECT e.Fname, e.Lname, d.Dname
FROM EMPLOYEE e
INNER JOIN DEPARTMENT d ON e.Dno = d.Dnumber;


-- Task 5: Employee, project and hours
SELECT e.Fname, e.Lname, p.Pname, w.Hours
FROM EMPLOYEE e
INNER JOIN WORKS_ON w ON e.Ssn = w.Essn
INNER JOIN PROJECT p ON w.Pno = p.Pnumber;
GO

-- Task 6: Department location
SELECT d.Dnumber, d.Dname, l.Dlocation
FROM DEPARTMENT d
INNER JOIN DEPT_LOCATIONS l ON d.Dnumber = l.Dnumber;


-- Task 7: Employee and dependent
SELECT e.Fname, e.Lname, x.Dependent_name, x.Relationship
FROM EMPLOYEE e
INNER JOIN DEPENDENT x ON e.Ssn = x.Essn;


-- Task 8: All employees, including employees without dependents
SELECT e.Ssn, e.Fname + ' ' + e.Lname AS Employee_Name,
       x.Dependent_name, x.Relationship
FROM EMPLOYEE e
LEFT JOIN DEPENDENT x ON e.Ssn = x.Essn;


-- Task 9: Employee, department, project and hours
SELECT e.Fname + ' ' + e.Lname AS Employee_Name,
       d.Dname, p.Pname, p.Plocation, w.Hours
FROM EMPLOYEE e
INNER JOIN DEPARTMENT d ON e.Dno = d.Dnumber
INNER JOIN WORKS_ON w ON e.Ssn = w.Essn
INNER JOIN PROJECT p ON w.Pno = p.Pnumber;


-- Task 10: Number of employees
SELECT COUNT(*) AS Employee_Count
FROM EMPLOYEE;


-- Task 11: Salary calculations
SELECT SUM(Salary) AS Total_Salary,
AVG(Salary) AS Average_Salary,
MIN(Salary) AS Minimum_Salary,
MAX(Salary) AS Maximum_Salary
FROM EMPLOYEE;


-- Task 12: Number of employees in each department
SELECT Dno, COUNT(*) AS Employee_Count
FROM EMPLOYEE
GROUP BY Dno;


-- Task 13: Total and average salary in each department
SELECT Dno, SUM(Salary) AS Total_Salary,
AVG(Salary) AS Average_Salary
FROM EMPLOYEE
GROUP BY Dno;


-- Task 14: Total hours for each project
SELECT Pno, SUM(Hours) AS Total_Hours
FROM WORKS_ON
GROUP BY Pno;


-- Task 15: Total hours for each employee
SELECT Essn, SUM(Hours) AS Total_Hours
FROM WORKS_ON
GROUP BY Essn;


-- Task 16: Salary analysis by department
SELECT d.Dname, COUNT(e.Ssn) AS Employee_Count,
SUM(e.Salary) AS Total_Salary,
AVG(e.Salary) AS Average_Salary
FROM DEPARTMENT d
INNER JOIN EMPLOYEE e ON d.Dnumber = e.Dno
GROUP BY d.Dname;


-- Task 17: Number of employees and hours by project
SELECT p.Pname, COUNT(w.Essn) AS Employee_Count,
SUM(w.Hours) AS Total_Hours,
AVG(w.Hours) AS Average_Hours
FROM PROJECT p
INNER JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY p.Pname;


-- Task 18: Number of projects and working hours by department
SELECT d.Dname, COUNT(DISTINCT p.Pnumber) AS Project_Count,
SUM(w.Hours) AS Total_Hours
FROM DEPARTMENT d
INNER JOIN PROJECT p ON d.Dnumber = p.Dnum
INNER JOIN WORKS_ON w ON p.Pnumber = w.Pno
GROUP BY d.Dname;


-- Task 19: Departments with an average salary above 30000
SELECT Dno, AVG(Salary) AS Average_Salary
FROM EMPLOYEE
GROUP BY Dno
HAVING AVG(Salary) > 30000;


-- Task 20: Projects with more than 15 total working hours
SELECT Pno, SUM(Hours) AS Total_Hours
FROM WORKS_ON
GROUP BY Pno
HAVING SUM(Hours) > 15;


-- Task 21: Departments with more than one employee
SELECT Dno, COUNT(*) AS Employee_Count
FROM EMPLOYEE
GROUP BY Dno
HAVING COUNT(*) > 1;

