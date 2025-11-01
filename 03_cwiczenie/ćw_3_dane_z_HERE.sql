-- 1. Znajdz Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana pomiędzy 2018 a 2019).
CREATE TABLE changed_buildings AS 
SELECT DISTINCT b19.*
FROM t2019_kar_buildings b19
LEFT JOIN t2018_kar_buildings b18 ON b19.polygon_id = b18.polygon_id
WHERE b18.polygon_id IS NULL OR NOT ST_Equals(b19.geom, b18.geom);

SELECT COUNT(*) AS liczba_zmienionych
FROM changed_buildings;



-- 2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii
SELECT p19.type, COUNT(DISTINCT p19.poi_id) AS liczba_poi
FROM t2019_kar_poi_table p19
LEFT JOIN t2018_kar_poi_table p18 ON p19.poi_id = p18.poi_id
JOIN changed_buildings cb ON ST_DWithin(p19.geom, cb.geom, 500)
WHERE p18.poi_id IS NULL
GROUP BY p19.type
ORDER BY liczba_poi DESC;



-- 3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini
CREATE TABLE streets_reprojected AS
SELECT *, ST_Transform(geom, 3068) AS geom_3068
FROM t2019_kar_streets;



-- 4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej. Użyj następujących współrzędnych:
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom geometry(Point, 4326)
);

INSERT INTO input_points (geom) VALUES
(ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
(ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));




-- 5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych DHDN.Berlin/Cassini
ALTER TABLE input_points
ADD COLUMN geom_3068 geometry(Point, 3068);

UPDATE input_points
SET geom_3068 = ST_Transform(geom, 3068);

SELECT 
    id,
    ST_AsText(geom) AS geom_4326,
    ST_AsText(geom_3068) AS geom_3068
    ST_SRID(geom_3068) AS srid
FROM input_points;




-- 6.  Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel
CREATE TABLE input_line AS 
SELECT  ST_MakeLine(geom_3068 ORDER BY id) AS geom
FROM input_points;

CREATE TABLE street_nodes_reproj AS
SELECT *, ST_Transform(geom, 3068) AS geom_3068
FROM t2019_kar_street_node;

CREATE TABLE intersections_200m AS
SELECT n.*
FROM street_nodes_reproj n, input_line
WHERE ST_DWithin(n.geom_3068, l.geom, 200);




-- 7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się w odległości 300 m od parków (LAND_USE_A)
SELECT COUNT(DISTINCT p.grid) AS liczba_sklepow_sportowych
FROM t2019_kar_poi_table p 
JOIN t2019_kar_land_use_a l ON ST_DWithin(p.geom, l.geom, 300)
WHERE p.type = 'Sporting Goods Store';



-- 8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’
SELECT TABLE t2019_kar_bridges AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM t2019_kar_railways r
JOIN t2019_kar_water_lines w ON ST_Intersects(r.geom, w.geom);

SELECT COUNT(*) AS liczba_mostow FROM t2019_kar_bridges;