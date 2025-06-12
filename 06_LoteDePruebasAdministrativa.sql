USE COM2900G13;
GO

/* ===================== LIMPIEZA COMPLETA ===================== */
DELETE FROM administracion.GrupoFamiliar;
DELETE FROM administracion.Invitado;
DELETE FROM administracion.Socio;
DELETE FROM administracion.Profesor;
DELETE FROM administracion.CategoriaSocio;
DELETE FROM administracion.Persona;
GO

/* ===================== INSERTAR PERSONAS BASE ===================== */
IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = '55666777')
BEGIN
    EXEC administracion.GestionarPersona
        @nombre = 'Tomas',
        @apellido = 'Borja',
        @dni = '55666777',
        @email = 'tomas.borja@email.com',
        @fecha_nacimiento = '2024-10-25',
        @domicilio = 'Av. San Martin 3200',
        @tel_contacto = '1234227890',
        @tel_emergencia = '0987658821',
        @operacion = 'Insertar';
END
GO

IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = '99888777')
BEGIN
    EXEC administracion.GestionarPersona
        @nombre = 'Jose',
        @apellido = 'Suarez',
        @dni = '99888777',
        @email = 'juan.perez@email.com',
        @fecha_nacimiento = '1965-10-25',
        @domicilio = 'Av. San Martin 3499',
        @tel_contacto = '1234567990',
        @tel_emergencia = '0987699321',
        @operacion = 'Insertar';
END
GO

/* ===================== INSERTAR CATEGORÍAS ===================== */
EXEC administracion.GestionarCategoriaSocio @nombre = 'Menor', @edad_desde = 0, @edad_hasta = 12, @costo_membresia = 700.00, @vigencia = '2025-12-31', @operacion = 'Insertar';
EXEC administracion.GestionarCategoriaSocio @nombre = 'Cadete', @edad_desde = 13, @edad_hasta = 17, @costo_membresia = 800.00, @vigencia = '2025-12-31', @operacion = 'Insertar';
EXEC administracion.GestionarCategoriaSocio @nombre = 'Mayor', @edad_desde = 18, @edad_hasta = 150, @costo_membresia = 1000.00, @vigencia = '2025-12-31', @operacion = 'Insertar';
GO

/* ===================== INSERTAR SOCIOS ===================== */
-- Responsable grupo A
EXEC administracion.GestionarSocio
    @nombre = 'Francisco', @apellido = 'Vignardel', @dni = '45778667',
    @email = 'francisco.vignardel@email.com', @fecha_nacimiento = '2004-04-10',
    @domicilio = 'Av. Gral. Mosconi 2345', @tel_contacto = '1231233234',
    @tel_emergencia = '6624324321', @categoria = 'Mayor',
    @nro_socio = 'SOC1002', @obra_social = 'OSPOCE', @nro_obra_social = '654321',
    @saldo = 0, @operacion = 'Insertar';
GO

-- Responsable grupo B
EXEC administracion.GestionarSocio
    @nombre = 'Juan', @apellido = 'Perez', @dni = '33444555',
    @email = 'juan.perez@email.com', @fecha_nacimiento = '2004-04-10',
    @domicilio = 'Av. Crovara 2345', @tel_contacto = '3331233234',
    @tel_emergencia = '6624324388', @categoria = 'Cadete',
    @nro_socio = 'SOC1003', @obra_social = 'VITA', @nro_obra_social = '654331',
    @saldo = 0, @operacion = 'Insertar';
GO

-- Grupo A - miembro
EXEC administracion.GestionarSocio
    @nombre = 'Mariana', @apellido = 'Vignardel', @dni = '40505050',
    @email = 'mariana.vignardel@email.com', @fecha_nacimiento = '2012-09-12',
    @domicilio = 'Av. Gral. Mosconi 2345', @tel_contacto = '1112223333',
    @tel_emergencia = '4445556666', @categoria = 'Cadete',
    @nro_socio = 'SOC1004', @obra_social = 'OSPOCE', @nro_obra_social = '987654',
    @saldo = 0, @operacion = 'Insertar';
GO

-- Grupo B - miembro
EXEC administracion.GestionarSocio
    @nombre = 'Camila', @apellido = 'Perez', @dni = '40606060',
    @email = 'camila.perez@email.com', @fecha_nacimiento = '2010-11-25',
    @domicilio = 'Av. Crovara 2345', @tel_contacto = '2223334444',
    @tel_emergencia = '7778889999', @categoria = 'Cadete',
    @nro_socio = 'SOC1005', @obra_social = 'VITA', @nro_obra_social = '112233',
    @saldo = 0, @operacion = 'Insertar';
GO

-- Sin grupo familiar
EXEC administracion.GestionarSocio
    @nombre = 'Luciano', @apellido = 'Costa', @dni = '40707070',
    @email = 'luciano.costa@email.com', @fecha_nacimiento = '1995-05-15',
    @domicilio = 'Calle Falsa 123', @tel_contacto = '5556667777',
    @tel_emergencia = '1112223333', @categoria = 'Mayor',
    @nro_socio = 'SOC1006', @obra_social = 'OSDE', @nro_obra_social = '445566',
    @saldo = 0, @operacion = 'Insertar';
GO

/* ===================== INSERTAR PROFESOR ===================== */
IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = '34567890')
BEGIN
    EXEC administracion.GestionarProfesor
        @nombre = 'Ana', @apellido = 'García', @dni = '34567890',
        @email = 'ana.garcia@email.com', @fecha_nacimiento = '1990-08-15',
        @domicilio = 'Av. Urquiza 8392', @tel_contacto = '1112223333',
        @tel_emergencia = '3332221111', @operacion = 'Insertar';
END
ELSE IF NOT EXISTS (
    SELECT 1 FROM administracion.Profesor P
    JOIN administracion.Persona PE ON P.id_persona = PE.id_persona
    WHERE PE.dni = '34567890'
)
BEGIN
    EXEC administracion.GestionarProfesor
        @nombre = 'Ana', @apellido = 'García', @dni = '34567890',
        @email = 'ana.garcia@email.com', @fecha_nacimiento = '1990-08-15',
        @domicilio = 'Av. Urquiza 8392', @tel_contacto = '1112223333',
        @tel_emergencia = '3332221111', @operacion = 'Insertar';
END
GO

/* ===================== INSERTAR INVITADO ===================== */
EXEC administracion.GestionarInvitado
    @dni_socio = '45778667',
    @dni_invitado = '46501934',
    @nombre = 'Lucia',
    @apellido = 'De Titto',
    @email = 'ldetitto10@email.com',
    @domicilio = 'Av. Crovara 2345',
    @operacion = 'Insertar';
GO

/* ===================== GRUPOS FAMILIARES ===================== */
-- Grupo A
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '40505050', -- Mariana
    @dni_socio_rp = '45778667', -- Francisco
    @operacion = 'Insertar';
GO

-- Grupo B
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '40606060', -- Camila
    @dni_socio_rp = '33444555', -- Juan
    @operacion = 'Insertar';
GO

/* ===================== VERIFICACIÓN FINAL ===================== */
SELECT * FROM administracion.Persona;
SELECT * FROM administracion.Socio;
SELECT * FROM administracion.CategoriaSocio;
SELECT * FROM administracion.Profesor;
SELECT * FROM administracion.Invitado;
SELECT * FROM administracion.GrupoFamiliar;


