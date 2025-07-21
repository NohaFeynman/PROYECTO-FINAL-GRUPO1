package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.daos.UsuarioDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ReenviarCodigoServlet", urlPatterns = {"/reenviarCodigo"})
public class ReenviarCodigoServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Intentar obtener el correo de diferentes fuentes
        String correo = request.getParameter("correo");
        
        // Si no viene como parámetro, buscarlo en la sesión
        if (correo == null || correo.trim().isEmpty()) {
            // Buscar el último código generado para obtener el correo
            CodigoDao codigoDao = new CodigoDao();
            correo = codigoDao.obtenerUltimoCorreoConCodigo();
        }
        
        if (correo == null || correo.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"No se pudo identificar el correo para reenvío\"}");
            return;
        }

        try {
            CodigoDao codigoDao = new CodigoDao();
            UsuarioDao usuarioDao = new UsuarioDao();
            
            System.out.println("🔄 ReenviarCodigoServlet - Procesando solicitud para: " + correo);
            
            // Obtener nombre del usuario para personalizar el mensaje
            String nombreUsuario = usuarioDao.obtenerNombrePorCorreo(correo);
            if (nombreUsuario == null) {
                nombreUsuario = "Usuario";
            }
            System.out.println("👤 Nombre de usuario obtenido: " + nombreUsuario);
            
            // Generar nuevo código usando tu CodeGenerator
            String nuevoCodigo = com.example.webproyecto.utils.CodeGenerator.generator();
            System.out.println("🎲 Nuevo código generado: " + nuevoCodigo);
            
            boolean codigoActualizado = codigoDao.actualizarCodigo(correo, nuevoCodigo);
            System.out.println("📝 Resultado actualización código: " + codigoActualizado);
            
            if (codigoActualizado) {
                // Envío de correo con el nuevo código
                try {
                    String asunto = "Nuevo código de verificación - ONU Mujeres";
                    String mensaje = "¡Hola " + nombreUsuario + "!\n\n" +
                                    "Has solicitado un nuevo código de verificación.\n\n" +
                                    "Tu nuevo código es: " + nuevoCodigo + "\n\n" +
                                    "IMPORTANTE: El código contiene números y letras (ejemplo: A1B2C3)\n\n" +
                                    "Por favor, ingresa este código en la página de verificación para completar tu registro.\n\n" +
                                    "Este código es válido por 5 minutos.\n\n" +
                                    "Saludos,\n" +
                                    "Equipo ONU Mujeres";
                    
                    // Usar tu MailSender existente - método estático
                    com.example.webproyecto.utils.MailSender.sendEmail(correo, asunto, mensaje);
                    
                    System.out.println("✅ Código reenviado por correo a: " + correo);
                    
                } catch (Exception emailException) {
                    System.err.println("❌ Error al reenviar correo a: " + correo);
                    System.err.println("❌ Detalle: " + emailException.getMessage());
                    emailException.printStackTrace();
                }
                
                // Debug en consola
                System.out.println("=== CÓDIGO REENVIADO ===");
                System.out.println("Correo: " + correo);
                System.out.println("Usuario: " + nombreUsuario);
                System.out.println("Nuevo código: " + nuevoCodigo);
                System.out.println("========================");
                
                out.print("{\"success\":true,\"message\":\"Código reenviado exitosamente\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"Error al actualizar el código\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error interno del servidor\"}");
        }
    }
}
