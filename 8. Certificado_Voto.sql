-- ============================================================================
-- 06_Solicitud_Certificado_Voto.sql
-- Tipo de solicitud CER_VOTO (Certificado de Votación), administrado por
-- ms-gestion-solicitudes y consumido por Matrícula Financiera para resolver
-- el descuento por votación en la vista de detalle del estudiante (MF NO lo
-- toma de la tabla descuentos: lo resuelve verificando si el estudiante tiene
-- una solicitud CER_VOTO en estado APROBADA).
--
-- Dependencias: 01_Base_Comun.sql y 02_Matricula_Financiera.sql
-- (requiere las tablas tipos_solicitudes, requisitos_solicitud y
-- documentos_requisitos_solicitud).
-- Este script es idempotente: solo inserta si el código/documento no existe.
-- Basado en el script de referencia
-- ms-maestriacomputacion-back-info-presupuestaria/Scripts/Base/4. Script_Solicitud_Certificado_Voto.sql
-- ============================================================================

USE `maestria-computacion`;

-- 1. Tipo de solicitud CER_VOTO (Certificado de Votación)
INSERT INTO tipos_solicitudes (nombre, estado, codigo)
SELECT 'Registro de certificado de votación', 'ACTIVO', 'CER_VOTO'
WHERE NOT EXISTS (SELECT 1 FROM tipos_solicitudes WHERE codigo = 'CER_VOTO');

-- 2. Mensaje informativo (requisitos_solicitud) que ve el estudiante antes
--    de radicar la solicitud.
INSERT INTO requisitos_solicitud (titulo_documento, descripcion, id_tipo_solicitud)
SELECT 'Documentos requeridos para solicitar el registro del certificado de votación:',
       NULL,
       (SELECT id FROM tipos_solicitudes WHERE codigo = 'CER_VOTO')
WHERE NOT EXISTS (SELECT 1 FROM requisitos_solicitud
                  WHERE id_tipo_solicitud = (SELECT id FROM tipos_solicitudes WHERE codigo = 'CER_VOTO'));

-- 3. Documentos requeridos
INSERT INTO documentos_requisitos_solicitud (nombre_documento, id_requisito_solicitud, adjuntar_documento, abreviatura_documento, enlace)
SELECT 'Certificado de votación', r.id, TRUE, 'Certificado de votación', FALSE
FROM requisitos_solicitud r
WHERE r.id_tipo_solicitud = (SELECT id FROM tipos_solicitudes WHERE codigo = 'CER_VOTO')
  AND NOT EXISTS (
      SELECT 1 FROM documentos_requisitos_solicitud d
      WHERE d.id_requisito_solicitud = r.id AND d.nombre_documento = 'Certificado de votación'
  );

INSERT INTO documentos_requisitos_solicitud (nombre_documento, id_requisito_solicitud, adjuntar_documento, abreviatura_documento, enlace)
SELECT 'Copia de la cédula de ciudadanía por ambos lados', r.id, TRUE, 'Copia Cédula', FALSE
FROM requisitos_solicitud r
WHERE r.id_tipo_solicitud = (SELECT id FROM tipos_solicitudes WHERE codigo = 'CER_VOTO')
  AND NOT EXISTS (
      SELECT 1 FROM documentos_requisitos_solicitud d
      WHERE d.id_requisito_solicitud = r.id AND d.nombre_documento = 'Copia de la cédula de ciudadanía por ambos lados'
  );
