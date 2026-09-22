
USE master;
GO

IF DB_ID(N'CompanyDB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE CompanyDB');
END;
GO

-- Keep USE and all table operations in the same batch.
USE CompanyDB;

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.DEPARTMENT', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.DEPARTMENT (
            Department_No   INT NOT NULL,
            Department_Name NVARCHAR(100) NOT NULL,
            Manager_SSN     VARCHAR(20) NOT NULL,
            Hire_Date       DATE NULL,

            CONSTRAINT PK_DEPARTMENT
                PRIMARY KEY (Department_No),

            CONSTRAINT UQ_DEPARTMENT_MANAGER
                UNIQUE (Manager_SSN)
        );
    END;

    IF OBJECT_ID(N'dbo.EMPLOYEE', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.EMPLOYEE (
            SSN             VARCHAR(20) NOT NULL,
            First_Name      NVARCHAR(50) NOT NULL,
            Last_Name       NVARCHAR(50) NOT NULL,
            Gender          NVARCHAR(20) NULL,
            Birth_Date      DATE NULL,
            Department_No   INT NOT NULL,
            Supervisor_SSN  VARCHAR(20) NULL,

            CONSTRAINT PK_EMPLOYEE
                PRIMARY KEY (SSN),

            CONSTRAINT FK_EMPLOYEE_DEPARTMENT
                FOREIGN KEY (Department_No)
                REFERENCES dbo.DEPARTMENT (Department_No),

            CONSTRAINT FK_EMPLOYEE_SUPERVISOR
                FOREIGN KEY (Supervisor_SSN)
                REFERENCES dbo.EMPLOYEE (SSN)
        );
    END;

    IF OBJECT_ID(N'dbo.DEPARTMENT_LOCATIONS', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.DEPARTMENT_LOCATIONS (
            Department_No INT NOT NULL,
            Location      NVARCHAR(150) NOT NULL,

            CONSTRAINT PK_DEPARTMENT_LOCATIONS
                PRIMARY KEY (Department_No, Location),

            CONSTRAINT FK_LOCATIONS_DEPARTMENT
                FOREIGN KEY (Department_No)
                REFERENCES dbo.DEPARTMENT (Department_No)
        );
    END;

    IF OBJECT_ID(N'dbo.PROJECT', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.PROJECT (
            Project_No    INT NOT NULL,
            Project_Name  NVARCHAR(100) NOT NULL,
            City          NVARCHAR(100) NULL,
            Location      NVARCHAR(150) NULL,
            Department_No INT NOT NULL,

            CONSTRAINT PK_PROJECT
                PRIMARY KEY (Project_No),

            CONSTRAINT FK_PROJECT_DEPARTMENT
                FOREIGN KEY (Department_No)
                REFERENCES dbo.DEPARTMENT (Department_No)
        );
    END;

    IF OBJECT_ID(N'dbo.DEPENDENT', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.DEPENDENT (
            Employee_SSN   VARCHAR(20) NOT NULL,
            Dependent_Name NVARCHAR(100) NOT NULL,
            Gender         NVARCHAR(20) NULL,
            Birth_Date     DATE NULL,

            CONSTRAINT PK_DEPENDENT
                PRIMARY KEY (Employee_SSN, Dependent_Name),

            CONSTRAINT FK_DEPENDENT_EMPLOYEE
                FOREIGN KEY (Employee_SSN)
                REFERENCES dbo.EMPLOYEE (SSN)
        );
    END;

    IF OBJECT_ID(N'dbo.WORKS_ON', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.WORKS_ON (
            Employee_SSN  VARCHAR(20) NOT NULL,
            Project_No    INT NOT NULL,
            Working_Hours DECIMAL(7, 2) NOT NULL,

            CONSTRAINT PK_WORKS_ON
                PRIMARY KEY (Employee_SSN, Project_No),

            CONSTRAINT FK_WORKS_ON_EMPLOYEE
                FOREIGN KEY (Employee_SSN)
                REFERENCES dbo.EMPLOYEE (SSN),

            CONSTRAINT FK_WORKS_ON_PROJECT
                FOREIGN KEY (Project_No)
                REFERENCES dbo.PROJECT (Project_No),

            CONSTRAINT CK_WORKS_ON_HOURS
                CHECK (Working_Hours >= 0)
        );
    END;

    -- Add the manager FK only when it does not already exist.
    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_DEPARTMENT_MANAGER'
          AND parent_object_id = OBJECT_ID(N'dbo.DEPARTMENT', N'U')
    )
    BEGIN
        ALTER TABLE dbo.DEPARTMENT WITH CHECK
        ADD CONSTRAINT FK_DEPARTMENT_MANAGER
            FOREIGN KEY (Manager_SSN)
            REFERENCES dbo.EMPLOYEE (SSN);

    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
