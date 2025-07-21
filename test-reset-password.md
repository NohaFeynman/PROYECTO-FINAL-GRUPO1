# Prueba del Flujo de Restablecimiento de Contraseña

## 📋 Pasos para probar:

### 1. **Preparación**
- Asegurar que tienes un usuario registrado en la base de datos
- Verificar que el servidor está ejecutándose
- Tener acceso a los logs de la consola

### 2. **Iniciar Recuperación de Contraseña**
```
URL: http://localhost:8080/WebProyecto/recuperarPassword.jsp
```
- Ingresar un correo electrónico válido que existe en la BD
- Hacer clic en "Enviar código"

### 3. **Verificar Logs (EnviarCodigoRecuperacionServlet)**
Buscar en la consola estos mensajes:
```
🔐 EnviarCodigoRecuperacionServlet - Iniciando proceso
✅ Usuario encontrado: [correo]
✅ Código generado: [código]
✅ Código enviado por correo a: [correo]
```

### 4. **Acceder a Restablecer Contraseña**
```
URL: http://localhost:8080/WebProyecto/restablecerPassword.jsp?correo=[tu-correo]
```
- Ingresar el código de 6 caracteres (visible en logs)
- Ingresar nueva contraseña (debe cumplir requisitos)
- Confirmar contraseña
- Hacer clic en "Restablecer Contraseña"

### 5. **Verificar Logs (RestablecerPasswordServlet)**
Buscar estos mensajes en orden:
```
🔐 RestablecerPasswordServlet - Iniciando proceso
📥 Parámetros recibidos:
   - Correo: [correo]
   - Código: [código]
   - Password length: [número]
   - Confirm password length: [número]
✅ Usuario encontrado: [id]
✅ Código válido, procediendo a actualizar contraseña
🔐 CodigoDao.actualizarContrasena - Iniciando para usuario ID: [id]
🔑 Hash generado para contraseña (primeros 10 caracteres): [hash]...
✅ Filas afectadas en actualización de contraseña: 1
✅ Contraseña actualizada para usuario ID: [id]
✅ Código de recuperación eliminado tras uso exitoso
```

### 6. **Verificar Éxito**
- Debería aparecer mensaje de éxito o redirección
- La respuesta del servidor debe ser "success - Contraseña restablecida exitosamente"

### 7. **Probar Login con Nueva Contraseña**
```
URL: http://localhost:8080/WebProyecto/LoginServlet
```
- Usar el mismo correo
- Usar la nueva contraseña establecida
- Verificar que puede iniciar sesión correctamente

## 🔍 Posibles Problemas y Soluciones:

### ❌ "Usuario no encontrado"
- Verificar que el correo existe en la tabla `credencial`
- Revisar que hay un usuario asociado en la tabla `usuario`

### ❌ "Código inválido o expirado"
- El código expira en 5 minutos
- Verificar que el código se ingresó correctamente (mayúsculas/minúsculas)
- Revisar logs para ver el código generado

### ❌ "No se actualizó ninguna fila"
- Verificar que el usuario existe en la tabla `credencial`
- Revisar la consulta SQL en los logs

### ❌ Error de conexión a BD
- Verificar configuración de base de datos en BaseDao
- Asegurar que MySQL está ejecutándose
- Verificar credenciales de conexión

## 📊 Consultas SQL para Verificar:

### Verificar usuario existe:
```sql
SELECT u.idusuario, u.nombre, c.correo 
FROM usuario u 
JOIN credencial c ON u.idusuario = c.idusuario 
WHERE c.correo = 'tu-correo@ejemplo.com';
```

### Verificar código generado:
```sql
SELECT cv.codigo, cv.fecha_creacion, cv.fecha_expiracion, cv.idusuario
FROM codigo_verificacion cv
JOIN usuario u ON cv.idusuario = u.idusuario
JOIN credencial c ON u.idusuario = c.idusuario
WHERE c.correo = 'tu-correo@ejemplo.com'
ORDER BY cv.fecha_creacion DESC LIMIT 1;
```

### Verificar contraseña actualizada:
```sql
SELECT c.correo, 
       LEFT(c.contrasenha, 10) as hash_inicio,
       LENGTH(c.contrasenha) as hash_length
FROM credencial c 
WHERE c.correo = 'tu-correo@ejemplo.com';
```

## ✅ Criterios de Éxito:
1. ✅ El código se genera y se envía
2. ✅ El código se puede verificar correctamente
3. ✅ La contraseña se actualiza en la base de datos
4. ✅ El código se elimina después del uso
5. ✅ Se puede hacer login con la nueva contraseña
6. ✅ Los logs muestran el flujo completo sin errores
