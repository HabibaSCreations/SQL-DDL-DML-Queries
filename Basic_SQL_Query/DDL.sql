
-- ???????? ???? ??? ????
USE master;
GO
IF DB_ID('TSPDB') IS NOT NULL
BEGIN
    ALTER DATABASE TSPDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TSPDB;
END
GO

CREATE DATABASE TSPDB
ON(
    NAME='TSPDB_Data_1',
    FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\TSPDB_Data_1.mdf',
    SIZE=25MB,
    MAXSIZE=100MB,
    FILEGROWTH=5%
)
LOG ON(
    NAME='TSPDB_Log_1',
    FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\TSPDB_Log_1.ldf',
    SIZE=2MB,
    MAXSIZE=25MB,
    FILEGROWTH=1%
);
GO

USE TSPDB;
GO

-- ????? ????
CREATE TABLE TSP (
    TSPId INT PRIMARY KEY NOT NULL,
    TSPName VARCHAR(7) NOT NULL
);
GO

CREATE TABLE Course (
    CourseID INT PRIMARY KEY NOT NULL,
    CourseName VARCHAR(25) NOT NULL
);
GO

CREATE TABLE Module (
    ModuleID INT PRIMARY KEY NOT NULL,
    ModuleName VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Student (
    StudentID INT PRIMARY KEY NOT NULL,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(10),
    TSPID INT NOT NULL REFERENCES TSP(TSPID),
    CourseID INT NOT NULL REFERENCES Course(CourseID),
    ModuleID INT NOT NULL REFERENCES Module(ModuleID)
);
GO

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY NOT NULL,
    FirstName VARCHAR(10) NOT NULL,
    LastName VARCHAR(6) NOT NULL,
    FAddress VARCHAR(25) NOT NULL,
    City VARCHAR(20) NOT NULL,
    States VARCHAR(10) NOT NULL
);
GO

CREATE TABLE Relation (
    RelationID INT PRIMARY KEY NOT NULL,
    Duration INT NOT NULL,
    StudentID INT NOT NULL REFERENCES Student(StudentID),
    FacultyID INT NOT NULL REFERENCES Faculty(FacultyID),
    AdmissionDate DATE NOT NULL
);
GO

-- Stored Procedure
CREATE PROC spSelectInsertUpdateDeleteOutputReturn
    @operation INT = 0,
    @StudentID INT = NULL,
    @FirstName VARCHAR(30) = NULL,
    @TSPID INT = NULL,
    @CourseID INT = NULL,
    @ModuleID INT = NULL,
    @name VARCHAR(20) OUTPUT,
    @retCOUNT INT OUTPUT
AS
BEGIN
    IF @operation = 1
    BEGIN
        SELECT StudentId, FirstName, LastName FROM Student;
    END
    ELSE IF @operation = 2
    BEGIN
        BEGIN TRY
            BEGIN TRAN
            INSERT INTO Student (StudentID, FirstName, LastName, TSPID, CourseID, ModuleID)
            VALUES (@StudentID, @FirstName, '', @TSPID, @CourseID, @ModuleID);
            COMMIT TRAN
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN
            SELECT ERROR_MESSAGE() AS ErrMessage, ERROR_NUMBER() AS ErrNumber;
        END CATCH
    END
    ELSE IF @operation = 3
    BEGIN
        UPDATE Student SET FirstName = @FirstName WHERE StudentID = @StudentID;
    END
    ELSE IF @operation = 4
    BEGIN
        DELETE FROM Student WHERE StudentID = @StudentID;
    END
    ELSE IF @operation = 5
    BEGIN
        SELECT @name = FirstName FROM Student WHERE StudentID = @StudentID;
    END
    ELSE IF @operation = 6
    BEGIN
        SELECT @retCOUNT = COUNT(*) FROM Student WHERE FirstName = @FirstName;
        RETURN @retCOUNT;
    END
END;
GO

-- Procedure Calling
DECLARE @outputName VARCHAR(20), @outputCount INT;

EXEC spSelectInsertUpdateDeleteOutputReturn
    @operation = 2,
    @StudentID = 101,
    @FirstName = 'Habiba',
    @TSPID = 1,
    @CourseID = 1,
    @ModuleID = 1,
    @name = @outputName OUTPUT,
    @retCOUNT = @outputCount OUTPUT;
GO

-- View
CREATE VIEW vu_InvInfoWithDuR
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT S.StudentID, S.FirstName, R.Duration, R.AdmissionDate
FROM dbo.Relation R
JOIN dbo.Student S ON R.StudentID = S.StudentID
WHERE R.Duration > 300;
GO

-- Calling View
SELECT * FROM vu_InvInfoWithDuR;
GO

-- Scalar Function
CREATE FUNCTION GetFirstName (@StudentID INT)
RETURNS VARCHAR(40)
AS
BEGIN
    DECLARE @Result VARCHAR(40);
    SELECT @Result = FirstName FROM Student WHERE StudentID = @StudentID;
    RETURN @Result;
END;
GO

-- Calling Scalar Function
SELECT dbo.GetFirstName(101) AS FirstName;
GO

-- Table-Valued Function
CREATE FUNCTION GetFacultyInfoByState (@state CHAR(2))
RETURNS TABLE
AS
RETURN
    SELECT FirstName, City, States FROM Faculty WHERE States = @state;
GO

-- Calling Table-Valued Function
SELECT * FROM GetFacultyInfoByState('NY');
GO

-- Multi-statement Table-valued Function
CREATE FUNCTION fnMultistatement(@Amount INT)
RETURNS @durTable TABLE (
    StudentID INT,
    AdmissionDate DATE,
    Duration INT
)
AS
BEGIN
    INSERT INTO @durTable
    SELECT StudentID, AdmissionDate, Duration
    FROM Relation
    WHERE Duration >= @Amount;
    RETURN;
END;
GO

-- Calling multi-statement function
SELECT * FROM fnMultistatement(150);
GO

-- Trigger (INSTEAD OF BULK DELETE/UPDATE PREVENTION)
CREATE TRIGGER tr_PreventBulkDataUpdateDelete
ON Student
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    IF (SELECT COUNT(*) FROM deleted) > 1 OR (SELECT COUNT(*) FROM inserted) > 1
    BEGIN
        RAISERROR('BULK UPDATE OR DELETE IS NOT ALLOWED', 16, 1);
    END
END;
GO
