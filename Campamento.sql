-- ============================================================
-- SISTEMA DE GESTIÓN CAMPAMENTO DE VERANO
-- Base de Datos PostgreSQL
-- IPN - UPIICSA | Diseño de Bases de Datos | Grupo 4CM40
-- ============================================================

-- CREACIÓN DE TABLAS

-- TABLA GRUPO
CREATE TABLE Grupo (
    GPO_CVE     INTEGER         PRIMARY KEY,
    GPO_COL     VARCHAR(20)     NOT NULL,
    GPO_LEMA    VARCHAR(200)    NOT NULL
);

-- TABLA TIENDA
CREATE TABLE Tienda (
    TDA_NUM     INTEGER         PRIMARY KEY,
    TDA_UBI     VARCHAR(100)    NOT NULL,
    TDA_CAP     INTEGER         NOT NULL
);

-- TABLA MONITOR
CREATE TABLE Monitor (
    MON_DNI     VARCHAR(13)     PRIMARY KEY,
    MON_NOM     VARCHAR(60)     NOT NULL,
    MON_EXP     INTEGER         NOT NULL,
    GPO_CVE     INTEGER         NOT NULL,
	MON_PWD     VARCHAR(60)     NOT NULL
    FOREIGN KEY (GPO_CVE) REFERENCES Grupo(GPO_CVE)
);

-- TABLA CAMPISTA
CREATE TABLE Campista (
    CAM_INS     INTEGER         PRIMARY KEY,
    CAM_NOM     VARCHAR(40)     NOT NULL,
    CAM_APP     VARCHAR(20)     NOT NULL,
    CAM_APM     VARCHAR(20)     NOT NULL,
    CAM_EDA     INTEGER         NOT NULL,
    CAM_DIR     VARCHAR(60),
    CAM_TEL     VARCHAR(10),
    GPO_CVE     INTEGER,
    SGP_SEC     INTEGER,
    CONSTRAINT ck_cam_eda CHECK (CAM_EDA BETWEEN 5 AND 18)
);

-- TABLA SUBGRUPO 
CREATE TABLE Subgrupo (
    GPO_CVE     INTEGER         NOT NULL,
    SGP_SEC     INTEGER         NOT NULL,
    TDA_NUM     INTEGER         NOT NULL,
    SGP_REP     INTEGER,
    SGP_PTO     INTEGER         DEFAULT 0,
    PRIMARY KEY (GPO_CVE, SGP_SEC),
    FOREIGN KEY (GPO_CVE) REFERENCES Grupo(GPO_CVE),
    FOREIGN KEY (TDA_NUM) REFERENCES Tienda(TDA_NUM)
);

-- FK de Campista hacia Subgrupo
ALTER TABLE Campista
    ADD FOREIGN KEY (GPO_CVE, SGP_SEC) REFERENCES Subgrupo(GPO_CVE, SGP_SEC);

-- FK del responsable del subgrupo hacia Campista
ALTER TABLE Subgrupo
    ADD FOREIGN KEY (SGP_REP) REFERENCES Campista(CAM_INS);

-- TABLA ACTIVIDAD
CREATE TABLE Actividad (
    ACT_CVE     VARCHAR(4)      PRIMARY KEY,
    ACT_NOM     VARCHAR(40)     NOT NULL,
    ACT_DES     VARCHAR(500)    NOT NULL,
    ACT_NIV     CHAR(1)         NOT NULL,
    MON_DNI     VARCHAR(13)     NOT NULL,
    FOREIGN KEY (MON_DNI) REFERENCES Monitor(MON_DNI),
    CONSTRAINT ck_act_niv CHECK (ACT_NIV IN ('D','M','S','C'))
);

-- TABLA REALIZA_ACTIVIDAD
CREATE TABLE Realiza_Actividad (
    GPO_CVE     INTEGER         NOT NULL,
    SGP_SEC     INTEGER         NOT NULL,
    ACT_CVE     VARCHAR(4)      NOT NULL,
    CAM_RES     INTEGER         NOT NULL,
    REA_PTO     INTEGER         NOT NULL,
    REA_FEC     DATE            NOT NULL,
    PRIMARY KEY (GPO_CVE, SGP_SEC, ACT_CVE),
    FOREIGN KEY (GPO_CVE, SGP_SEC) REFERENCES Subgrupo(GPO_CVE, SGP_SEC),
    FOREIGN KEY (ACT_CVE)           REFERENCES Actividad(ACT_CVE),
    FOREIGN KEY (CAM_RES)           REFERENCES Campista(CAM_INS),
    UNIQUE (CAM_RES)
);

--==============================================================================
--                      AUDITORÍA DEL DDL
--==============================================================================
-- Proyecto:     Sistema de Gestión de Campamento
-- Base de Datos: Campamento_DB
-- Motor RDBMS:  PostgreSQL 18.x
-- Creado Por:   Aldo Uriel Becerril Martínez
-- Fecha Creación:28/04/2026
-- Versión:      1.0
--
-- Descripción:  
-- Definición del esquema físico (DDL) mediante 
-- la creación de las 7 tablas base: actividad, campista, grupo, monitor, y 
-- realiza_actividad_subgrupo. Incluye restricciones de integridad (PK, FK, UNIQUE).
--
-- HISTORIAL DE MODIFICACIONES:
-- -----------------------------------------------------------------------------
-- Fecha       | Versión | Autor       | Descripción del Cambio
-- -----------------------------------------------------------------------------
-- 26/04/2026  |  1.0    | Aldo Uriel  | Creación inicial del DDL e inserciones básicas.
-- 28/04/2026  |  1.1    | Aldo Uriel  | Optimización de llaves foráneas y revisión.
--==============================================================================

-- ============================================================
-- Inserción de datos
-- ============================================================

-- GRUPOS
INSERT INTO Grupo VALUES (101, 'Rojo',    'Nunca rendirse, siempre avanzar');
INSERT INTO Grupo VALUES (102, 'Azul',    'Unidos somos mas fuertes');
INSERT INTO Grupo VALUES (103, 'Verde',   'La naturaleza es nuestro hogar');
INSERT INTO Grupo VALUES (104, 'Amarillo','El sol brilla para todos');
INSERT INTO Grupo VALUES (105, 'Morado',  'Creatividad sin limites');

SELECT * FROM Grupo;

-- TIENDAS
INSERT INTO Tienda VALUES (1, 'Zona Norte - Sector A', 8);
INSERT INTO Tienda VALUES (2, 'Zona Norte - Sector B', 6);
INSERT INTO Tienda VALUES (3, 'Zona Sur   - Sector A', 10);
INSERT INTO Tienda VALUES (4, 'Zona Sur   - Sector B', 8);
INSERT INTO Tienda VALUES (5, 'Zona Este  - Sector A', 7);
INSERT INTO Tienda VALUES (6, 'Zona Oeste - Sector A', 9);
INSERT INTO Tienda VALUES (7, 'Zona Central',          12);

SELECT * FROM Tienda;

-- MONITORES
INSERT INTO Monitor VALUES ('PONS850312AB1', 'Carlos Ponce Solis',     5, 101, crypt('carlos123', gen_salt('bf', 8)));
INSERT INTO Monitor VALUES ('FLOI900215CD2', 'Irvin Flores Pacheco',   3, 102, crypt('irvin456', gen_salt('bf', 8)));
INSERT INTO Monitor VALUES ('MAYK950830EF3', 'Katerine Mayen Matinez', 7, 103, crypt('katerine123', gen_salt('bf', 8)));
INSERT INTO Monitor VALUES ('BEAU001120GH4', 'Aldo Becerril Martinez', 2, 104, crypt('clave456', gen_salt('bf', 8))); 
INSERT INTO Monitor VALUES ('ROLA870622IJ5', 'Laura Roque Alvarado',   9, 105, crypt('laura789', gen_salt('bf', 8)));
INSERT INTO Monitor VALUES ('GARM800101KL6', 'Mario Garcia Ruiz',      4, 101, crypt('mario123', gen_salt('bf', 8)));
INSERT INTO Monitor VALUES ('LONT781230MN7', 'Teresa Lopez Nieto',     6, 102, crypt('teresa456', gen_salt('bf', 8)));

SELECT * FROM Monitor;

-- CAMPISTAS (Insert inicial con datos de contacto básicos)
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000001,'Sofia',   'Torres',   'Mendez', 12,'Av. Reforma 10',      '5512345678');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000002,'Diego',   'Ramirez',  'Luna',   14,'Calle Juarez 5',      '5523456789');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000003,'Valeria', 'Morales',  'Vega',   11,'Av. Insurgentes 200', '5534567890');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000004,'Luis',    'Hernandez','Ortiz',  13,'Calle Hidalgo 45',    '5545678901');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000005,'Ana',     'Jimenez',  'Ruiz',   10,'Av. Universidad 80',  '5556789012');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000006,'Carlos',  'Martinez', 'Soto',   15,'Calle Morelos 12',    '5567890123');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000007,'Isabella','Garcia',   'Reyes',   9,'Av. Revolucion 33',   '5578901234');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000008,'Miguel',  'Lopez',    'Perez',  16,'Calle 5 de Mayo 7',   '5589012345');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000009,'Fernanda','Diaz',     'Castro', 12,'Av. Chapultepec 22',  '5590123456');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000010,'Emilio',  'Sanchez',  'Flores', 17,'Calle Victoria 14',   '5501234567');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000011,'Renata',  'Cruz',     'Vargas', 11,'Av. Satelite 5',       '5511223344');
INSERT INTO Campista (CAM_INS,CAM_NOM,CAM_APP,CAM_APM,CAM_EDA,CAM_DIR,CAM_TEL) VALUES (10000012,'Hector',  'Rios',     'Aguilar',13,'Calle Tepeyac 9',      '5522334455');

SELECT * FROM Campista;

-- SUBGRUPOS
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (101,1,1);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (101,2,2);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (102,1,3);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (102,2,4);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (103,1,5);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (104,1,6);
INSERT INTO Subgrupo (GPO_CVE,SGP_SEC,TDA_NUM) VALUES (105,1,7);

-- Asignar campistas a sus subgrupos
UPDATE Campista SET GPO_CVE=101, SGP_SEC=1 WHERE CAM_INS IN (10000001,10000002);
UPDATE Campista SET GPO_CVE=101, SGP_SEC=2 WHERE CAM_INS IN (10000003,10000004);
UPDATE Campista SET GPO_CVE=102, SGP_SEC=1 WHERE CAM_INS IN (10000005,10000006);
UPDATE Campista SET GPO_CVE=102, SGP_SEC=2 WHERE CAM_INS IN (10000007,10000008);
UPDATE Campista SET GPO_CVE=103, SGP_SEC=1 WHERE CAM_INS IN (10000009,10000010);
UPDATE Campista SET GPO_CVE=104, SGP_SEC=1 WHERE CAM_INS=10000011;
UPDATE Campista SET GPO_CVE=105, SGP_SEC=1 WHERE CAM_INS=10000012;

-- Asignar responsable de cada subgrupo
UPDATE Subgrupo SET SGP_REP=10000001 WHERE GPO_CVE=101 AND SGP_SEC=1;
UPDATE Subgrupo SET SGP_REP=10000003 WHERE GPO_CVE=101 AND SGP_SEC=2;
UPDATE Subgrupo SET SGP_REP=10000005 WHERE GPO_CVE=102 AND SGP_SEC=1;
UPDATE Subgrupo SET SGP_REP=10000007 WHERE GPO_CVE=102 AND SGP_SEC=2;
UPDATE Subgrupo SET SGP_REP=10000009 WHERE GPO_CVE=103 AND SGP_SEC=1;
UPDATE Subgrupo SET SGP_REP=10000011 WHERE GPO_CVE=104 AND SGP_SEC=1;
UPDATE Subgrupo SET SGP_REP=10000012 WHERE GPO_CVE=105 AND SGP_SEC=1;

SELECT * FROM Subgrupo;

-- ACTIVIDADES
INSERT INTO Actividad VALUES ('ACT1','Tiro con Arco',        'Tecnicas basicas de tiro con arco',          'D','PONS850312AB1');
INSERT INTO Actividad VALUES ('ACT2','Natacion',             'Actividad acuatica supervisada en el lago',  'M','FLOI900215CD2');
INSERT INTO Actividad VALUES ('ACT3','Senderismo',           'Caminata por rutas naturales del campamento','S','MAYK950830EF3');
INSERT INTO Actividad VALUES ('ACT4','Fogata y Campismo',    'Tecnicas de supervivencia y fogata segura',  'C','BEAU001120GH4');
INSERT INTO Actividad VALUES ('ACT5','Manualidades',         'Artesanias con materiales reciclados',       'S','ROLA870622IJ5');
INSERT INTO Actividad VALUES ('ACT6','Escalada',             'Escalada en muro con equipo de seguridad',   'D','GARM800101KL6');
INSERT INTO Actividad VALUES ('ACT7','Cocina al Aire Libre', 'Preparacion de alimentos en exterior',       'M','LONT781230MN7');

SELECT * FROM Actividad;

-- REALIZA_ACTIVIDAD
INSERT INTO Realiza_Actividad VALUES (101,1,'ACT1',10000001, 90, '2025-07-10');
INSERT INTO Realiza_Actividad VALUES (101,2,'ACT2',10000003, 70, '2025-07-11');
INSERT INTO Realiza_Actividad VALUES (102,1,'ACT3',10000005, 80, '2025-07-11');
INSERT INTO Realiza_Actividad VALUES (102,2,'ACT4',10000007, 60, '2025-07-12');
INSERT INTO Realiza_Actividad VALUES (103,1,'ACT5',10000009,100, '2025-07-12');
INSERT INTO Realiza_Actividad VALUES (104,1,'ACT6',10000011, 50, '2025-07-13');
INSERT INTO Realiza_Actividad VALUES (105,1,'ACT7',10000012, 80, '2025-07-13');

SELECT * FROM Realiza_Actividad;
SELECT * FROM Subgrupo;
--==============================================================================
--                         AUDITORÍA DEL DML
--==============================================================================
-- Proyecto:     Sistema de Gestión de Campamento
-- Creado por:   Dalia Ponce Solís e Irving Uriel Flores Pacheco
-- Fecha:        11/05/2026
-- Versión:      1.0
--
-- Descripción:  
-- Se ejecuta la inserción de registros de prueba en las 7 tablas del esquema:
-- 5 grupos, 7 tiendas, 7 monitores, 12 campistas, 7 subgrupos con asignación 
-- de responsables, y el histórico de 7 actividades realizadas.
--==============================================================================
-- HISTORIAL DE MODIFICACIONES:
-- -----------------------------------------------------------------------------
-- Fecha       | Versión | Autor                      | Descripción del Cambio
-- -----------------------------------------------------------------------------
-- 09/05/2026  |  1.2   | Dalia Ponce Solís           | Creación inicial del DDL 
--                        Irving Uriel Flores Pacheco    e inserciones básicas.
-- 09/05/2026  |  1.3   | Aldo Uriel Becerril Martinez| Cambios requeridos por el profesor


-- ============================================================
-- ROLLBACK
-- ============================================================

--DROP TABLE IF EXISTS Realiza_Actividad CASCADE;
--DROP TABLE IF EXISTS Actividad           CASCADE;
--DROP TABLE IF EXISTS Campista            CASCADE;
--DROP TABLE IF EXISTS Subgrupo            CASCADE;
--DROP TABLE IF EXISTS Monitor             CASCADE;
--DROP TABLE IF EXISTS Tienda              CASCADE;
--DROP TABLE IF EXISTS Grupo               CASCADE;