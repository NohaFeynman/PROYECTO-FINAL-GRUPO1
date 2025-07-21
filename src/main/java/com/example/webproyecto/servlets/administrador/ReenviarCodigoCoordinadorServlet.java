package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.utils.CodeGenerator;
import com.example.webproyecto.utils.MailSender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ReenviarCodigoCoordinadorServlet", urlPatterns = {"/reenviarCodigoCoordinador"})
public class ReenviarCodigoCoordinadorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String correo = request.getParameter("correo");
        
        if (correo == null || correo.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Correo no válido\"}");
            return;
        }

        try {
            CodigoDao codigoDao = new CodigoDao();
            UsuarioDao usuarioDao = new UsuarioDao();
            
            System.out.println("🔄 ReenviarCodigoCoordinadorServlet - Procesando solicitud para: " + correo);
            
            // Obtener nombre del coordinador para personalizar el mensaje
            String nombreCoordinador = usuarioDao.obtenerNombrePorCorreo(correo);
            if (nombreCoordinador == null) {
                nombreCoordinador = "Coordinador";
            }
            
            System.out.println("👤 Nombre de coordinador obtenido: " + nombreCoordinador);
            
            // Generar nuevo código usando CodeGenerator
            String nuevoCodigo = CodeGenerator.generator();
            System.out.println("🎲 Nuevo código generado: " + nuevoCodigo);
            
            boolean codigoActualizado = codigoDao.actualizarCodigo(correo, nuevoCodigo);
            System.out.println("📝 Resultado actualización código: " + codigoActualizado);
            
            if (codigoActualizado) {
                // Envío de correo con el nuevo código (específico para coordinadores)
                try {
                    String asunto = "Nuevo código de verificación - Coordinador Interno - ONU Mujeres";
                    String mensaje = "¡Hola " + nombreCoordinador + "!\n\n" +
                                    "Has solicitado un nuevo código de verificación para activar tu cuenta como Coordinador Interno.\n\n" +
                                    "Tu nuevo código de verificación es: " + nuevoCodigo + "\n\n" +
                                    "IMPORTANTE: El código contiene números y letras (ejemplo: A1B2C3)\n\n" +
                                    "Por favor, ingresa este código en la página de verificación para completar la configuración de tu cuenta.\n\n" +
                                    "Este código es válido por 5 minutos por seguridad.\n\n" +
                                    "Como Coordinador Interno, tendrás acceso a funcionalidades especiales para gestionar encuestadores y supervisar el trabajo de campo.\n\n" +
                                    "Si no solicitaste este código, puedes ignorar este mensaje de forma segura.\n\n" +
                                    "¡Bienvenido/a al equipo!\n\n" +
                                    "Saludos,\n" +
                                    "Equipo ONU Mujeres\n" +
                                    "Defensora mundial de la igualdad de género";
                    
                    // Usar MailSender existente
                    MailSender.sendEmail(correo, asunto, mensaje);
                    
                    System.out.println("✅ Código de coordinador reenviado por correo a: " + correo);
                    
                } catch (Exception emailException) {
                    System.err.println("❌ Error al reenviar correo a coordinador: " + correo);
                    System.err.println("❌ Detalle: " + emailException.getMessage());
                    emailException.printStackTrace();
                }
                
                // Debug en consola
                System.out.println("=== CÓDIGO REENVIADO COORDINADOR ===");
                System.out.println("Correo: " + correo);
                System.out.println("Coordinador: " + nombreCoordinador);
                System.out.println("Nuevo código: " + nuevoCodigo);
                System.out.println("===================================");
                
                out.print("{\"success\":true,\"message\":\"Código reenviado exitosamente a tu correo\"}");
            } else {
                System.err.println("❌ No se pudo actualizar el código para: " + correo);
                out.print("{\"success\":false,\"message\":\"Error al generar nuevo código. Inténtalo nuevamente.\"}");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error general en ReenviarCodigoCoordinadorServlet: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error interno del servidor. Contacta al administrador.\"}");
        }
    }
}
