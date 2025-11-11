# Database-projects# 🚀 Lab 1 - Datamanipulering i SQL

## 📋 Projektbeskrivning

Praktisk laboration i datamanipulering i databasen **everyloop**, som innehåller två huvudtabeller:
- **MoonMissions** : Historiska månuppdrag
- **Users** : Användare med svenskt personnummer

---

## 🎯 Mål

Skapa nya tabeller från befintliga data och utföra olika operationer:
- Filtrering och skapande av tabeller
- Datarensning
- Aggregering och gruppering
- Hantering av dubbletter
- Villkorlig radering
- Beräkning av medelålder per kön

---

## 📊 Genomförda övningar

### **Tabell: MoonMissions**

#### ✅ Övning 1 : Skapa SuccessfulMissions
Extrahering av lyckade månuppdrag till en ny tabell.

**Kompetenser:** `SELECT INTO`, `WHERE`

#### ✅ Övning 2 : Rensa mellanslag
Borttagning av mellanslag före/efter operatörernas namn.

**Kompetenser:** `UPDATE`, `TRIM()`

#### ✅ Övning 3 : Räkna uppdrag
Gruppering och räkning av uppdrag per operatör och typ.

**Kompetenser:** `GROUP BY`, `HAVING`, `COUNT()`, `ORDER BY`

#### ✅ Övning 4 (VG) : Ta bort parenteser
Rensning av alternativa namn inom parenteser.

**Kompetenser:** `CHARINDEX()`, `LEFT()`, strängmanipulering

---

### **Tabell: Users**

#### ✅ Övning 5 : Skapa NewUsers med Gender
Sammanslagning av namn och bestämning av kön via personnummer.

**Kompetenser:** `CONCAT()`, `CASE`, `SUBSTRING()`, affärslogik

#### ✅ Övning 6 : Identifiera dubbletter
Sökning efter användarnamn som inte är unika.

**Kompetenser:** `GROUP BY`, `HAVING COUNT(*) > 1`

#### ✅ Övning 7 : Göra användarnamn unika
Modifiering av dubbletter för att garantera unikhet.

**Kompetenser:** `ALTER TABLE`, `UPDATE`, hantering av dubbletter

#### ✅ Övning 8 : Ta bort användare
Radering av kvinnor födda före 1970.

**Kompetenser:** `DELETE`, `BETWEEN`, datumlogik

#### ✅ Övning 9 : Lägg till en användare
Infogning av en ny post.

**Kompetenser:** `INSERT INTO`

#### ✅ Övning 10 (VG) : Beräkna medelålder
Beräkning av medelålder per kön.

**Kompetenser:** `AVG()`, `CASE`, `YEAR()`, `GETDATE()`, datumberäkningar
