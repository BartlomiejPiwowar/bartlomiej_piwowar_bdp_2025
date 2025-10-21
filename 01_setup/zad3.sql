CREATE TABLE ksiegowosc.pracownicy (
	id_pracownika INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	imie VARCHAR(50) NOT NULL,
	nazwisko VARCHAR(50) NOT NULL,
	adres VARCHAR(100),
	telefon VARCHAR(15)
); 
COMMENT ON TABLE ksiegowosc.pracownicy IS 'Tabela zawiera dane osobowe pracowników firmy (imię, nazwisko, adres, telefon).';


CREATE TABLE ksiegowosc.godziny (
	id_godziny INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	data DATE NOT NULL,
	liczba_godzin INT,
	id_pracownika INT,
	FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika)
);
COMMENT ON TABLE ksiegowosc.godziny IS 'Tabela rejestruje liczbę przepracowanych godzin danego pracownika w określonym dniu.';


CREATE TABLE ksiegowosc.pensja (
	id_pensji INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	stanowisko VARCHAR(50) NOT NULL,
	kwota DECIMAL(10, 2) NOT NULL CHECK (kwota >= 0)
);
COMMENT ON TABLE ksiegowosc.pensja IS 'Tabela przechowuje dane o podstawowym wynagrodzeniu dla określonego stanowiska.';


CREATE TABLE ksiegowosc.premia (
	id_premii INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	rodzaj VARCHAR(50) NOT NULL,
	kwota DECIMAL(10,2) CHECK (kwota >= 0)
);
COMMENT ON TABLE ksiegowosc.premia IS 'Tabela zawiera informacje o rodzajach premii i ich wysokościach.';


CREATE TABLE ksiegowosc.wynagrodzenie (
	id_wynagrodzenia INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	id_pracownika INT NOT NULL,
	id_godziny INT NOT NULL,
	id_pensji INT NOT NULL,
	id_premii INT,
	data DATE NOT NULL,
	FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika),
	FOREIGN KEY (id_godziny) REFERENCES ksiegowosc.godziny(id_godziny),
	FOREIGN KEY (id_pensji) REFERENCES ksiegowosc.pensja(id_pensji),
	FOREIGN KEY (id_premii) REFERENCES ksiegowosc.premia(id_premii)
);
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Tabela łączy dane o pracowniku, przepracowanych godzinach, pensji i ewentualnej premii w celu obliczenia całkowitego wynagrodzenia.';
