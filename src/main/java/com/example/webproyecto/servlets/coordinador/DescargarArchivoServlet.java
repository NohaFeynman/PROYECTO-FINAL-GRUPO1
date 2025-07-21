package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.beans.ArchivoCargado;
import com.example.webproyecto.daos.coordinador.SubidaMasivaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/DescargarArchivoServlet")
public class DescargarArchivoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idArchivoStr = request.getParameter("idArchivo");

        if (idArchivoStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de archivo faltante");
            return;
        }

        int idArchivo = Integer.parseInt(idArchivoStr);
        SubidaMasivaDao dao = new SubidaMasivaDao();
        ArchivoCargado archivo = dao.obtenerArchivoPorId(idArchivo);

        if (archivo == null || archivo.getContenido() == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Archivo no encontrado");
            return;
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + archivo.getNombreArchivoOriginal() + "\"");
        response.setContentLength(archivo.getContenido().length);

        OutputStream out = response.getOutputStream();
        out.write(archivo.getContenido());
        out.flush();
    }
}
