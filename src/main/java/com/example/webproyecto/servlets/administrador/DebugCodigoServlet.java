package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.daos.CodigoDao;
import com.example.webproyecto.beans.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "DebugCodigoServlet", urlPatterns = {"/debugCodigo"})
public class DebugCodigoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String correo = request.getParameter("correo");
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Debug - Código de Verificación</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }");
        out.println(".container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }");
        out.println(".codigo { background: #e3f2fd; padding: 20px; border-radius: 8px; text-align: center; font-size: 1.5em; font-weight: bold; color: #1565c0; margin: 20px 0; }");
        out.println(".link { background: #f0f8ff; padding: 15px; border-radius: 8px; margin: 15px 0; }");
        out.println(".link a { color: #007bff; text-decoration: none; font-weight: bold; }");
        out.println(".error { color: #dc3545; background: #f8d7da; padding: 15px; border-radius: 8px; margin: 15px 0; }");
        out.println(".warning { color: #856404; background: #fff3cd; padding: 15px; border-radius: 8px; margin: 15px 0; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>🔧 Debug - Código de Verificación para Coordinadores</h1>");
        
        if (correo != null && !correo.trim().isEmpty()) {
            CodigoDao codigoDao = new CodigoDao();
            Usuario usuario = codigoDao.getUsuarioByCorreo(correo);
            
            if (usuario != null) {
                // Verificar si hay un código activo
                int tiempoRestante = codigoDao.getTiempoRestanteCodigo(correo);
                
                if (tiempoRestante > 0) {
                    out.println("<p><strong>✅ Usuario encontrado:</strong> " + correo + "</p>");
                    out.println("<p><strong>⏰ Tiempo restante:</strong> " + tiempoRestante + " segundos</p>");
                    
                    // Para debug, vamos a mostrar información sobre el código en la consola
                    out.println("<div class='warning'>");
                    out.println("<strong>⚠️ Modo Debug:</strong><br>");
                    out.println("Revisa la consola del servidor para ver el código de verificación cuando se creó el coordinador.<br>");
                    out.println("También puedes buscar líneas que contengan: <code>🔐 Código de verificación:</code>");
                    out.println("</div>");
                    
                    out.println("<div class='link'>");
                    out.println("<strong>🔗 Enlace directo para verificar:</strong><br>");
                    out.println("<a href='verificarCoordinador?correo=" + java.net.URLEncoder.encode(correo, "UTF-8") + "' target='_blank'>");
                    out.println("Ir a página de verificación de coordinador");
                    out.println("</a>");
                    out.println("</div>");
                    
                } else {
                    out.println("<div class='error'>");
                    out.println("<strong>❌ No hay código activo</strong><br>");
                    out.println("El código puede haber expirado o no existe. Solicita al administrador que cree nuevamente el coordinador.");
                    out.println("</div>");
                }
            } else {
                out.println("<div class='error'>");
                out.println("<strong>❌ Usuario no encontrado</strong><br>");
                out.println("No se encontró un usuario con el correo: " + correo);
                out.println("</div>");
            }
        } else {
            out.println("<p>Ingresa el correo del coordinador para verificar su código:</p>");
            out.println("<form method='get'>");
            out.println("<input type='email' name='correo' placeholder='correo@ejemplo.com' required style='padding: 10px; width: 300px; border: 2px solid #ddd; border-radius: 5px;'>");
            out.println("<button type='submit' style='padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; margin-left: 10px;'>Verificar</button>");
            out.println("</form>");
        }
        
        out.println("<hr style='margin: 30px 0;'>");
        out.println("<h3>📋 Instrucciones:</h3>");
        out.println("<ol>");
        out.println("<li><strong>Crea un coordinador</strong> desde el panel de administración</li>");
        out.println("<li><strong>Copia el correo</strong> del coordinador creado</li>");
        out.println("<li><strong>Pega el correo aquí</strong> para obtener el enlace de verificación</li>");
        out.println("<li><strong>Busca en la consola</strong> del servidor el código que se muestra al crear el coordinador</li>");
        out.println("<li><strong>Usa el enlace directo</strong> y el código para completar la verificación</li>");
        out.println("</ol>");
        
        out.println("<div class='warning'>");
        out.println("<strong>🚧 Página de Debug Temporal</strong><br>");
        out.println("Esta página es solo para pruebas. En producción, los coordinadores recibirían el correo directamente.");
        out.println("</div>");
        
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}
