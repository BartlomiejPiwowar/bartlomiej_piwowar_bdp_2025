INSERT INTO buildings (geometry, name) VALUES
(ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 0), 'BuildingA'),
(ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0), 'BuildingB'),
(ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 0), 'BuildingC'),
(ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0), 'BuildingD'),
(ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 0), 'BuildingF');

INSERT INTO roads (geometry, name) VALUES
(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'RoadX'),
(ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)', 0), 'RoadY');

INSERT INTO poi (geometry, name) VALUES
(ST_GeomFromText('POINT(1 3.5)', 0), 'G'),
(ST_GeomFromText('POINT(5.5 1.5)', 0), 'H'),
(ST_GeomFromText('POINT(9.5 6)', 0), 'I'),
(ST_GeomFromText('POINT(6.5 6)', 0), 'J'),
(ST_GeomFromText('POINT(6 9.5)', 0), 'K');

--a) Wyznacz całkowitą długość dróg w analizowanym mieście.   
SELECT SUM(ST_Length(geometry)) AS total_road_length
FROM roads;

--b) Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA.  
SELECT 
    ST_AsText(geometry) AS wkt,
    ST_Area(geometry) AS area,
    ST_Perimeter(geometry) AS perimeter
FROM buildings
WHERE name = 'BuildingA';

--c) Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.   
SELECT name, ST_Area(geometry) AS area
FROM buildings
ORDER BY name ASC;

--d) Wypisz nazwy i obwody 2 budynków o największej powierzchni.   
SELECT name, ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;

--e) Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem K.   
SELECT ST_Distance(b.geometry, p.geometry) AS min_distance
FROM buildings b
JOIN poi p ON p.name = 'K'
WHERE b.name = 'BuildingC';

--f) Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB.  
SELECT ST_Area(ST_Difference(bC.geometry, ST_Buffer(bB.geometry, 0.5))) AS area
FROM buildings bC
JOIN buildings bB ON bB.name = 'BuildingB'
WHERE bC.name = 'BuildingC';

--g) Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX. 
SELECT b.name
FROM buildings b
JOIN roads r ON r.name = 'RoadX'
WHERE ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_StartPoint(r.geometry));

--h) Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów. 
WITH poly AS (
    SELECT ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0) AS geom
)
SELECT ST_Area(ST_SymDifference(b.geometry, poly.geom)) AS area
FROM buildings b, poly
WHERE b.name = 'BuildingC';