
USE TSPDB;
GO

-- Top 5 Students --
SELECT TOP 5 StudentId, FirstName, LastName FROM student
ORDER BY StudentId DESC;

-- Students with Admission Date after 2023-01-13 --
SELECT FacultyId, StudentId, Admisiondate FROM Relation
WHERE Admisiondate > '2023-01-13';

-- Join Query --
SELECT S.StudentId, S.FirstName, Admisiondate 
FROM student AS S 
JOIN Relation AS R ON S.StudentId = R.StudentId
WHERE (S.FirstName NOT IN ('C#') AND Admisiondate > '2023-01-13');

-- Between and AND Operation --
SELECT StudentId, FacultyId, Duration FROM Relation
WHERE AdmisionDate BETWEEN '2023-01-13' AND '2023-02-02';

-- Like (Starts with A) --
SELECT FirstName, StudentId FROM student
WHERE FirstName LIKE 'A%';

-- Like (Starts with Vowel) --
SELECT StudentId, FirstName FROM student 
WHERE FirstName LIKE '[AEIOU]%';

-- Like Range --
SELECT StudentId, FirstName FROM student 
WHERE FirstName LIKE 'N[A-J]%';

-- Like Not in Range --
SELECT StudentId, FirstName FROM student 
WHERE FirstName LIKE 'N[^K-Y]%';

-- Offset-Fetch --
SELECT StudentId, FirstName, LastName FROM student
ORDER BY StudentId
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- Aggregate Function --
SELECT RelationId, StudentId, FacultyId, AVG(Duration) AS AVGduration 
FROM Relation
GROUP BY RelationId, StudentId, FacultyId
HAVING AVG(Duration) > 300;

-- Rollup Operator --
SELECT StudentId, FirstName, LastName, COUNT(*) AS countstudent 
FROM student
GROUP BY ROLLUP (StudentId, FirstName, LastName);

-- Cube Operator --
SELECT StudentId, FirstName, LastName, COUNT(*) AS countstudent 
FROM student
GROUP BY CUBE (StudentId, FirstName, LastName);

-- Grouping Sets Operator --
SELECT Firstname, LastName, COUNT(*) AS studentcount
FROM student
WHERE LastName IN ('IA', 'NJ')
GROUP BY GROUPING SETS (StudentId, Firstname, LastName)
ORDER BY Firstname DESC, LastName DESC;

-- OVER Clause --
SELECT RelationId, FacultyId, StudentId,
SUM(Duration) OVER (PARTITION BY AdmisionDate) AS SumDuration,
AVG(Duration) OVER (PARTITION BY AdmisionDate) AS AvgDuration
FROM Relation;

-- Subquery --
SELECT StudentId, FirstName, LastName FROM student
WHERE StudentId IN (SELECT StudentId FROM student)
ORDER BY FirstName;

-- ANY Operator --
SELECT StudentId, FacultyId, Duration, Admisiondate FROM Relation
WHERE Duration > ANY (SELECT Duration FROM Relation WHERE StudentId = 306);

-- ALL Operator --
SELECT StudentId, FacultyId, Duration, Admisiondate FROM Relation
WHERE Duration > ALL (SELECT Duration FROM Relation WHERE StudentId = 306);

-- SOME Operator --
SELECT StudentId, FacultyId, Duration, Admisiondate FROM Relation
WHERE Duration > SOME (SELECT Duration FROM Relation WHERE StudentId = 306);

-- EXISTS Operator --
SELECT StudentId, FacultyId, Duration FROM Relation 
WHERE EXISTS (
    SELECT * FROM student 
    WHERE student.StudentId = Relation.StudentId
);

-- Common Table Expression (CTE) --
;WITH summary AS (
    SELECT S.StudentId, S.FirstName, SUM(Duration) AS sumdura 
    FROM Relation AS R 
    JOIN student AS S ON R.StudentId = S.StudentId
    GROUP BY S.StudentId, S.FirstName
),
toprel AS (
    SELECT S.StudentId, S.FirstName, MAX(sumdura) AS maxdura 
    FROM summary AS S 
    GROUP BY S.StudentId, S.FirstName
)
SELECT S.StudentId, S.FirstName, maxdura 
FROM summary AS S 
JOIN toprel AS t ON S.FirstName = t.FirstName;

-- Insert Into --
INSERT INTO Course(CourseId, CourseName)
VALUES ('106', 'CF');

-- Delete From --
DELETE FROM Course WHERE CourseId = '106';

-- Select Into --
-- Use only if 'course' does not exist already
-- SELECT * INTO course FROM Relation;

-- CAST Function --
SELECT Admisiondate, StudentId, Duration,
CAST(Admisiondate AS VARCHAR) AS strInvDate,
CAST(StudentId AS INT) AS strInvToatl,
CAST(Duration AS INT) AS intInvToatl
FROM Relation;

-- CONVERT Function --
SELECT Admisiondate, Duration,
CONVERT(VARCHAR, Admisiondate) AS strInvDate,
CONVERT(VARCHAR, Admisiondate, 1) AS strInvDate1,
CONVERT(VARCHAR, Admisiondate, 107) AS strInvDate2,
CONVERT(VARCHAR, Admisiondate) AS strInvTotal1,
CONVERT(VARCHAR, Admisiondate, 1) AS strInvTotal2
FROM Relation;

-- TRY_CONVERT Function --
SELECT Admisiondate, Duration,
TRY_CONVERT(VARCHAR, Admisiondate) AS strInvDate,
TRY_CONVERT(VARCHAR, Admisiondate, 1) AS strInvDate1,
TRY_CONVERT(VARCHAR, Admisiondate, 107) AS strInvDate2,
TRY_CONVERT(VARCHAR, Duration) AS strInvTotal1,
TRY_CONVERT(VARCHAR, Duration, 1) AS strInvTotal2,
TRY_CONVERT(DATE, 'Feb 29 2018') AS InvalidDate
FROM Relation;

-- DATEDIFF Function --
SELECT StudentId, Admisiondate, Duration, GETDATE() AS CurrentDate,
DATEDIFF(DAY, Admisiondate, GETDATE()) AS DayDiff,
DATEDIFF(MONTH, Admisiondate, GETDATE()) AS MonthDiff,
DATEDIFF(YEAR, Admisiondate, GETDATE()) AS YearDiff
FROM Relation;

-- DATEADD Function --
SELECT StudentId, Admisiondate, Duration,
DATEADD(MONTH, 1, Admisiondate) AS NewAddDate,
DATEADD(MONTH, -1, Admisiondate) AS NewSubtractDate
FROM Relation;

-- CASE Statement --
SELECT StudentId, FirstName,
CASE StudentId
    WHEN 1 THEN '10 days'
    WHEN 2 THEN '20 days'
    WHEN 3 THEN '30 days'
    ELSE 'Other'
END AS sdescription
FROM student;

-- Search CASE --
SELECT StudentId, Admisiondate,
CASE
    WHEN DATEDIFF(YEAR, Admisiondate, GETDATE()) > 4 THEN 'Over 4 Years'
    WHEN DATEDIFF(YEAR, Admisiondate, GETDATE()) > 0 THEN 'Over 1 Years to 4 years'
    ELSE 'Current'
END AS dateStatus
FROM Relation;

-- IIF Function --
SELECT StudentId, SUM(Duration) AS durTotal,
IIF(SUM(Duration) > 1000, 'High', 'Low') AS InvRange
FROM Relation
GROUP BY StudentId
ORDER BY SUM(Duration) DESC;

-- CHOOSE Function --
SELECT StudentId, Duration, FacultyId,
CHOOSE(FacultyId, '10 days', '20 days', '30 days', '60 days', '90 days') AS NetDuration
FROM Relation;

-- ISNULL Function --
SELECT StudentId, Admisiondate,
ISNULL(Admisiondate, '2023-01-13') AS NewDate 
FROM Relation
WHERE Admisiondate IS NULL;

-- COALESCE Function --
SELECT S.StudentId, R.Duration,
COALESCE(CAST(R.Duration AS VARCHAR), 'No Invoice') AS InvStatus
FROM Relation R 
RIGHT JOIN student S ON R.StudentId = S.StudentId;

-- Ranking Functions --
SELECT StudentId, ROW_NUMBER() OVER (ORDER BY FirstName) AS RowNumber, FirstName FROM student;

SELECT StudentId, FacultyId, Duration,
RANK() OVER (ORDER BY Duration DESC) AS RankNo FROM Relation;

SELECT StudentId, FacultyId, Duration,
DENSE_RANK() OVER (ORDER BY Duration) AS DenseRankNo FROM Relation;

SELECT CourseName,
NTILE(2) OVER (ORDER BY CourseID) AS Tile2,
NTILE(3) OVER (ORDER BY CourseID) AS Tile3,
NTILE(4) OVER (ORDER BY CourseID) AS Tile4,
NTILE(5) OVER (ORDER BY CourseID) AS Tile5
FROM Course;

SELECT StudentId, FacultyId, Admisiondate,
FIRST_VALUE(Duration) OVER (PARTITION BY StudentId ORDER BY Admisiondate) AS FirstValue
FROM Relation;

SELECT StudentId, Duration, FacultyId, Admisiondate,
LAST_VALUE(Duration) OVER (PARTITION BY StudentId ORDER BY Admisiondate DESC) AS LastValue
FROM Relation;

SELECT StudentId, Admisiondate, Duration, FacultyId,
LEAD(Duration) OVER (PARTITION BY FacultyId ORDER BY Admisiondate) AS LeadAmount
FROM Relation;

SELECT StudentId, Admisiondate, Duration, FacultyId,
LAG(Admisiondate) OVER (PARTITION BY FacultyId ORDER BY Admisiondate) AS PrevAdmissionDate
FROM Relation;

SELECT StudentId, Admisiondate, Duration,
CUME_DIST() OVER (PARTITION BY StudentId ORDER BY Duration) AS Cumulative_Distribution
FROM Relation;


