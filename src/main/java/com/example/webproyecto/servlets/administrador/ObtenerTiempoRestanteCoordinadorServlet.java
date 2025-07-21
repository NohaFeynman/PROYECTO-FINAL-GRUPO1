package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.daos.CodigoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ObtenerTiempoRestanteCoordinadorServlet", urlPatterns = {"/obtenerTiempoRestanteCoordinador"})
public class ObtenerTiempoRestanteCoordinadorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String correo = request.getParameter("correo");
        
        if (correo == null || correo.trim().isEmpty()) {
            out.print("{\"success\":false,\"tiempoRestante\":0,\"message\":\"Correo no válido\"}");
            return;
        }

        try {
            CodigoDao codigoDao = new CodigoDao();
            int tiempoRestante = codigoDao.getTiempoRestanteCodigo(correo);
            
            System.out.println("⏰ Tiempo restante para coordinador " + correo + ": " + tiempoRestante + " segundos");
            
            out.print("{\"success\":true,\"tiempoRestante\":" + tiempoRestante + "}");
            
        } catch (Exception e) {
            System.err.println("❌ Error al obtener tiempo restante para coordinador: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"tiempoRestante\":0,\"message\":\"Error interno del servidor\"}");
        }
    }
}
