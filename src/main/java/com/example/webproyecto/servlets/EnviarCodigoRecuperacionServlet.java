package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.utils.CodeGenerator;
import com.example.webproyecto.utils.MailSender;
import com.example.webproyecto.beans.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/enviarCodigoRecuperacion")
public class EnviarCodigoRecuperacionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("📧 EnviarCodigoRecuperacionServlet - Iniciando proceso de recuperación");
        
        String correo = request.getParameter("correo");
        
        if (correo == null || correo.trim().isEmpty()) {
            System.out.println("❌ Correo vacío o nulo");
            request.setAttribute("error", "Debe ingresar un correo electrónico");
            request.getRequestDispatcher("recuperarPassword.jsp").forward(request, response);
            return;
        }
        
        correo = correo.trim().toLowerCase();
        System.out.println("📧 Procesando recuperación para: " + correo);
        
        CodigoDao codigoDao = new CodigoDao();
        
        try {
            // Verificar si el usuario existe
            Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
            if (usuario == null) {
                System.out.println("❌ Usuario no encontrado para: " + correo);
                request.setAttribute("error", "No se encontró una cuenta asociada a este correo electrónico");
                request.getRequestDispatcher("recuperarPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Usuario encontrado - ID: " + usuario.getIdUsuario());
            
            // Generar nuevo código de verificación
            String codigo = CodeGenerator.generator();
            System.out.println("🔐 Código generado: " + codigo);
            
            // Guardar código en la base de datos usando el método específico para recuperación
            boolean codigoGuardado = codigoDao.generarCodigoRecuperacion(correo, codigo);
            if (!codigoGuardado) {
                System.out.println("❌ Error al guardar código de recuperación en BD");
                request.setAttribute("error", "Error interno. Inténtalo nuevamente.");
                request.getRequestDispatcher("recuperarPassword.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ Código guardado exitosamente");
            
            // Mostrar el código claramente en los logs para pruebas
            System.out.println("🔐 ========================================");
            System.out.println("🔐 CÓDIGO DE RECUPERACIÓN GENERADO:");
            System.out.println("🔐 Correo: " + correo);
            System.out.println("🔐 Código: " + codigo);
            System.out.println("🔐 ========================================");
            
            // Enviar código por correo
            String asunto = "Recuperación de Contraseña - Plataforma ONU Mujeres";
            String mensaje = "Estimado/a usuario/a,\n\n" +
                           "Has solicitado restablecer tu contraseña en la Plataforma ONU Mujeres.\n\n" +
                           "Tu código de verificación es: " + codigo + "\n\n" +
                           "Este código expirará en 5 minutos por seguridad.\n\n" +
                           "Si no solicitaste este cambio, puedes ignorar este mensaje de forma segura.\n\n" +
                           "Atentamente,\n" +
                           "Equipo de la Plataforma ONU Mujeres\n" +
                           "Defensora mundial de la igualdad de género";
            
            try {
                MailSender.sendEmail(correo, asunto, mensaje);
                System.out.println("✅ Email enviado exitosamente a: " + correo);
                System.out.println("📧 CÓDIGO PARA PRUEBAS: " + codigo + " (válido por 5 minutos)");
                
                // Redirigir a la página de verificación de correo
                request.getSession().setAttribute("correoRecuperacion", correo);
                request.setAttribute("correoUsuario", correo);
                request.setAttribute("tipoOperacion", "recuperacion");
                request.getRequestDispatcher("verificaTuCorreo.jsp").forward(request, response);
                
            } catch (Exception emailException) {
                System.out.println("❌ Error al enviar email: " + emailException.getMessage());
                emailException.printStackTrace();
                request.setAttribute("error", "Error al enviar el código por correo. Verifica tu dirección e inténtalo nuevamente.");
                request.getRequestDispatcher("recuperarPassword.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error en EnviarCodigoRecuperacionServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error interno del sistema. Inténtalo más tarde.");
            request.getRequestDispatcher("recuperarPassword.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirigir al formulario de recuperación
        response.sendRedirect("recuperarPassword.jsp");
    }
}
