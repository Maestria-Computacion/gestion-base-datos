-- ============================================================================
-- 04_Solicitud_Revision_Matricula.sql
-- Tipo de solicitud RE_MATR (Revisión de Matrícula), agregado por este
-- trabajo para que el estudiante pueda solicitar la revisión de su matrícula
-- financiera o académica desde el módulo de Matrícula Financiera.
--
-- Dependencias: 01_Base_Comun.sql y 02_Matricula_Financiera.sql
-- (requiere la tabla tipos_solicitudes).
-- Este script es idempotente: solo inserta si el código no existe.
-- ============================================================================

USE `maestria-computacion`;

INSERT INTO tipos_solicitudes (nombre, estado, codigo)
SELECT 'Revisión de matrícula', 'ACTIVO', 'RE_MATR'
WHERE NOT EXISTS (SELECT 1 FROM tipos_solicitudes WHERE codigo = 'RE_MATR');
