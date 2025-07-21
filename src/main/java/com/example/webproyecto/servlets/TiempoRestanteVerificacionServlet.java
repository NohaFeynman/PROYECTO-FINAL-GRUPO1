package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.CodigoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/tiempoRestanteVerificacion")
public class TiempoRestanteVerificacionServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🔍 TiempoRestanteVerificacionServlet - Iniciando petición");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Intentar obtener el correo de la sesión o el último correo con código activo
        String correo = (String) request.getSession().getAttribute("correoVerificacion");
        
        try {
            System.out.println("🔄 Creando CodigoDao...");
            CodigoDao codigoDao = new CodigoDao();
            
            // Si no hay correo en la sesión, obtener el último correo con código activo
            if (correo == null || correo.trim().isEmpty()) {
                correo = codigoDao.obtenerUltimoCorreoConCodigo();
                System.out.println("📧 Correo obtenido de BD: " + correo);
            } else {
                System.out.println("📧 Correo obtenido de sesión: " + correo);
            }
            
            if (correo == null || correo.trim().isEmpty()) {
                System.out.println("❌ No se encontró correo válido");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                PrintWriter out = response.getWriter();
                out.print("{\"error\": \"No se encontró código de verificación activo\", \"segundos\": 0}");
                return;
            }
            
            System.out.println("⏰ Obteniendo tiempo restante de verificación para: " + correo);
            int segundosRestantes = codigoDao.getTiempoRestanteCodigo(correo);
            System.out.println("✅ Tiempo restante de verificación obtenido: " + segundosRestantes + " segundos");
            
            PrintWriter out = response.getWriter();
            out.print("{\"segundos\": " + segundosRestantes + "}");
            System.out.println("📤 Respuesta de verificación enviada exitosamente");
            
        } catch (Exception e) {
            System.err.println("❌ ERROR en TiempoRestanteVerificacionServlet:");
            System.err.println("   Mensaje: " + e.getMessage());
            System.err.println("   Tipo: " + e.getClass().getName());
            e.printStackTrace();
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print("{\"error\": \"Error interno del servidor\", \"segundos\": 0}");
        }
    }
}
