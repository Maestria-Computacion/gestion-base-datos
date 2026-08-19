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

-- 1. Tipo de solicitud RE_MATR (Revisión de Matrícula)
INSERT INTO tipos_solicitudes (nombre, estado, codigo)
SELECT 'Revisión de matrícula', 'ACTIVO', 'RE_MATR'
WHERE NOT EXISTS (SELECT 1 FROM tipos_solicitudes WHERE codigo = 'RE_MATR');

-- 2. Mensaje informativo (requisitos_solicitud) que ve el estudiante antes
--    de radicar la solicitud: título y consideraciones previas.
--    La tabla requisitos_solicitud se crea en el script 02.
INSERT INTO requisitos_solicitud (titulo_documento, descripcion, articulo, tener_en_cuenta, id_tipo_solicitud)
SELECT 'Consideraciones importantes antes de solicitar una revisión:',
       'I. Antes de solicitar una revisión, es necesario verificar que toda la información en el apartado "MATRÍCULAS" sea correcta. II. Si la matrícula aún no ha sido generada y se considera que esto es un error, se puede solicitar una revisión. III. En caso de identificar un error en la matrícula académica o financiera, se puede proceder con la solicitud de revisión.',
       NULL,
       NULL,
       (SELECT id FROM tipos_solicitudes WHERE codigo = 'RE_MATR')
WHERE NOT EXISTS (SELECT 1 FROM requisitos_solicitud
                  WHERE id_tipo_solicitud = (SELECT id FROM tipos_solicitudes WHERE codigo = 'RE_MATR'));
