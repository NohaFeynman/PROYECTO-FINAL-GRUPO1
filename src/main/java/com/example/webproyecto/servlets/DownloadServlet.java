package com.example.webproyecto.servlets; // O el paquete adecuado

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet(name = "DownloadServlet", value = "/DownloadServlet")
public class DownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String relativeFilePath = request.getParameter("file"); // "uploads/nombre_unico_archivo.pdf"

        if (relativeFilePath == null || relativeFilePath.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parámetro 'file' faltante o vacío.");
            return;
        }

        // Obtener la ruta real del archivo en el servidor
        String uploadDir = getServletContext().getRealPath("/"); // Esto apunta al contexto raíz de tu aplicación
        Path filePath = Paths.get(uploadDir, relativeFilePath);
        File downloadFile = filePath.toFile();

        if (!downloadFile.exists() || !downloadFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Archivo no encontrado en el servidor.");
            return;
        }

        // Obtener el tipo de contenido del archivo
        String mimeType = getServletContext().getMimeType(downloadFile.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream"; // Tipo por defecto si no se puede determinar
        }

        response.setContentType(mimeType);
        response.setHeader("Content-Disposition", "attachment; filename=\"" + downloadFile.getName() + "\"");
        response.setContentLength((int) downloadFile.length());

        try (FileInputStream inStream = new FileInputStream(downloadFile);
             OutputStream outStream = response.getOutputStream()) {

            byte[] buffer = new byte[4096];
            int bytesRead = -1;

            while ((bytesRead = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
        } catch (Exception e) {
            System.err.println("Error al descargar el archivo: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al procesar la descarga.");
        }
    }
}
