-- ============================================================================
-- 4. Matricula_Financiera.sql
-- Tablas del módulo de Matrícula Financiera (MF) y del flujo de solicitudes
-- de becas/descuentos que MF consume para la vista de detalle del estudiante.
--
-- Ejecutar después de 1, 2 y 3 (requiere estudiantes, personas).
-- No incluye datos de prueba: solo estructura y el tipo de solicitud
-- RE_MATR (Revisión de Matrícula), agregado por este trabajo.
--
-- Incluye tambien `grupo`, `periodo_academico` y `estudiantes.es_egresado_unicauca`,
-- que no forman parte del script oficial de base de datos del programa
-- (`1. SCRIPT_FINAL_BASE_DATOS_MAESTRIA_V3.sql`): `grupo` la crea Hibernate del
-- microservicio de Informacion Presupuestaria (ddl-auto), `periodo_academico`
-- la crea el script propio de Matricula Academica (fuera de este repositorio),
-- y `es_egresado_unicauca` es un atributo financiero agregado por este trabajo.
-- Se agregan aqui porque este es el primer script que las necesita por FK.
--
-- Las tablas del flujo de solicitudes (tipos_solicitudes, solicitudes,
-- solicitud_beca_descuento, solicitudes_en_comite, solicitudes_en_concejo,
-- requisitos_solicitud, documentos_requisitos_solicitud) las administra
-- ms-gestion-solicitudes (corre con ddl-auto=update); su estructura aquí
-- fue verificada contra las entidades JPA reales de ese microservicio para
-- que coincida exactamente con la tabla real, incluso si ya existe por
-- fuera de este trabajo (ver 00_README.md).
-- ============================================================================

USE `maestria-computacion`;
SET sql_notes = 0;

-- ----------------------------------------------------------------------------
-- 1. GRUPO (grupos de investigacion)
-- GTI, IDIS, GICO. Consumido por MF (grupo del estudiante) e IP (reporte por grupos).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS grupo (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='GTI, IDIS, GICO, etc';

INSERT IGNORE INTO grupo (nombre) VALUES ('GTI'), ('IDIS'), ('GICO');

-- ----------------------------------------------------------------------------
-- 2. PERIODO_ACADEMICO
-- El estado PROYECCION se agrego para el modulo de Informacion Presupuestaria
-- (permite periodos en fase de proyeccion).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS periodo_academico (
    id BIGINT NOT NULL AUTO_INCREMENT,
    tag_periodo INT NOT NULL COMMENT '1 = primer semestre, 2 = segundo semestre',
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    fecha_fin_matricula DATE NOT NULL,
    descripcion VARCHAR(255) NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' COMMENT 'ACTIVO | INACTIVO | FINALIZADO | PROYECCION',
    estudiantes_nuevos_esperados INT DEFAULT 0 COMMENT 'Cantidad de estudiantes nuevos esperados en proyeccion',
    PRIMARY KEY (id),
    UNIQUE KEY uk_periodo_tag_anio (tag_periodo, fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 3. ESTUDIANTES.ES_EGRESADO_UNICAUCA (atributo financiero agregado por MF)
-- (requiere MySQL 8.0.29+ para ADD COLUMN IF NOT EXISTS; si la BD ya tiene
-- esta columna por fuera de este trabajo, la instruccion no falla)
-- ----------------------------------------------------------------------------
ALTER TABLE estudiantes ADD COLUMN IF NOT EXISTS es_egresado_unicauca BOOLEAN NOT NULL DEFAULT FALSE;

-- ----------------------------------------------------------------------------
-- 4. MATRICULA_FINANCIERA
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
-- 5. TIPOS_SOLICITUDES
-- Catálogo de tipos de solicitud del sistema de Gestión de Solicitudes.
-- Los tipos existentes (CER_VOTO, etc.) los administra ms-gestion-solicitudes;
-- RE_MATR se agrega en el script 6 y CER_VOTO en el script 8.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tipos_solicitudes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    codigo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    estado VARCHAR(50),
    fecha_inicio TEXT NULL,
    fecha_final TEXT NULL,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 6. FLUJO DE SOLICITUDES (Becas y Descuentos)
-- id_tutor es NULL para tipos de solicitud que no requieren tutor (ej. CER_VOTO).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS solicitudes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_tipo_solicitud BIGINT NOT NULL,
    id_estudiante BIGINT NOT NULL,
    id_tutor BIGINT NULL,
    id_director BIGINT NULL,
    estado VARCHAR(50) NULL,
    requiere_firma_director BOOLEAN NOT NULL DEFAULT FALSE,
    documento_firmado MEDIUMTEXT NULL,
    radicado VARCHAR(10) NULL,
    comentario TEXT NULL,
    id_revisor BIGINT NULL,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_sol_tipo FOREIGN KEY (id_tipo_solicitud) REFERENCES tipos_solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitud_beca_descuento (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_solicitud BIGINT NOT NULL,
    tipo VARCHAR(200) NOT NULL,
    motivo TEXT NULL,
    formato_solicitud MEDIUMTEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_sbd_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitudes_en_comite (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_solicitud BIGINT NOT NULL,
    avalado_comite VARCHAR(2) NULL,
    concepto_comite TEXT NULL,
    numero_acta VARCHAR(200) NULL,
    fecha_aval DATE NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_comite_solicitud (id_solicitud),
    CONSTRAINT fk_comite_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS solicitudes_en_concejo (
    id BIGINT NOT NULL AUTO_INCREMENT,
    id_solicitud BIGINT NOT NULL,
    avalado_concejo VARCHAR(2) NULL,
    concepto_concejo TEXT NULL,
    numero_acta VARCHAR(200) NULL,
    fecha_aval DATE NULL,
    porcentaje DECIMAL(5,2) NULL,
    resolucion VARCHAR(100) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_concejo_solicitud (id_solicitud),
    CONSTRAINT fk_sol_concejo_id_sol FOREIGN KEY (id_solicitud) REFERENCES solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 7. REQUISITOS_SOLICITUD
-- Mensaje informativo que ve el estudiante antes de radicar una solicitud
-- (título, descripción, artículo y consideraciones) por tipo de solicitud.
-- Los flujos RE_MATR y CER_VOTO usan esta tabla para mostrar el mensaje previo.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS requisitos_solicitud (
    id BIGINT NOT NULL AUTO_INCREMENT,
    titulo_documento TEXT NOT NULL,
    descripcion TEXT NULL,
    articulo TEXT NULL,
    tener_en_cuenta TEXT NULL,
    id_tipo_solicitud BIGINT NOT NULL,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_req_sol_tipo FOREIGN KEY (id_tipo_solicitud) REFERENCES tipos_solicitudes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 8. DOCUMENTOS_REQUISITOS_SOLICITUD
-- Documentos que deben adjuntarse por requisito de solicitud.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS documentos_requisitos_solicitud (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre_documento TEXT NOT NULL,
    id_requisito_solicitud BIGINT NOT NULL,
    adjuntar_documento BOOLEAN NOT NULL DEFAULT TRUE,
    abreviatura_documento VARCHAR(100) NULL,
    enlace BOOLEAN NULL DEFAULT FALSE,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_doc_req_sol FOREIGN KEY (id_requisito_solicitud) REFERENCES requisitos_solicitud (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET sql_notes = 1;
