--- Inlämnigsuppgift Lab2
--- Namn : Abdi-Salam Ibrahim
--- Klass : DevSecOps 2025 

--- Som en påminnelse har jag gjort två delar separat: en del i version G och den andra i version VG.
--- Den här delen är version G-delen.


Create database Lab2_del_G  
Go 

Use Lab2_del_G  
Go

----- RADERING AV TABELLER  (stor tack !!! ...Drop table if..) 
-- Syfte: Ta bort alla tabeller för att skapa en ren databas
-- Viktigt: Barn-tabeller (med FK) måste tas bort FÖRE de föräldratabeller som de hänvisar till

DROP TABLE IF EXISTS OrderDetaljer; 
DROP TABLE IF EXISTS Ordrar;        
DROP TABLE IF EXISTS LagerSaldo;     
DROP TABLE IF EXISTS Kunder;         
DROP TABLE IF EXISTS Böcker;        
DROP TABLE IF EXISTS Butiker;        
DROP TABLE IF EXISTS Författare;     

DROP VIEW IF EXISTS v_TitlarPerFörfattare;

--------

-- Table 1: Författare

-- ============================================
-- Table 1: Författare (avec Date de Décès)
-- ============================================
CREATE TABLE Författare 
(
    FörfattareID INT IDENTITY PRIMARY KEY,
    Förnamn NVARCHAR(100) NOT NULL,
    Efternamn NVARCHAR(100) NOT NULL,
    Födelsedatum DATE NULL,
    Dödsdatum DATE NULL,  
     CONSTRAINT Check_Författare_Födelsedatum CHECK (Födelsedatum <= GETDATE()),
     CONSTRAINT Check_Författare_Dödsdatum CHECK (Dödsdatum <= GETDATE()),
    cONSTRAINT Check_Författare_Dödsdatum_Efter_Födelse CHECK (Dödsdatum IS NULL OR Dödsdatum >= Födelsedatum)
);
GO


-- Table 2: Böcker

CREATE TABLE Böcker 
(
    ISBN13 CHAR(13) PRIMARY KEY,
    Titel NVARCHAR(300) NOT NULL,
    Språk NVARCHAR(50) NOT NULL DEFAULT 'Svenska',
    Pris DECIMAL(10,2) NOT NULL,
    Utgivningsdatum DATE NULL,
    FörfattareID INT NOT NULL,
    Genre NVARCHAR(50) NULL,
    CONSTRAINT Check_Böcker_Pris CHECK (Pris >= 0),
    CONSTRAINT Check_Böcker_ISBN13 CHECK (ISBN13 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT FK_Böcker_Författare FOREIGN KEY (FörfattareID) REFERENCES Författare(FörfattareID),
    CONSTRAINT Check_Böcker_Utgivningsdatum CHECK (Utgivningsdatum <= GETDATE())
);
GO


-- Table 3: Butiker

CREATE TABLE Butiker 
(
    ButikID INT IDENTITY PRIMARY KEY,
    Butiksnamn NVARCHAR(200) NOT NULL,
    Adress NVARCHAR(300) NOT NULL,
    Stad NVARCHAR(100) NOT NULL,
    Land NVARCHAR(100) NOT NULL DEFAULT 'Sverige'
);
GO


-- Table 4: LagerSaldo

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


-- Table 5: Kunder

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


-- Table 6: Ordrar

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


-- Table 7: OrderDetaljer

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




------------------------ Data demo
--  Data demo Författare
INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum, Dödsdatum) VALUES
('J.K.', 'Rowling', '1965-07-31', NULL),
('Stephen', 'King', '1947-09-21', NULL),
('Haruki', 'Murakami', '1949-01-12', NULL),
('Stieg', 'Larsson', '1954-08-15', '2004-11-09'),

('George', 'Orwell', '1903-06-25', '1950-01-21'),
('Agatha', 'Christie', '1890-09-15', '1976-01-12'),
('Ernest', 'Hemingway', '1899-07-21', '1961-07-02'),
('Victor', 'Hugo', '1802-02-26', '1885-05-22'),
('Albert', 'Camus', '1913-11-07', '1960-01-04'),
('Gabriel', 'García Márquez', '1927-03-06', '2014-04-17'),
('Astrid', 'Lindgren', '1907-11-14', '2002-01-28');
GO

-- Data demo Böcker
INSERT INTO Böcker (ISBN13, Titel, Språk, Pris, Utgivningsdatum, FörfattareID, Genre) VALUES
('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 'Engelska', 299.00, '1997-06-26', 1, 'Fantasy'),
('9780439064873', 'Harry Potter and the Chamber of Secrets', 'Engelska', 299.00, '1998-07-02', 1, 'Fantasy'),
('9780439136365', 'Harry Potter and the Prisoner of Azkaban', 'Engelska', 319.00, '1999-07-08', 1, 'Fantasy'),

('9780451524935', '1984', 'Engelska', 189.00, '1949-06-08', 2, 'Dystopi'),
('9780452284234', 'Animal Farm', 'Engelska', 159.00, '1945-08-17', 2, 'Satir'),

('9780062073488', 'Murder on the Orient Express', 'Engelska', 179.00, '1934-01-01', 3, 'Deckare'),

('9780307743657', 'The Shining', 'Engelska', 249.00, '1977-01-28', 4, 'Skräck'),
('9781501142970', 'It', 'Engelska', 349.00, '1986-09-15', 4, 'Skräck'),

('9780684801223', 'The Old Man and the Sea', 'Engelska', 169.00, '1952-09-01', 5, 'Klassiker'),

('9780451419439', 'Les Misérables', 'Franska', 399.00, '1862-01-01', 6, 'Klassiker'),

('9780679720201', 'L''Étranger', 'Franska', 179.00, '1942-01-01', 7, 'Filosofi'),

('9780307476463', 'Norwegian Wood', 'Japanska', 269.00, '1987-09-04', 8, 'Roman'),
('9780307593313', '1Q84', 'Japanska', 449.00, '2009-05-29', 8, 'Science Fiction'),

('9780060883287', 'One Hundred Years of Solitude', 'Spanska', 289.00, '1967-05-30', 9, 'Magisk Realism'),

('9789129697704', 'Pippi Långstrump', 'Svenska', 149.00, '1945-11-01', 10, 'Barn'),

('9780307454546', 'Män som hatar kvinnor', 'Svenska', 199.00, '2005-08-01', 11, 'Thriller');
GO


-- data demo Butiker

INSERT INTO Butiker (Butiksnamn, Adress, Stad, Land) VALUES
('Akademibokhandeln Stockholm', 'Mäster Samuelsgatan 28', 'Stockholm', 'Sverige'),
('Waterstones London', '203-206 Piccadilly', 'London', 'Storbritannien'),
('Shakespeare and Company', '37 Rue de la Bûcherie', 'Paris', 'Frankrike'),
('Strand Bookstore', '828 Broadway', 'New York', 'USA'),
('Kinokuniya Tokyo', '5 Chome-24-2 Sendagaya', 'Tokyo', 'Japan');
GO

-- Data demo LagerSAldo

INSERT INTO LagerSaldo (ButikID, ISBN13, Antal) VALUES
(1, '9780439708180', 15),
(1, '9780439064873', 12),
(1, '9780451524935', 8),
(1, '9780307743657', 10),
(1, '9789129697704', 25),
(1, '9780307454546', 20),
(1, '9780307476463', 7),

(2, '9780439708180', 30),
(2, '9780439064873', 28),
(2, '9780439136365', 25),
(2, '9780451524935', 18),
(2, '9780452284234', 15),
(2, '9780062073488', 12),
(2, '9780684801223', 10),

(3, '9780451419439', 14),
(3, '9780679720201', 16),
(3, '9780439708180', 10),
(3, '9780307743657', 8),
(3, '9780060883287', 12),

(4, '9780307743657', 22),
(4, '9781501142970', 18),
(4, '9780684801223', 15),
(4, '9780451524935', 20),
(4, '9780439708180', 25),
(4, '9780060883287', 10),

(5, '9780307476463', 30),
(5, '9780307593313', 25),
(5, '9780439708180', 12),
(5, '9780451524935', 10),
(5, '9780307743657', 8);
GO
-- Data demo Kunder
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
--- data demo Ordrar
INSERT INTO Ordrar (KundID, ButikID, OrderDatum, Status) VALUES
(1, 1, '2024-10-15', 'Levererad'),
(2, 1, '2024-11-01', 'Skickad'),
(8, 1, '2024-11-10', 'Bekräftad'),

(3, 2, '2024-10-20', 'Levererad'),
(3, 2, '2024-11-05', 'Väntande'),

(4, 3, '2024-10-25', 'Levererad'),

(5, 4, '2024-11-02', 'Skickad'),
(5, 4, '2024-11-15', 'Väntande'),

(6, 5, '2024-10-18', 'Levererad'),
(6, 5, '2024-11-12', 'Bekräftad');
GO


-- Data demo OrderDetaljer

INSERT INTO OrderDetaljer (OrderID, ISBN13, Antal, PrisPerExemplar) VALUES
(1, '9780439708180', 2, 299.00),
(1, '9789129697704', 1, 149.00),

(2, '9780307454546', 3, 199.00),
(2, '9780451524935', 1, 189.00),

(3, '9780439064873', 1, 299.00),
(3, '9780307743657', 1, 249.00),

(4, '9780439708180', 2, 299.00),
(4, '9780439064873', 2, 299.00),
(4, '9780439136365', 1, 319.00),

(5, '9780451524935', 1, 189.00),
(5, '9780062073488', 1, 179.00),

(6, '9780451419439', 1, 399.00),
(6, '9780679720201', 2, 179.00),

(7, '9780307743657', 2, 249.00),
(7, '9781501142970', 1, 349.00),

(8, '9780684801223', 1, 169.00),

(9, '9780307476463', 3, 269.00),
(9, '9780307593313', 1, 449.00),

(10, '9780307476463', 2, 269.00);
GO


-- v_TitlarPerFörfattare -------------------------------------------------------------------------------
CREATE VIEW v_TitlarPerFörfattare AS
SELECT 
    CONCAT(f.Förnamn, ' ', f.Efternamn) AS Namn,
    CONCAT(
        DATEDIFF(YEAR, f.Födelsedatum, COALESCE(f.Dödsdatum, GETDATE())) - 
        CASE 
            WHEN MONTH(f.Födelsedatum) > MONTH(COALESCE(f.Dödsdatum, GETDATE())) 
                 OR (MONTH(f.Födelsedatum) = MONTH(COALESCE(f.Dödsdatum, GETDATE())) 
                     AND DAY(f.Födelsedatum) > DAY(COALESCE(f.Dödsdatum, GETDATE())))
            THEN 1 ELSE 0 
        END,
        ' år'
    ) AS Ålder,
    CONCAT(COUNT(DISTINCT b.ISBN13), ' st') AS Titlar,
    CONCAT(ISNULL(SUM(b.Pris * ls.Antal), 0), ' kr') AS Lagervärde
FROM Författare f
LEFT JOIN Böcker b ON f.FörfattareID = b.FörfattareID
LEFT JOIN LagerSaldo ls ON b.ISBN13 = ls.ISBN13
GROUP BY f.FörfattareID, f.Förnamn, f.Efternamn, f.Födelsedatum, f.Dödsdatum;
GO

-- Testa vyn och tabeller
SELECT * FROM v_TitlarPerFörfattare ORDER BY Namn;

SELECT * FROM Författare;
SELECT * FROM Böcker;
SELECT * FROM Butiker;
SELECT * FROM LagerSaldo;
SELECT * FROM Kunder;
SELECT * FROM Ordrar;
SELECT * FROM OrderDetaljer;
