-- a) Wyświetl tylko id pracownika oraz jego nazwisko
SELECT id_pracownika, nazwisko
FROM ksiegowosc.pracownicy;

-- b) Wyświetl id pracowników, których płaca jest większa niż 1000
SELECT p.id_pracownika, pe.kwota
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as kw ON p.id_pracownika = kw.id_pracownika
JOIN ksiegowosc.pensja as pe ON kw.id_pensji = pe.id_pensji
WHERE pe.kwota > 1000;

-- c) Wyświetl id pracowników nieposiadających premii, których płaca jest większa niż 2000
SELECT p.id_pracownika, pr.kwota as premia, pe.kwota as pensja
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON pe.id_pensji = w.id_pensji
JOIN ksiegowosc.premia as pr ON pr.id_premii = w.id_premii
WHERE pr.kwota IS NULL AND pe.kwota > 2000;

-- d) Wyświetl pracowników, których pierwsza litera imienia zaczyna się na literę ‘J’
SELECT id_pracownika, imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE imie LIKE 'J%';

-- e) Wyświetl pracowników, których nazwisko zawiera literę ‘n’ oraz imię kończy się na literę ‘a’
SELECT id_pracownika, imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE imie LIKE '%a' AND nazwisko LIKE '%n%';

-- f) Wyświetl imię i nazwisko pracowników oraz liczbę ich nadgodzin, przyjmując, iż standardowy czas pracy to 160h miesięcznie
SELECT p.imie, p.nazwisko, (g.liczba_godzin - 160) as liczba_nadgodzin 
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.godziny as g ON w.id_godziny = g.id_godziny
WHERE g.liczba_godzin > 160;

-- g) Wyświetl imię i nazwisko pracowników, których pensja zawiera się w przedziale 1500 – 3000 PLN
SELECT p.imie, p.nazwisko, pe.kwota as pensja
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON w.id_pensji = pe.id_pensji
WHERE pe.kwota BETWEEN 1500 AND 3000;

-- h) Wyświetl imię i nazwisko pracowników, którzy pracowali w nadgodzinach i nie otrzymali premii
SELECT p.imie, p.nazwisko, (liczba_godzin - 160) as liczba_nadgodzin, pr.kwota as premia
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.godziny as g ON w.id_godziny = g.id_godziny
JOIN ksiegowosc.premia as pr ON w.id_premii = pr.id_premii
WHERE (liczba_godzin - 160) > 0 AND pr.kwota IS NULL;

-- i) Uszereguj pracowników według pensji
SELECT pe.kwota as pensja, p.imie, p.nazwisko
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON w.id_pensji = pe.id_pensji
ORDER BY pe.kwota DESC;

-- j) Uszereguj pracowników według pensji i premii malejąco
SELECT (COALESCE(pr.kwota, 0) + pe.kwota) as laczne_wynagrodzenie, p.imie, p.nazwisko
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON w.id_pensji = pe.id_pensji
LEFT JOIN ksiegowosc.premia as pr ON w.id_premii = pr.id_premii
ORDER BY laczne_wynagrodzenie DESC;

-- k) Zlicz i pogrupuj pracowników według pola ‘stanowisko’
SELECT pe.stanowisko, COUNT(*) as zliczenia
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON pe.id_pensji = w.id_pensji
GROUP BY pe.stanowisko

-- l) Policz średnią, minimalną i maksymalną płacę dla stanowiska ‘kierownik’ (jeżeli takiego nie masz, to przyjmij dowolne inne)
SELECT AVG(pe.kwota) as średnia, MIN(pe.kwota) as minimalna, MAX(pe.kwota) as maksymalna
FROM ksiegowosc.pracownicy as p 
JOIN ksiegowosc.wynagrodzenie as w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe ON w.id_pensji = pe.id_pensji
WHERE pe.stanowisko = 'Kierownik'

-- m) Policz sumę wszystkich wynagrodzeń
SELECT SUM(pe.kwota + COALESCE(pr.kwota, 0)) AS suma_wynagrodzen
FROM ksiegowosc.pensja as pe
JOIN ksiegowosc.wynagrodzenie as w ON pe.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia as pr ON w.id_premii = pr.id_premii

-- n) Policz sumę wynagrodzeń w ramach danego stanowiska
SELECT pe.stanowisko, SUM(pe.kwota) as suma
FROM ksiegowosc.wynagrodzenie as w
JOIN ksiegowosc.pensja as pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko;

-- o) Wyznacz liczbę premii przyznanych dla pracowników danego stanowiska
SELECT pe.stanowisko, COUNT(pr.id_premii) as liczba_premii
FROM ksiegowosc.pensja as pe
JOIN ksiegowosc.wynagrodzenie as w ON pe.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia as pr ON w.id_premii = pr.id_premii
GROUP BY pe.stanowisko

-- p) Usuń wszystkich pracowników mających pensję mniejszą niż 1200 zł
DELETE FROM ksiegowosc.pracownicy
WHERE id_pracownika IN (
    SELECT w.id_pracownika
    FROM ksiegowosc.wynagrodzenie AS w
    JOIN ksiegowosc.pensja AS pe ON w.id_pensji = pe.id_pensji
    WHERE pe.kwota < 1200
);
