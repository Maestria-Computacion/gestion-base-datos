-- ============================================================================
-- 03_Info_Presupuestaria.sql
-- Tablas del módulo de Información Presupuestaria (IP): proyecciones,
-- configuración de reportes financieros, reporte por grupos y gastos.
--
-- Ejecutar después de 01_Base_Comun.sql (requiere estudiantes, grupo y
-- periodo_academico).
-- No incluye datos de prueba: solo estructura.
-- ============================================================================

USE `maestria-computacion`;
SET sql_notes = 0;

-- ----------------------------------------------------------------------------
-- 1. PROYECCION_ESTUDIANTE
-- Proyecciones de estudiantes por período (planeación de ingresos).
-- estudiante_id es NULL para estudiantes simulados (solo en períodos
-- PROYECCION); los campos *_simulado y los respaldos grupo_investigacion y
-- valor_en_smlv soportan ese escenario.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS proyeccion_estudiante (
    id BIGINT NOT NULL AUTO_INCREMENT,
    periodo_academico_id BIGINT NOT NULL,
    estudiante_id BIGINT NULL COMMENT 'NULL para estudiantes simulados (solo en periodos PROYECCION)',
    esta_pago TINYINT DEFAULT 0 COMMENT 'Pago simulado para proyecciones',
    porcentaje_beca DECIMAL(5,2) DEFAULT 0.00,
    aplica_votacion TINYINT DEFAULT 0,
    aplica_egresado TINYINT DEFAULT 0,
    es_simulado BOOLEAN NOT NULL DEFAULT FALSE,
    nombre_simulado VARCHAR(150) NULL,
    apellido_simulado VARCHAR(150) NULL,
    identificacion_simulada BIGINT NULL,
    grupo_investigacion VARCHAR(50) NULL COMMENT 'Respaldo persistido del grupo del estudiante (real o simulado) para periodos PROYECCION',
    valor_en_smlv INT NULL COMMENT 'Respaldo persistido de los SMLV cobrados al estudiante para periodos PROYECCION',
    PRIMARY KEY (id),
    UNIQUE KEY uk_proyeccion_est_periodo (periodo_academico_id, estudiante_id),
    CONSTRAINT fk_proyeccion_periodo FOREIGN KEY (periodo_academico_id) REFERENCES periodo_academico (id),
    CONSTRAINT fk_proyeccion_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiantes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 2. CONFIGURACION_REPORTE_FINANCIERO
-- Parámetros globales del reporte financiero por período (SMLV, costos fijos).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS configuracion_reporte_financiero (
    id BIGINT NOT NULL AUTO_INCREMENT,
    periodo_academico_id BIGINT NOT NULL,
    valor_smlv DECIMAL(15,6) NOT NULL,
    biblioteca DECIMAL(15,2) NOT NULL COMMENT 'Costo fijo por estudiante',
    recursos_computacionales DECIMAL(15,2) NOT NULL COMMENT 'Costo fijo por estudiante',
    es_reporte_final TINYINT DEFAULT 0,
    porcentaje_votacion_fijo DECIMAL(5,2) DEFAULT 0.10,
    porcentaje_egresado_fijo DECIMAL(5,2) DEFAULT 0.10,
    PRIMARY KEY (id),
    UNIQUE KEY uk_config_financiera_periodo (periodo_academico_id),
    CONSTRAINT fk_config_fin_periodo FOREIGN KEY (periodo_academico_id) REFERENCES periodo_academico (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 3. CONFIGURACION_REPORTE_GRUPOS
-- Parámetros del reporte por grupos (AUI, ítems de distribución, imprevistos).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS configuracion_reporte_grupos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    periodo_academico_id BIGINT NOT NULL,
    aui_porcentaje DECIMAL(5,4) DEFAULT 0.2200,
    excedentes_maestria DECIMAL(15,2) DEFAULT 0.00,
    item1 DECIMAL(5,4) DEFAULT 0.4000,
    item2 DECIMAL(5,4) DEFAULT 0.6000,
    imprevistos DECIMAL(5,4) DEFAULT 0.1000,
    PRIMARY KEY (id),
    UNIQUE KEY uk_config_grupos_periodo (periodo_academico_id),
    CONSTRAINT fk_config_grupos_periodo FOREIGN KEY (periodo_academico_id) REFERENCES periodo_academico (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 4. PARTICIPACION_GRUPO
-- Participación porcentual de cada grupo de investigación en el presupuesto.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS participacion_grupo (
    id BIGINT NOT NULL AUTO_INCREMENT,
    configuracion_reporte_grupos_id BIGINT NOT NULL,
    grupo_id BIGINT NOT NULL,
    porcentaje_participacion DECIMAL(5,4) DEFAULT 0.0000,
    porcentaje_primer_semestre DECIMAL(5,4) DEFAULT 0.0000,
    porcentaje_segundo_semestre DECIMAL(5,4) DEFAULT 0.0000,
    vigencias_anteriores DECIMAL(15,2) DEFAULT 0.00,
    PRIMARY KEY (id),
    UNIQUE KEY uk_participacion_grupo_config (configuracion_reporte_grupos_id, grupo_id),
    CONSTRAINT fk_part_config FOREIGN KEY (configuracion_reporte_grupos_id) REFERENCES configuracion_reporte_grupos (id),
    CONSTRAINT fk_part_grupo FOREIGN KEY (grupo_id) REFERENCES grupo (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 5. GASTO_GENERAL
-- Gastos generales de la maestría asociados a una configuración de reporte.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS gasto_general (
    id BIGINT NOT NULL AUTO_INCREMENT,
    configuracion_reporte_grupos_id BIGINT NOT NULL,
    categoria VARCHAR(255),
    descripcion VARCHAR(255),
    monto DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_gastos_config FOREIGN KEY (configuracion_reporte_grupos_id) REFERENCES configuracion_reporte_grupos (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET sql_notes = 1;
