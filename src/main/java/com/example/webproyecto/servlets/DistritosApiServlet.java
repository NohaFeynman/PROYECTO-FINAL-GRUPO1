package com.example.webproyecto.servlets;

import com.example.webproyecto.daos.DistritoDao;
import com.example.webproyecto.beans.Distrito;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/distritos")
public class DistritosApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("🌐 DistritosApiServlet - Serviendo distritos vía API");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            DistritoDao distritoDao = new DistritoDao();
            List<Distrito> distritos = distritoDao.listarDistritos();
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            
            for (int i = 0; i < distritos.size(); i++) {
                Distrito distrito = distritos.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                    .append("\"idDistrito\":").append(distrito.getIdDistrito()).append(",")
                    .append("\"nombreDistrito\":\"").append(distrito.getNombreDistrito()).append("\"")
                    .append("}");
            }
            
            json.append("]");
            
            System.out.println("✅ API: " + distritos.size() + " distritos servidos");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            System.err.println("❌ Error en API de distritos: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Error al cargar distritos\"}");
        }
    }
}
