package com.example.webproyecto.servlets;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.daos.CredencialDao;
import com.example.webproyecto.daos.DistritoDao;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.utils.MailSender;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet(name = "CredencialRegistroServlet", urlPatterns = {"/registro"})
public class CredencialRegistroServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🔧 CredencialRegistroServlet - doGet iniciado");
        
        // Limpiar cualquier sesión de proceso de registro anterior
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Limpiar atributos relacionados con procesos de registro anteriores
            session.removeAttribute("correoVerificacion");
            session.removeAttribute("correoRecuperacion");
            session.removeAttribute("correoCoordinador");
            session.removeAttribute("iniciarTimer");
            session.removeAttribute("registroEnProceso"); // Nuevo atributo para control
            System.out.println("🧹 Sesión anterior limpiada para nuevo proceso de registro");
        }
        
        try {
            DistritoDao distritoDao = new DistritoDao();
            System.out.println("✅ DistritoDao creado");
            
            var distritos = distritoDao.listarDistritos();
            System.out.println("📋 Distritos cargados: " + (distritos != null ? distritos.size() : "null"));
            
            if (distritos != null && !distritos.isEmpty()) {
                for (int i = 0; i < Math.min(3, distritos.size()); i++) {
                    var distrito = distritos.get(i);
                    System.out.println("   - Distrito " + (i+1) + ": ID=" + distrito.getIdDistrito() + ", Nombre=" + distrito.getNombreDistrito());
                }
            } else {
                System.out.println("❌ No se cargaron distritos o la lista está vacía");
            }
            
            request.setAttribute("distritos", distritos);
            System.out.println("✅ Atributo 'distritos' establecido en request");
            
        } catch (Exception e) {
            System.err.println("❌ Error al cargar distritos: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar distritos: " + e.getMessage());
        }
        
        System.out.println("🔄 Redirigiendo a registro.jsp");
        request.getRequestDispatcher("registro.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🔧 CredencialRegistroServlet - Procesando registro");
        
        // Debug: Imprimir todos los parámetros recibidos
        System.out.println("📋 Parámetros recibidos:");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println("   - " + key + ": " + String.join(", ", values));
        });
        
        // Recoger parámetros con nombres correctos del JSP
        String nombre = request.getParameter("nombre");
        String apellidoPaterno = request.getParameter("apellidopaterno"); // Corregido
        String apellidoMaterno = request.getParameter("apellidomaterno"); // Corregido
        String dni = request.getParameter("dni");
        String direccion = request.getParameter("direccion");
        String idDistritoStr = request.getParameter("idDistrito"); // Corregido
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        
        System.out.println("✅ Datos procesados:");
        System.out.println("   - Nombre: " + nombre);
        System.out.println("   - Apellido Paterno: " + apellidoPaterno);
        System.out.println("   - Apellido Materno: " + apellidoMaterno);
        System.out.println("   - DNI: " + dni);
        System.out.println("   - Dirección: " + direccion);
        System.out.println("   - ID Distrito: " + idDistritoStr);
        System.out.println("   - Correo: " + correo);
        System.out.println("   - Password: " + (password != null ? "***" : "null"));
        
        // Validaciones básicas
        if (nombre == null || apellidoPaterno == null || apellidoMaterno == null || 
            dni == null || direccion == null || idDistritoStr == null || correo == null || password == null ||
            nombre.trim().isEmpty() || apellidoPaterno.trim().isEmpty() || apellidoMaterno.trim().isEmpty() ||
            dni.trim().isEmpty() || direccion.trim().isEmpty() || idDistritoStr.trim().isEmpty() ||
            correo.trim().isEmpty() || password.trim().isEmpty()) {
            
            System.out.println("❌ Error: Faltan campos obligatorios");
            request.setAttribute("error", "Todos los campos son obligatorios");
            DistritoDao distritoDao = new DistritoDao();
            request.setAttribute("distritos", distritoDao.listarDistritos());
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }
        
        int idDistrito;
        try {
            idDistrito = Integer.parseInt(idDistritoStr);
        } catch (NumberFormatException e) {
            System.out.println("❌ Error: ID Distrito no válido: " + idDistritoStr);
            request.setAttribute("error", "Distrito seleccionado no válido");
            DistritoDao distritoDao = new DistritoDao();
            request.setAttribute("distritos", distritoDao.listarDistritos());
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre.trim());
        usuario.setApellidopaterno(apellidoPaterno.trim());
        usuario.setApellidomaterno(apellidoMaterno.trim());
        usuario.setDni(dni.trim());
        usuario.setDireccion(direccion.trim());
        usuario.setIdDistrito(idDistrito);
        usuario.setIdRol(3); // Rol encuestador por defecto
        usuario.setIdEstado(1); // Estado pendiente de verificación

        CredencialDao credencialDao = new CredencialDao();
        UsuarioDao usuarioDao = new UsuarioDao();

        try {
            // Verificar si el correo ya existe
            if (credencialDao.existeCorreo(correo)) {
                System.out.println("⚠️ Correo ya registrado: " + correo);
                
                // Verificar el estado del usuario con este correo
                Integer estadoUsuario = credencialDao.obtenerEstadoUsuarioPorCorreo(correo);
                System.out.println("📊 Estado del usuario: " + estadoUsuario);
                
                if (estadoUsuario != null && estadoUsuario == 1) {
                    // Usuario pendiente de verificación
                    System.out.println("🔄 Usuario pendiente de verificación detectado");
                    
                    // Verificar si ya hay un proceso en curso para evitar re-envíos
                    HttpSession session = request.getSession();
                    String registroEnProceso = (String) session.getAttribute("registroEnProceso");
                    
                    if (correo.equals(registroEnProceso)) {
                        // Ya hay un proceso en curso para este correo - solo redirigir sin enviar nuevo código
                        System.out.println("� Proceso ya en curso para " + correo + " - no re-enviar código");
                        session.setAttribute("correoVerificacion", correo);
                        request.setAttribute("correo", correo);
                        request.setAttribute("info", "Ya tienes un proceso de verificación en curso. Revisa tu correo o usa el botón reenviar si es necesario.");
                        request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
                        return;
                    }
                    
                    // Marcar que hay un proceso en curso
                    session.setAttribute("registroEnProceso", correo);
                    
                    // Generar nuevo código de verificación solo si no hay proceso en curso
                    String nuevoCodigoVerificacion = com.example.webproyecto.utils.CodeGenerator.generator();
                    CodigoDao codigoDao = new CodigoDao();
                    
                    // Eliminar códigos anteriores y guardar el nuevo
                    codigoDao.eliminarCodigosPorCorreo(correo);
                    boolean codigoGuardado = codigoDao.guardarCodigo(correo, nuevoCodigoVerificacion);
                    
                    if (codigoGuardado) {
                        // Enviar nuevo código por correo
                        boolean correoEnviado = false;
                        try {
                            String asunto = "Código de verificación - ONU Mujeres";
                            String mensaje = "¡Hola " + nombre + "!\n\n" +
                                            "Tu código de verificación es: " + nuevoCodigoVerificacion + "\n\n" +
                                            "IMPORTANTE: El código contiene números y letras (ejemplo: A1B2C3)\n\n" +
                                            "Por favor, ingresa este código en la página de verificación para completar tu registro.\n\n" +
                                            "Este código es válido por 5 minutos.\n\n" +
                                            "Saludos,\n" +
                                            "Equipo ONU Mujeres";
                            
                            MailSender.sendEmail(correo, asunto, mensaje);
                            correoEnviado = true;
                            System.out.println("✅ Nuevo código de verificación enviado a: " + correo);
                        } catch (Exception emailException) {
                            System.err.println("❌ Error al enviar nuevo código: " + emailException.getMessage());
                        }
                        
                        // Debug en consola
                        System.out.println("=== NUEVO CÓDIGO DE VERIFICACIÓN ===");
                        System.out.println("Correo: " + correo);
                        System.out.println("Usuario: " + nombre);
                        System.out.println("Código: " + nuevoCodigoVerificacion);
                        System.out.println("Enviado por email: " + (correoEnviado ? "SÍ ✅" : "NO ❌"));
                        
                        // Redirigir a verificación
                        session.setAttribute("correoVerificacion", correo);
                        request.setAttribute("correo", correo);
                        request.setAttribute("iniciarTimer", true);
                        request.setAttribute("info", "Tu cuenta ya existe pero está pendiente de verificación. Hemos enviado un nuevo código a tu correo.");
                        request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
                        return;
                    }
                }
                
                // Para cualquier otro caso, mostrar error estándar
                System.out.println("❌ Error: Correo ya registrado y activo: " + correo);
                request.setAttribute("error", "El correo ya está registrado. Si olvidaste tu contraseña, usa la opción de recuperación.");
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.getRequestDispatcher("registro.jsp").forward(request, response);
                return;
            }

            // Verificar si el DNI ya existe
            if (usuarioDao.existeDni(dni)) {
                System.out.println("❌ Error: DNI ya registrado: " + dni);
                request.setAttribute("error", "El DNI ya está registrado");
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.getRequestDispatcher("registro.jsp").forward(request, response);
                return;
            }

            // Insertar usuario y obtener su id
            System.out.println("📝 Insertando usuario en la base de datos...");
            int idUsuario = credencialDao.insertarUsuarioYObtenerId(usuario);
            if (idUsuario == -1) {
                System.out.println("❌ Error: No se pudo insertar el usuario");
                request.setAttribute("error", "Error al registrar usuario.");
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.getRequestDispatcher("registro.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Usuario insertado con ID: " + idUsuario);

            // Insertar credencial con la contraseña proporcionada
            System.out.println("🔐 Insertando credenciales...");
            credencialDao.insertarCredencial(correo, password, idUsuario);
            System.out.println("✅ Credenciales insertadas correctamente");

            // Generar código de verificación
            String codigoVerificacion = com.example.webproyecto.utils.CodeGenerator.generator();
            System.out.println("🔑 Código de verificación generado: " + codigoVerificacion);

            // Guardar código en la base de datos
            CodigoDao codigoDao = new CodigoDao();
            boolean codigoGuardado = codigoDao.guardarCodigo(correo, codigoVerificacion);

            if (!codigoGuardado) {
                System.out.println("❌ Error: No se pudo guardar el código de verificación");
                request.setAttribute("error", "Error al generar código de verificación.");
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.getRequestDispatcher("registro.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Código guardado en la base de datos");

            // Enviar código por correo usando tu MailSender
            boolean correoEnviado = false;
            String asunto = "Código de verificación - ONU Mujeres";
            String mensaje = "¡Hola " + nombre + "!\n\n" +
                            "Bienvenido/a a la plataforma de ONU Mujeres.\n\n" +
                            "Tu código de verificación es: " + codigoVerificacion + "\n\n" +
                            "IMPORTANTE: El código contiene números y letras (ejemplo: A1B2C3)\n\n" +
                            "Por favor, ingresa este código en la página de verificación para completar tu registro y establecer tu contraseña.\n\n" +
                            "Este código es válido por 5 minutos.\n\n" +
                            "Si no solicitaste este registro, puedes ignorar este mensaje.\n\n" +
                            "Saludos,\n" +
                            "Equipo ONU Mujeres";

            try {
                // Usar tu MailSender existente - método estático
                com.example.webproyecto.utils.MailSender.sendEmail(correo, asunto, mensaje);
                correoEnviado = true;
                
                System.out.println("✅ Código enviado por correo a: " + correo);
                
            } catch (Exception emailException) {
                System.err.println("❌ Error al enviar correo a: " + correo);
                System.err.println("❌ Detalle: " + emailException.getMessage());
                emailException.printStackTrace();
                correoEnviado = false;
            }

            // Debug en consola
            System.out.println("=== CÓDIGO DE VERIFICACIÓN ===");
            System.out.println("Correo: " + correo);
            System.out.println("Usuario: " + nombre);
            System.out.println("Código: " + codigoVerificacion);
            System.out.println("Enviado por email: " + (correoEnviado ? "SÍ ✅" : "NO ❌"));

            if (correoEnviado) {
                // Marcar proceso en sesión
                HttpSession session = request.getSession();
                session.setAttribute("registroEnProceso", correo);
                session.setAttribute("correoVerificacion", correo);
                
                // Redirigir a página de verificación
                request.setAttribute("correo", correo);
                request.setAttribute("iniciarTimer", true);
                request.getRequestDispatcher("verificarCodigo.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Error al enviar el código de verificación. Inténtalo nuevamente.");
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("distritos", distritoDao.listarDistritos());
                request.getRequestDispatcher("registro.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error interno del servidor.");
            DistritoDao distritoDao = new DistritoDao();
            request.setAttribute("distritos", distritoDao.listarDistritos());
            request.getRequestDispatcher("registro.jsp").forward(request, response);
        }
    }
}
