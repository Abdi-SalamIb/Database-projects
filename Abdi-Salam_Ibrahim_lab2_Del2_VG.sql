--- Inlämnigsuppgift Lab2
--- Namn : Abdi-Salam Ibrahim
--- Klass : DevSecOps 2025 

--- Som en påminnelse har jag gjort två delar separat: en del i version G och den andra i version VG.
--- Den här delen är version VG-delen.


Create database Lab2_del_VG  
Go 

Use Lab2_del_VG  
Go

---*********************************
---  Radering av gamla tabeller
---*********************************

DROP TABLE IF EXISTS v_TitlarPerFörfattare
DROP TABLE IF EXISTS v_FörlagStatistik 
DROP TABLE IF EXISTS v_LeverantörStatistik
DROP TABLE IF EXISTS Recensioner;
DROP TABLE IF EXISTS OrderDetaljer;
DROP TABLE IF EXISTS Ordrar;
DROP TABLE IF EXISTS Kunder;
DROP TABLE IF EXISTS LagerSaldo;
DROP TABLE IF EXISTS BokFörfattare;
DROP TABLE IF EXISTS Butiker;
DROP TABLE IF EXISTS Böcker;
DROP TABLE IF EXISTS Förlag;
DROP TABLE IF EXISTS Leverantörer;
DROP TABLE IF EXISTS Författare;
GO

-- ********************************************
--    TABELLER
-- ********************************************

-- Tabell 1 : Författare
CREATE TABLE Författare 
(
    FörfattareID INT IDENTITY PRIMARY KEY,
    Förnamn NVARCHAR(100) NOT NULL,
    Efternamn NVARCHAR(100) NOT NULL,
    Födelsedatum DATE NULL,
    Dödsdatum DATE NULL,
    CONSTRAINT Check_Författare_Födelsedatum CHECK (Födelsedatum <= GETDATE()),
    CONSTRAINT Check_Författare_Dödsdatum CHECK (Dödsdatum <= GETDATE()),
    CONSTRAINT Check_Författare_Dödsdatum_Efter_Födelse CHECK (Dödsdatum IS NULL OR Dödsdatum >= Födelsedatum)
);
GO

-- Tabell 2 : Leverantörer
CREATE TABLE Leverantörer 
(
    LeverantörID INT IDENTITY PRIMARY KEY,
    Företagsnamn NVARCHAR(200) NOT NULL,
    Kontaktperson NVARCHAR(200) NULL,
    Email NVARCHAR(200) NULL,
    Telefon NVARCHAR(50) NULL,
    Land NVARCHAR(100) NOT NULL DEFAULT 'Sverige',
    Webbplats NVARCHAR(300) NULL,
    CONSTRAINT Check_Leverantörer_Email CHECK (Email LIKE '%_@__%.__%')
);
GO

-- Tabell 3 : Förlag
CREATE TABLE Förlag 
(
    FörlagID INT IDENTITY PRIMARY KEY,
    Förlagsnamn NVARCHAR(200) NOT NULL,
    Land NVARCHAR(100) NOT NULL DEFAULT 'Sverige',
    Grundat INT NULL,
    Website NVARCHAR(300) NULL,
    LeverantörID INT NULL,
    CONSTRAINT Check_Förlag_Grundat CHECK (Grundat >= 1400 AND Grundat <= YEAR(GETDATE())),
    CONSTRAINT FK_Förlag_Leverantörer FOREIGN KEY (LeverantörID) REFERENCES Leverantörer(LeverantörID)
);
GO

-- Tabell 4 : Böcker
CREATE TABLE Böcker 
(
    ISBN13 CHAR(13) PRIMARY KEY,
    Titel NVARCHAR(300) NOT NULL,
    Språk NVARCHAR(50) NOT NULL DEFAULT 'Svenska',
    Pris DECIMAL(10,2) NOT NULL,
    Utgivningsdatum DATE NULL,
    FörlagID INT NULL,
    Genre NVARCHAR(50) NULL,
    CONSTRAINT Check_Böcker_Pris CHECK (Pris >= 0),
    CONSTRAINT Check_Böcker_ISBN13 CHECK (ISBN13 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT FK_Böcker_Förlag FOREIGN KEY (FörlagID) REFERENCES Förlag(FörlagID),
    CONSTRAINT Check_Böcker_Utgivningsdatum CHECK (Utgivningsdatum <= GETDATE())
);
GO

-- Tabell 5 : Butiker
CREATE TABLE Butiker 
(
    ButikID INT IDENTITY PRIMARY KEY,
    Butiksnamn NVARCHAR(200) NOT NULL,
    Adress NVARCHAR(300) NOT NULL,
    Stad NVARCHAR(100) NOT NULL,
    Land NVARCHAR(100) NOT NULL DEFAULT 'Sverige'
);
GO

-- Tabell 6 : BokFörfattare 
CREATE TABLE BokFörfattare 
(
    ISBN13 CHAR(13) NOT NULL,
    FörfattareID INT NOT NULL,
    OrdningsNummer INT NOT NULL DEFAULT 1,
    PRIMARY KEY (ISBN13, FörfattareID),
    CONSTRAINT FK_BokFörfattare_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13) ON DELETE CASCADE,
    CONSTRAINT FK_BokFörfattare_Författare FOREIGN KEY (FörfattareID) REFERENCES Författare(FörfattareID) ON DELETE CASCADE,
    CONSTRAINT Check_BokFörfattare_Ordning CHECK (OrdningsNummer > 0)
);
GO

-- Tabell 7 : LagerSaldo 
CREATE TABLE LagerSaldo
(
    ButikID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL,
    PRIMARY KEY (ButikID, ISBN13),
    CONSTRAINT FK_LagerSaldo_Butiker FOREIGN KEY (ButikID) REFERENCES Butiker(ButikID),
    CONSTRAINT FK_LagerSaldo_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13),
    CONSTRAINT Check_LagerSaldo_Antal CHECK (Antal >= 0)
);
GO

-- Tabell 8 : Kunder
CREATE TABLE Kunder 
(
    KundID INT IDENTITY PRIMARY KEY,
    Förnamn NVARCHAR(100) NOT NULL,
    Efternamn NVARCHAR(100) NOT NULL,
    Email NVARCHAR(200) NULL,
    Telefonnummer NVARCHAR(50) NULL,
    Adress NVARCHAR(300) NULL,
    Stad NVARCHAR(100) NULL,
    Land NVARCHAR(100) NULL,
    RegistreringsDatum DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT Check_Kunder_Email CHECK (Email LIKE '%_@__%.__%')
);
GO

-- Tabell 9 : Ordrar
CREATE TABLE Ordrar 
(
    OrderID INT IDENTITY PRIMARY KEY,
    KundID INT NOT NULL,
    ButikID INT NOT NULL,
    OrderDatum DATE NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Väntande',
    CONSTRAINT FK_Ordrar_Kunder FOREIGN KEY (KundID) REFERENCES Kunder(KundID),
    CONSTRAINT FK_Ordrar_Butiker FOREIGN KEY (ButikID) REFERENCES Butiker(ButikID),
    CONSTRAINT Check_Ordrar_Status CHECK (Status IN ('Väntande', 'Bekräftad', 'Skickad', 'Levererad', 'Avbruten'))
);
GO

-- Tabell 10 : OrderDetaljer 
CREATE TABLE OrderDetaljer 
(
    OrderDetaljID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL,
    PrisPerExemplar DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderDetaljer_Ordrar FOREIGN KEY (OrderID) REFERENCES Ordrar(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetaljer_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13),
    CONSTRAINT Check_OrderDetaljer_Antal CHECK (Antal > 0),
    CONSTRAINT Check_OrderDetaljer_Pris CHECK (PrisPerExemplar >= 0)
);
GO

-- Tabell 11 : Recensioner
CREATE TABLE Recensioner 
(
    RecensionID INT IDENTITY PRIMARY KEY,
    KundID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Betyg INT NOT NULL,
    Kommentar NVARCHAR(1000) NULL,
    RecensionDatum DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Recensioner_Kunder FOREIGN KEY (KundID) REFERENCES Kunder(KundID) ON DELETE CASCADE,
    CONSTRAINT FK_Recensioner_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13) ON DELETE CASCADE,
    CONSTRAINT Check_Recensioner_Betyg CHECK (Betyg BETWEEN 1 AND 5), --- Star 1 till star 5
    CONSTRAINT UQ_Recensioner_Kund_Bok UNIQUE (KundID, ISBN13)
);
GO

---***********************************
---- Demo Data
---**********************************

-- Författare
INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum, Dödsdatum) VALUES
('J.K.', 'Rowling', '1965-07-31', NULL),
('George', 'Orwell', '1903-06-25', '1950-01-21'),
('Agatha', 'Christie', '1890-09-15', '1976-01-12'),
('Stephen', 'King', '1947-09-21', NULL),
('Ernest', 'Hemingway', '1899-07-21', '1961-07-02'),
('Victor', 'Hugo', '1802-02-26', '1885-05-22'),
('Albert', 'Camus', '1913-11-07', '1960-01-04'),
('Haruki', 'Murakami', '1949-01-12', NULL),
('Gabriel', 'García Márquez', '1927-03-06', '2014-04-17'),
('Astrid', 'Lindgren', '1907-11-14', '2002-01-28'),
('Stieg', 'Larsson', '1954-08-15', '2004-11-09');
GO

-- Leverantörer
INSERT INTO Leverantörer (Företagsnamn, Kontaktperson, Email, Telefon, Land, Webbplats) VALUES
('Bertrams Books', 'David Williams', 'david.williams@bertrams.com', '+441603695800', 'Storbritannien', 'www.bertrams.com'),
('Ingram Content Group', 'Sarah Miller', 'sarah.miller@ingramcontent.com', '+16157937000', 'USA', 'www.ingramcontent.com'),
('Hachette Distribution', 'Jean Moreau', 'jean.moreau@hachette.fr', '+33149544200', 'Frankrike', 'www.hachette.fr'),
('BTJ Sverige', 'Anna Bergström', 'anna.bergstrom@btj.se', '+46858503000', 'Sverige', 'www.btj.se'),
('Nippan IPS', 'Takeshi Yamamoto', 'takeshi.yamamoto@nippan.co.jp', '+81332950811', 'Japan', 'www.nippan.co.jp');
GO

-- Förlag
INSERT INTO Förlag (Förlagsnamn, Land, Grundat, Website, LeverantörID) VALUES
('Bloomsbury Publishing', 'Storbritannien', 1986, 'www.bloomsbury.com', 1),
('Penguin Random House', 'USA', 1927, 'www.penguinrandomhouse.com', 2),
('Hachette Livre', 'Frankrike', 1826, 'www.hachette.com', 3),
('Rabén & Sjögren', 'Sverige', 1942, 'www.raben.se', 4),
('Norstedts', 'Sverige', 1823, 'www.norstedts.se', 4);
GO

-- Böcker
INSERT INTO Böcker (ISBN13, Titel, Språk, Pris, Utgivningsdatum, FörlagID, Genre) VALUES
('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 'Engelska', 299.00, '1997-06-26', 1, 'Fantasy'),
('9780439064873', 'Harry Potter and the Chamber of Secrets', 'Engelska', 299.00, '1998-07-02', 1, 'Fantasy'),
('9780439136365', 'Harry Potter and the Prisoner of Azkaban', 'Engelska', 319.00, '1999-07-08', 1, 'Fantasy'),
('9780451524935', '1984', 'Engelska', 189.00, '1949-06-08', 2, 'Dystopi'),
('9780452284234', 'Animal Farm', 'Engelska', 159.00, '1945-08-17', 2, 'Satir'),
('9780062073488', 'Murder on the Orient Express', 'Engelska', 179.00, '1934-01-01', 2, 'Deckare'),
('9780307743657', 'The Shining', 'Engelska', 249.00, '1977-01-28', 2, 'Skräck'),
('9781501142970', 'It', 'Engelska', 349.00, '1986-09-15', 2, 'Skräck'),
('9780684801223', 'The Old Man and the Sea', 'Engelska', 169.00, '1952-09-01', 2, 'Klassiker'),
('9780451419439', 'Les Misérables', 'Franska', 399.00, '1862-01-01', 3, 'Klassiker'),
('9780679720201', 'L''Étranger', 'Franska', 179.00, '1942-01-01', 3, 'Filosofi'),
('9780307476463', 'Norwegian Wood', 'Japanska', 269.00, '1987-09-04', 2, 'Roman'),
('9780307593313', '1Q84', 'Japanska', 449.00, '2009-05-29', 2, 'Science Fiction'),
('9780060883287', 'One Hundred Years of Solitude', 'Spanska', 289.00, '1967-05-30', 2, 'Magisk Realism'),
('9789129697704', 'Pippi Långstrump', 'Svenska', 149.00, '1945-11-01', 4, 'Barn'),
('9780307454546', 'Män som hatar kvinnor', 'Svenska', 199.00, '2005-08-01', 5, 'Thriller');
GO

-- Butiker
INSERT INTO Butiker (Butiksnamn, Adress, Stad, Land) VALUES
('Akademibokhandeln Stockholm', 'Mäster Samuelsgatan 28', 'Stockholm', 'Sverige'),
('Waterstones London', '203-206 Piccadilly', 'London', 'Storbritannien'),
('Shakespeare and Company', '37 Rue de la Bûcherie', 'Paris', 'Frankrike'),
('Strand Bookstore', '828 Broadway', 'New York', 'USA'),
('Kinokuniya Tokyo', '5 Chome-24-2 Sendagaya', 'Tokyo', 'Japan');
GO

-- BokFörfattare
INSERT INTO BokFörfattare (ISBN13, FörfattareID, OrdningsNummer) VALUES
('9780439708180', 1, 1), ('9780439064873', 1, 1), ('9780439136365', 1, 1),
('9780451524935', 2, 1), ('9780452284234', 2, 1),
('9780062073488', 3, 1),
('9780307743657', 4, 1), ('9781501142970', 4, 1),
('9780684801223', 5, 1),
('9780451419439', 6, 1),
('9780679720201', 7, 1),
('9780307476463', 8, 1), ('9780307593313', 8, 1),
('9780060883287', 9, 1),
('9789129697704', 10, 1),
('9780307454546', 11, 1);
GO

-- LagerSaldo
INSERT INTO LagerSaldo (ButikID, ISBN13, Antal) VALUES
(1, '9780439708180', 15), (1, '9780439064873', 12), (1, '9780451524935', 8),
(1, '9780307743657', 10), (1, '9789129697704', 25), (1, '9780307454546', 20),
(1, '9780307476463', 7),
(2, '9780439708180', 30), (2, '9780439064873', 28), (2, '9780439136365', 25),
(2, '9780451524935', 18), (2, '9780452284234', 15), (2, '9780062073488', 12),
(2, '9780684801223', 10),
(3, '9780451419439', 14), (3, '9780679720201', 16), (3, '9780439708180', 10),
(3, '9780307743657', 8), (3, '9780060883287', 12),
(4, '9780307743657', 22), (4, '9781501142970', 18), (4, '9780684801223', 15),
(4, '9780451524935', 20), (4, '9780439708180', 25), (4, '9780060883287', 10),
(5, '9780307476463', 30), (5, '9780307593313', 25), (5, '9780439708180', 12),
(5, '9780451524935', 10), (5, '9780307743657', 8);
GO

-- Kunder
INSERT INTO Kunder (Förnamn, Efternamn, Email, Telefonnummer, Adress, Stad, Land, RegistreringsDatum) VALUES
('Erik', 'Andersson', 'erik.andersson@email.se', '+46701234567', 'Sveavägen 123', 'Stockholm', 'Sverige', '2023-01-15'),
('Emma', 'Larsson', 'emma.larsson@email.se', '+46702345678', 'Vasagatan 45', 'Göteborg', 'Sverige', '2023-03-22'),
('James', 'Smith', 'james.smith@email.co.uk', '+447911234567', '10 Downing Street', 'London', 'Storbritannien', '2023-05-10'),
('Sophie', 'Dubois', 'sophie.dubois@email.fr', '+33612345678', 'Avenue des Champs-Élysées 100', 'Paris', 'Frankrike', '2023-07-08'),
('Michael', 'Johnson', 'michael.j@email.com', '+12125551234', '5th Avenue 123', 'New York', 'USA', '2023-09-14'),
('Yuki', 'Tanaka', 'yuki.tanaka@email.jp', '+819012345678', 'Shibuya 2-1', 'Tokyo', 'Japan', '2023-11-20'),
('Maria', 'García', 'maria.garcia@email.es', '+34612345678', 'Gran Vía 28', 'Madrid', 'Espagne', '2024-01-05'),
('Lars', 'Nilsson', 'lars.nilsson@email.se', '+46703456789', 'Storgatan 67', 'Malmö', 'Sverige', '2024-02-18');
GO

-- Ordrar
INSERT INTO Ordrar (KundID, ButikID, OrderDatum, Status) VALUES
(1, 1, '2024-10-15', 'Levererad'), (2, 1, '2024-11-01', 'Skickad'),
(8, 1, '2024-11-10', 'Bekräftad'), (3, 2, '2024-10-20', 'Levererad'),
(3, 2, '2024-11-05', 'Väntande'), (4, 3, '2024-10-25', 'Levererad'),
(5, 4, '2024-11-02', 'Skickad'), (5, 4, '2024-11-15', 'Väntande'),
(6, 5, '2024-10-18', 'Levererad'), (6, 5, '2024-11-12', 'Bekräftad');
GO

-- OrderDetaljer
INSERT INTO OrderDetaljer (OrderID, ISBN13, Antal, PrisPerExemplar) VALUES
(1, '9780439708180', 2, 299.00), (1, '9789129697704', 1, 149.00),
(2, '9780307454546', 3, 199.00), (2, '9780451524935', 1, 189.00),
(3, '9780439064873', 1, 299.00), (3, '9780307743657', 1, 249.00),
(4, '9780439708180', 2, 299.00), (4, '9780439064873', 2, 299.00),
(4, '9780439136365', 1, 319.00),
(5, '9780451524935', 1, 189.00), (5, '9780062073488', 1, 179.00),
(6, '9780451419439', 1, 399.00), (6, '9780679720201', 2, 179.00),
(7, '9780307743657', 2, 249.00), (7, '9781501142970', 1, 349.00),
(8, '9780684801223', 1, 169.00),
(9, '9780307476463', 3, 269.00), (9, '9780307593313', 1, 449.00),
(10, '9780307476463', 2, 269.00);
GO

-- Recensioner
INSERT INTO Recensioner (KundID, ISBN13, Betyg, Kommentar, RecensionDatum) VALUES
(1, '9780439708180', 5, 'Fantastisk bok! Mina barn älskar den.', '2024-10-20'),
(2, '9780439708180', 4, 'Mycket bra, men lite långsam i början.', '2024-10-22'),
(3, '9780451524935', 5, 'En klassiker som alla bör läsa.', '2024-10-25'),
(4, '9780451419439', 5, 'Magnifique! Un chef-d''œuvre.', '2024-10-28'),
(5, '9780307743657', 4, 'Very scary, couldn''t sleep!', '2024-11-01'),
(6, '9780307476463', 5, '素晴らしい小説です。', '2024-11-05'),
(1, '9780307454546', 5, 'Spännande thriller!', '2024-11-08'),
(2, '9789129697704', 5, 'Min dotter älskar Pippi!', '2024-11-10');
GO

---******************************
-- Vyer
---*****************************

CREATE VIEW v_TitlarPerFörfattare AS
SELECT 
    CONCAT(f.Förnamn, ' ', f.Efternamn) AS Namn,
    CONCAT(
        DATEDIFF(YEAR, f.Födelsedatum, COALESCE(f.Dödsdatum, GETDATE())) - 
        CASE 
            WHEN MONTH(f.Födelsedatum) > MONTH(COALESCE(f.Dödsdatum, GETDATE())) 
                OR (MONTH(f.Födelsedatum) = MONTH(COALESCE(f.Dödsdatum, GETDATE())) 
                    AND DAY(f.Födelsedatum) > DAY(COALESCE(f.Dödsdatum, GETDATE())))
            THEN 1 
            ELSE 0 
        END,
        ' år'
    ) AS Ålder,
    CONCAT(COUNT(DISTINCT bf.ISBN13), ' st') AS Titlar,
    CONCAT(ISNULL(SUM(b.Pris * ls.Antal), 0), ' kr') AS Lagervärde
FROM Författare f
LEFT JOIN BokFörfattare bf ON f.FörfattareID = bf.FörfattareID
LEFT JOIN Böcker b ON bf.ISBN13 = b.ISBN13
LEFT JOIN LagerSaldo ls ON b.ISBN13 = ls.ISBN13
GROUP BY f.FörfattareID, f.Förnamn, f.Efternamn, f.Födelsedatum, f.Dödsdatum;
GO

CREATE VIEW v_FörlagStatistik AS
SELECT 
    f.Förlagsnamn AS Förlag,
    f.Land,
    COUNT(DISTINCT b.ISBN13) AS 'Antal Titlar',
    ISNULL(SUM(ls.Antal), 0) AS 'Totalt i Lager',
    ISNULL(SUM(od.Antal), 0) AS 'Totalt Sålda',
    CONCAT(ISNULL(SUM(b.Pris * ls.Antal), 0), ' kr') AS 'Lagervärde',
    CONCAT(ISNULL(SUM(od.PrisPerExemplar * od.Antal), 0), ' kr') AS 'Totala Försäljning'
FROM Förlag f
LEFT JOIN Böcker b ON f.FörlagID = b.FörlagID
LEFT JOIN LagerSaldo ls ON b.ISBN13 = ls.ISBN13
LEFT JOIN OrderDetaljer od ON b.ISBN13 = od.ISBN13
GROUP BY f.FörlagID, f.Förlagsnamn, f.Land;
GO

CREATE VIEW v_LeverantörStatistik AS
SELECT 
    l.Företagsnamn AS Leverantör,
    l.Land,
    COUNT(DISTINCT fo.FörlagID) AS 'Antal Förlag',
    COUNT(DISTINCT b.ISBN13) AS 'Antal Titlar',
    ISNULL(SUM(ls.Antal), 0) AS 'Totalt i Lager',
    CONCAT(ISNULL(SUM(b.Pris * ls.Antal), 0), ' kr') AS 'Lagervärde'
FROM Leverantörer l
LEFT JOIN Förlag fo ON l.LeverantörID = fo.LeverantörID
LEFT JOIN Böcker b ON fo.FörlagID = b.FörlagID
LEFT JOIN LagerSaldo ls ON b.ISBN13 = ls.ISBN13
GROUP BY l.LeverantörID, l.Företagsnamn, l.Land;
GO


--- ****************************
-- Stored  Procedure
-- ****************************


-- Flytta böcker mellan butiker
CREATE PROCEDURE usp_FlyttaBok
    @FranButikID INT,
    @TillButikID INT,
    @ISBN CHAR(13),
    @Antal INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AntalILager INT;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Kontroller
        IF NOT EXISTS (SELECT 1 FROM Butiker WHERE ButikID = @FranButikID)
            THROW 50001, 'Källbutiken finns inte', 1;
        
        IF NOT EXISTS (SELECT 1 FROM Butiker WHERE ButikID = @TillButikID)
            THROW 50002, 'Målbutiken finns inte', 1;
        
        IF NOT EXISTS (SELECT 1 FROM Böcker WHERE ISBN13 = @ISBN)
            THROW 50003, 'Boken finns inte', 1;
        
        SELECT @AntalILager = Antal FROM LagerSaldo 
        WHERE ButikID = @FranButikID AND ISBN13 = @ISBN;
        
        IF @AntalILager IS NULL
            THROW 50004, 'Boken finns inte i lagret', 1;
        
        IF @AntalILager < @Antal
            THROW 50005, 'Otillräckligt lagersaldo', 1;
        
        IF @Antal <= 0
            THROW 50006, 'Antal måste vara positivt', 1;
        
        -- Minska från källbutiken
        UPDATE LagerSaldo SET Antal = Antal - @Antal
        WHERE ButikID = @FranButikID AND ISBN13 = @ISBN;
        
        DELETE FROM LagerSaldo
        WHERE ButikID = @FranButikID AND ISBN13 = @ISBN AND Antal = 0;
        
        -- Öka i målbutiken
        IF EXISTS (SELECT 1 FROM LagerSaldo WHERE ButikID = @TillButikID AND ISBN13 = @ISBN)
            UPDATE LagerSaldo SET Antal = Antal + @Antal
            WHERE ButikID = @TillButikID AND ISBN13 = @ISBN;
        ELSE
            INSERT INTO LagerSaldo (ButikID, ISBN13, Antal)
            VALUES (@TillButikID, @ISBN, @Antal);
        
        COMMIT TRANSACTION;
        PRINT 'Lyckades: ' + CAST(@Antal AS NVARCHAR) + ' exemplar flyttade';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
--*****************************************
-- TESTER
--*****************************************


-- Visa alla tabeller
SELECT * FROM Författare;
SELECT * FROM Böcker;
SELECT * FROM Butiker;
SELECT * FROM LagerSaldo;
SELECT * FROM Kunder;
SELECT * FROM Ordrar;
SELECT * FROM OrderDetaljer;
SELECT * FROM Förlag;
SELECT * FROM BokFörfattare;
SELECT * FROM Recensioner;
SELECT * FROM Leverantörer;
Go

-- Visa alla vyer
SELECT * FROM v_TitlarPerFörfattare ORDER BY Namn;
SELECT * FROM v_FörlagStatistik ORDER BY Förlag;
SELECT * FROM v_LeverantörStatistik ORDER BY Leverantör;

-- Testa stored procedure
SELECT * FROM LagerSaldo WHERE ISBN13 = '9780439708180' AND ButikID IN (1, 2);

EXEC usp_FlyttaBok 
    @FranButikID = 1, 
    @TillButikID = 2, 
    @ISBN = '9780439708180', 
    @Antal = 5;

SELECT * FROM LagerSaldo WHERE ISBN13 = '9780439708180' AND ButikID IN (1, 2);
GO