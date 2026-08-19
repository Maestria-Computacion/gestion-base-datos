-- ============================================================================
-- 02_Matricula_Financiera.sql
-- Tablas del módulo de Matrícula Financiera (MF) y del flujo de solicitudes
-- de becas/descuentos que MF consume para la vista de detalle del estudiante.
--
-- Ejecutar después de 01_Base_Comun.sql (requiere estudiantes, grupo,
-- periodo_academico y personas).
-- No incluye datos de prueba: solo estructura y el tipo de solicitud
-- RE_MATR (Revisión de Matrícula), agregado por este trabajo.
-- ============================================================================

USE `maestria-computacion`;
SET sql_notes = 0;

-- ----------------------------------------------------------------------------
-- 1. MATRICULA_FINANCIERA
-- Fuente de verdad del estado de pago real y del grupo asignado por período.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS matricula_financiera (
    id BIGINT NOT NULL AUTO_INCREMENT,
    estudiante_id BIGINT NOT NULL,
    periodo_id BIGINT NOT NULL,
    grupo_id BIGINT NULL,
    esta_pago BOOLEAN DEFAULT FALSE,
    fecha_pago DATETIME NULL,
    referencia_pago VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_estudiante_periodo_pago (estudiante_id, periodo_id),
    CONSTRAINT fk_mat_fin_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiantes (id),
    CONSTRAINT fk_mat_fin_periodo FOREIGN KEY (periodo_id) REFERENCES periodo_academico (id),
    CONSTRAINT fk_mat_fin_grupo FOREIGN KEY (grupo_id) REFERENCES grupo (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Estado de pago real y grupo asignado';

-- ----------------------------------------------------------------------------
-- 2. TIPOS_SOLICITUDES
-- Catálogo de tipos de solicitud del sistema de Gestión de Solicitudes.
-- Los tipos existentes (CER_VOTO, etc.) los administra ms-gestion-solicitudes;
-- RE_MATR se agrega en el script 04.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tipos_solicitudes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    codigo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    estado VARCHAR(50),
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 3. FLUJO DE SOLICITUDES (Becas y Descuentos)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS solicitudes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_tipo_solicitud BIGINT NOT NULL,
    id_estudiante BIGINT NOT NULL,
    id_tutor BIGINT NULL,
    estado VARCHAR(50) NULL,
    radicado VARCHAR(50) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_sol_tipo FOREIGN KEY (id_tipo_solicitud) REFERENCES tipos_solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitud_beca_descuento (
    id_solicitud BIGINT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    motivo VARCHAR(255) NULL,
    PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_sbd_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitudes_en_comite (
    id_solicitud BIGINT NOT NULL,
    avalado_comite VARCHAR(2) NULL,
    concepto_comite VARCHAR(255) NULL,
    PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_comite_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitudes_en_concejo (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_solicitud BIGINT NOT NULL,
    porcentaje DECIMAL(5,2) NULL,
    avalado_concejo VARCHAR(2) NULL,
    resolucion VARCHAR(100) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_sol_concejo_id_sol FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET sql_notes = 1;
