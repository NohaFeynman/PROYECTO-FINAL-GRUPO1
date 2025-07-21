package com.example.webproyecto.servlets;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.utils.CodeGenerator;
import com.example.webproyecto.utils.MailSender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/reenviarCodigoRecuperacion")
public class ReenviarCodigoRecuperacionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("📧 ReenviarCodigoRecuperacionServlet - Procesando reenvío");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String correo = request.getParameter("correo");
        
        if (correo == null || correo.trim().isEmpty()) {
            System.out.println("❌ Correo vacío o nulo");
            response.getWriter().write("{\"success\": false, \"message\": \"Correo no válido\"}");
            return;
        }
        
        correo = correo.trim().toLowerCase();
        System.out.println("📧 Reenviando código para: " + correo);
        
        CodigoDao codigoDao = new CodigoDao();
        
        try {
            // Verificar si el usuario existe
            System.out.println("🔍 Verificando si el usuario existe para correo: " + correo);
            
            // Generar nuevo código
            String nuevoCodigo = CodeGenerator.generator();
            System.out.println("🔐 Nuevo código generado: " + nuevoCodigo);
            
            // Actualizar código en la base de datos usando el método específico para recuperación
            boolean codigoActualizado = codigoDao.actualizarCodigoRecuperacion(correo, nuevoCodigo);
            System.out.println("🔄 Resultado de actualizarCodigoRecuperacion: " + codigoActualizado);
            
            if (codigoActualizado) {
                System.out.println("✅ Código actualizado en BD");
                
                // Mostrar el código claramente en los logs para pruebas
                System.out.println("🔐 ========================================");
                System.out.println("🔐 CÓDIGO DE RECUPERACIÓN REENVIADO:");
                System.out.println("🔐 Correo: " + correo);
                System.out.println("🔐 Nuevo Código: " + nuevoCodigo);
                System.out.println("🔐 ========================================");
                
                // Enviar el nuevo código por correo
                String asunto = "Nuevo Código de Recuperación - Plataforma ONU Mujeres";
                String mensaje = "Estimado/a usuario/a,\n\n" +
                               "Has solicitado un nuevo código para restablecer tu contraseña.\n\n" +
                               "Tu nuevo código de verificación es: " + nuevoCodigo + "\n\n" +
                               "Este código expirará en 5 minutos por seguridad.\n\n" +
                               "Si no solicitaste este cambio, puedes ignorar este mensaje de forma segura.\n\n" +
                               "Atentamente,\n" +
                               "Equipo de la Plataforma ONU Mujeres\n" +
                               "Defensora mundial de la igualdad de género";
                
                try {
                    MailSender.sendEmail(correo, asunto, mensaje);
                    System.out.println("✅ Código reenviado exitosamente");
                    System.out.println("📧 NUEVO CÓDIGO PARA PRUEBAS: " + nuevoCodigo + " (válido por 5 minutos)");
                    response.getWriter().write("{\"success\": true, \"message\": \"Código reenviado exitosamente\"}");
                } catch (Exception emailException) {
                    System.out.println("❌ Error al reenviar email: " + emailException.getMessage());
                    emailException.printStackTrace();
                    response.getWriter().write("{\"success\": false, \"message\": \"Error al enviar el código por correo\"}");
                }
                
            } else {
                System.out.println("❌ Error al actualizar código en BD");
                System.out.println("🔍 Intentando verificar si el usuario existe...");
                
                // Verificar si el usuario existe
                try {
                    Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
                    if (usuario != null) {
                        System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario());
                        response.getWriter().write("{\"success\": false, \"message\": \"Error al actualizar el código en la base de datos\"}");
                    } else {
                        System.out.println("❌ Usuario no encontrado para correo: " + correo);
                        response.getWriter().write("{\"success\": false, \"message\": \"Usuario no encontrado\"}");
                    }
                } catch (Exception e2) {
                    System.out.println("❌ Error al verificar usuario: " + e2.getMessage());
                    response.getWriter().write("{\"success\": false, \"message\": \"Error al verificar usuario: " + e2.getMessage() + "\"}");
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error en ReenviarCodigoRecuperacionServlet: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Error interno del sistema\"}");
        }
    }
}
