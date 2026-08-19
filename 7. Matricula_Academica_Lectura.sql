-- ============================================================================
-- 05_Matricula_Academica_Lectura.sql
-- Tablas del módulo de Matrícula Académica que el módulo de Matrícula
-- Financiera (MF) LEE (solo consulta) para:
--   * la tarjeta "Materias Matriculadas" de la vista de detalle del estudiante, y
--   * el Reporte Centro Postgrados.
--
-- Estas tablas pertenecen al módulo de Matrícula Académica (fuera del alcance
-- de este trabajo), pero DEBEN existir para que MF funcione. Se incluyen aquí
-- con las columnas mínimas que las consultas de MF utilizan.
--
-- Ejecutar después de 01_Base_Comun.sql (requiere estudiantes y personas).
-- ============================================================================

USE `maestria-computacion`;
SET sql_notes = 0;

-- ----------------------------------------------------------------------------
-- 1. ASIGNATURAS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS asignaturas (
    id BIGINT NOT NULL AUTO_INCREMENT,
    codigo_asignatura BIGINT NULL DEFAULT NULL,
    contenido_asignatura VARCHAR(255) NULL DEFAULT NULL,
    creditos INT NULL DEFAULT NULL,
    estado_asignatura BIT(1) NULL DEFAULT NULL,
    fecha_aprobacion DATETIME(6) NULL DEFAULT NULL,
    horas_no_presencial INT NULL DEFAULT NULL,
    horas_presencial INT NULL DEFAULT NULL,
    horas_total INT NULL DEFAULT NULL,
    nombre_asignatura VARCHAR(255) NULL DEFAULT NULL,
    objetivo_asignatura VARCHAR(255) NULL DEFAULT NULL,
    tipo_asignatura VARCHAR(255) NULL DEFAULT NULL,
    area_formacion BIGINT NULL DEFAULT NULL,
    contenido_programatico TEXT NULL DEFAULT NULL,
    lineas_investigacion BIGINT NULL DEFAULT NULL,
    microcurriculo BIGINT NULL DEFAULT NULL,
    oficio_facultad BIGINT NULL DEFAULT NULL,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 2. CURSOS
-- (incluye la columna id_asignatura agregada para el módulo de matrícula académica)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cursos (
    id INT AUTO_INCREMENT NOT NULL,
    idmatricula INT NULL,
    grupocurso VARCHAR(2) NOT NULL,
    periodocurso INT NULL,
    aniocurso INT NULL,
    horariocurso VARCHAR(20),
    saloncurso VARCHAR(10),
    estado BOOLEAN,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE cursos ADD COLUMN IF NOT EXISTS id_asignatura BIGINT NULL;
ALTER TABLE cursos ADD COLUMN IF NOT EXISTS periodo_id BIGINT NULL;

-- ----------------------------------------------------------------------------
-- 3. DOCENTES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS docentes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(255) NULL DEFAULT NULL,
    departamento VARCHAR(255) NULL DEFAULT NULL,
    escalafon VARCHAR(255) NULL DEFAULT NULL,
    estado VARCHAR(255) NULL DEFAULT NULL,
    facultad VARCHAR(255) NULL DEFAULT NULL,
    observacion VARCHAR(255) NULL DEFAULT NULL,
    tipo_vinculacion VARCHAR(255) NULL DEFAULT NULL,
    id_persona BIGINT NULL DEFAULT NULL,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 4. MATRICULAS (académicas)
-- (incluye las columnas agregadas que MF consulta: id_curso, id_periodo,
--  estado_matricula, observacion)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS matriculas (
    id INT NOT NULL,
    id_estudiante BIGINT NOT NULL,
    periodo INT NOT NULL,
    anio INT NOT NULL,
    estado BOOLEAN,
    usuario_creacion INT NOT NULL DEFAULT 1 CHECK (usuario_creacion > 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificacion INT NOT NULL DEFAULT 1 CHECK (usuario_modificacion > 0),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE matriculas MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT;
ALTER TABLE matriculas ADD COLUMN IF NOT EXISTS id_curso INT NULL;
ALTER TABLE matriculas ADD COLUMN IF NOT EXISTS id_periodo BIGINT NULL;
ALTER TABLE matriculas ADD COLUMN IF NOT EXISTS estado_matricula VARCHAR(50) NULL;
ALTER TABLE matriculas ADD COLUMN IF NOT EXISTS observacion VARCHAR(255) NULL;

-- ----------------------------------------------------------------------------
-- 5. CURSO_DOCENTE (asignación docente a cursos)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS curso_docente (
    id_curso INT NOT NULL,
    id_docente BIGINT NOT NULL,
    PRIMARY KEY (id_curso, id_docente),
    CONSTRAINT fk_cd_curso FOREIGN KEY (id_curso) REFERENCES cursos (id),
    CONSTRAINT fk_cd_docente FOREIGN KEY (id_docente) REFERENCES docentes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET sql_notes = 1;
