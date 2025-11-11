--- Inlämnigsuppgift 1
--- Namn : Abdi-Salam Ibrahim
--- Klass : DevSecOps 2025 

Use everyloop
Go



--- Uppgift 1 

-- Jag har lärt mig att man använder hakparenteser [ ] när kolumn
-- eller tabellnamn innehåller ett mellanslag eller är ett reserverat SQL-ord som date eller type

Select Spacecraft, [Launch date], [Carrier rocket], Operator, [Mission type]
into SuccessfulMissions from MoonMissions 
where outcome = 'Successful' 
GO
Select * from SuccessfulMissions
GO

--- Uppgit 2 
Update SuccessfulMissions set Operator = TRIM(operator)
Select * from SuccessfulMissions
GO

--- Uppgit 3
--Jag har lärt mig:
--Skillnaden mellan WHERE och HAVING: WHERE filtrerar de enskilda raderna, medan HAVING filtrerar grupperna.

Select operator, [mission Type], count(*) as [Mission count]
From SuccessfulMissions
Group by Operator, [Mission type]
having count(*) > 1
Order by Operator, [Mission type]
Go

--- Uppgit 4
 update SuccessfulMissions
Set [Spacecraft] = CASE 
    wHeN CHARINDEX('(', [Spacecraft]) > 0 
    Then LTRIM(RTRIM(LEFT([Spacecraft], CHARINDEX('(', [Spacecraft]) - 1)))
    Else [Spacecraft]
End
WHere CHARINDEX('(', [Spacecraft]) > 0

Go
select * from  SuccessfulMissions
GO

--- uppgift 4 
Update SuccessfulMissions SET [Spacecraft] = CASE 
    When CHARINDEX('(', [Spacecraft]) > 0 
    Then LTRIM(RTRIM(LEFT([Spacecraft], CHARINDEX('(', [Spacecraft]) - 1)))
    Else [Spacecraft]
End
Where CHARINDEX('(', [Spacecraft]) > 0

Select * from SuccessfulMissions
GO

--- uppgift 5 

Select * from Users 

---SELECT....... INTO NewUsers FROM Users

Select ID,FirstName,LastName,CONCAT(FirstName,' ', LastName) as [Name],UserName,
Case
WHEN CAST(SUBSTRING([ID], 10, 1) AS INT) % 2 = 0 THEN 'Female'
Else 'Male'
End as Gender
into NewUsers
FROM Users
select * from NewUsers
GO
--- Uppgift 6


SELECT 
    [UserName],
    COUNT(*) AS [Duplicate count]
FROM NewUsers
GROUP BY [UserName]
HAVING COUNT(*) > 1
select * from NewUsers
GO

--- Uppgift 7

ALTER TABLE NewUsers
ALTER COLUMN [UserName] NVARCHAR(20);

GO

UPDATE NewUsers
SET [UserName] = [UserName] + RIGHT([ID], 4)
WHERE [UserName] IN (
    SELECT [UserName]
    FROM NewUsers
    GROUP BY [UserName]
    HAVING COUNT(*) > 1);

GO
select * from NewUsers 
GO

----uppgift 8
Delete from  NewUsers
where [Gender] = 'Female' AND 
( 
(LEFT([ID], 2) < '70')
)
GO
Select * from NewUsers
Select Id, gender from NewUsers
where gender = 'female' 
GO
--- uppgift 9

Select * from NewUsers
Insert into NewUsers (ID,firstName,LastName, [Name],USerName, gender) values
                    (9511111234,'Abdi','Salam','Abdi-Salam','Abdi','Male') 
Go
Select * from NewUsers
Go

--uppgift 10

Select Gender, AVG(
 case
 When Left([ID], 2) <= '24' 
 THEN YEAR(GETDATE()) - (2000 + CAST(LEFT([ID], 2) AS INT))
 else YEAR(GETDATE()) - (1900 + CAST(LEFT([ID], 2) AS INT))
end
) AS [Average age]
FROM NewUsers
GROUP BY [Gender]
GO
