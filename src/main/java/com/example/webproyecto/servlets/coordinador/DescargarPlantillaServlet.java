package com.example.webproyecto.servlets.coordinador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

@WebServlet("/DescargarPlantillaServlet")
public class DescargarPlantillaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Configurar cabeceras de respuesta para descarga
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=plantilla_subida.xlsx");
        
        // Obtener la plantilla desde el directorio de recursos
        try (InputStream in = getServletContext().getResourceAsStream("/plantillas/plantilla_subida.xlsx");
             OutputStream out = response.getOutputStream()) {
            
            if (in == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Plantilla no encontrada");
                return;
            }
            
            // Copiar el archivo al output
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Error al descargar la plantilla: " + e.getMessage());
        }
    }
}
