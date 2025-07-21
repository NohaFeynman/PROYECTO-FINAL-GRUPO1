package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.CodigoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "TiempoRestanteServlet", value = "/tiempoRestante")
public class TiempoRestanteServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🔍 TiempoRestanteServlet - Iniciando petición");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String correo = request.getParameter("correo");
        System.out.println("📧 Correo recibido: " + correo);
        
        if (correo == null || correo.trim().isEmpty()) {
            System.out.println("❌ Correo no válido o vacío");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            PrintWriter out = response.getWriter();
            out.print("{\"error\": \"Correo requerido\"}");
            return;
        }
        
        try {
            System.out.println("🔄 Creando CodigoDao...");
            CodigoDao codigoDao = new CodigoDao();
            
            System.out.println("⏰ Obteniendo tiempo restante para: " + correo);
            int segundosRestantes = codigoDao.getTiempoRestanteCodigo(correo);
            System.out.println("✅ Tiempo restante obtenido: " + segundosRestantes + " segundos");
            
            PrintWriter out = response.getWriter();
            out.print("{\"segundos\": " + segundosRestantes + "}");
            System.out.println("📤 Respuesta enviada exitosamente");
            
        } catch (Exception e) {
            System.err.println("❌ ERROR en TiempoRestanteServlet:");
            System.err.println("   Mensaje: " + e.getMessage());
            System.err.println("   Tipo: " + e.getClass().getSimpleName());
            e.printStackTrace();
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print("{\"error\": \"Error interno del servidor: " + e.getMessage() + "\"}");
        }
    }
}
