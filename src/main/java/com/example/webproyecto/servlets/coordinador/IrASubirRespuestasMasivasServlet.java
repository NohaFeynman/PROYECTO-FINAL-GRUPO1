package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.daos.coordinador.SubidaMasivaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.example.webproyecto.beans.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/IrASubirRespuestasMasivasServlet")
public class IrASubirRespuestasMasivasServlet extends HttpServlet {
    private static final int ARCHIVOS_POR_PAGINA = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        Integer idUsuario = (Integer) session.getAttribute("idUsuario");
        if (idUsuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idFormularioStr = request.getParameter("idFormulario");
        if (idFormularioStr == null || idFormularioStr.isEmpty()) {
            request.setAttribute("error", "No se especificó el formulario.");
            request.getRequestDispatcher("/coordinador/jsp/SubirRespuestasMasivas.jsp").forward(request, response);
            return;
        }

        int idFormulario = Integer.parseInt(idFormularioStr);

        int pagina = 1;
        String paginaStr = request.getParameter("pagina");
        if (paginaStr != null && !paginaStr.isEmpty()) {
            try {
                pagina = Integer.parseInt(paginaStr);
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        SubidaMasivaDao subidaMasivaDao = new SubidaMasivaDao();
        int totalArchivos = subidaMasivaDao.contarArchivosPorUsuarioYFormulario(idUsuario, idFormulario);
        int totalPaginas = (int) Math.ceil((double) totalArchivos / ARCHIVOS_POR_PAGINA);

        int offset = (pagina - 1) * ARCHIVOS_POR_PAGINA;
        List<ArchivoCargado> archivos = subidaMasivaDao.obtenerArchivosPorUsuarioYFormulario(idUsuario, idFormulario, offset, ARCHIVOS_POR_PAGINA);
        List<Pregunta> listaPreguntas = subidaMasivaDao.obtenerPreguntasOrdenadasPorFormulario(idFormulario);
        request.setAttribute("listaPreguntas", listaPreguntas);
        request.setAttribute("archivos", archivos);
        request.setAttribute("paginaActual", pagina);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("idFormulario", idFormulario);

        request.getRequestDispatcher("/coordinador/jsp/SubirRespuestasMasivas.jsp").forward(request, response);
    }
}
