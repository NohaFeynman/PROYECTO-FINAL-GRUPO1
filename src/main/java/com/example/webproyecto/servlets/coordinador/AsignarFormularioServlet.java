package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.daos.coordinador.AsignacionFormularioDao;
import com.example.webproyecto.daos.coordinador.FormularioCoordinadorDao;
import com.example.webproyecto.daos.encuestador.FormularioDao;

import com.example.webproyecto.beans.Formulario;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AsignarFormularioServlet", value = "/AsignarFormularioServlet")
public class AsignarFormularioServlet extends HttpServlet {

    AsignacionFormularioDao asignacionDao = new AsignacionFormularioDao();
    FormularioDao formularioDao = new FormularioDao();  // <- sigue existiendo para otros métodos
    FormularioCoordinadorDao formularioCoordinadorDao = new FormularioCoordinadorDao();

    private static final int FORMULARIOS_POR_PAGINA = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int idEncuestador = Integer.parseInt(request.getParameter("idEncuestador"));
        String filtroTitulo = request.getParameter("titulo");
        int pagina = 1;

        // Página actual
        if (request.getParameter("pagina") != null) {
            try {
                pagina = Integer.parseInt(request.getParameter("pagina"));
            } catch (NumberFormatException e) {
                pagina = 1;
            }
        }

        // Lógica de paginación
        int totalFormularios = formularioCoordinadorDao.contarFormulariosNoAsignados(idEncuestador);
        int totalPaginas = (int) Math.ceil((double) totalFormularios / FORMULARIOS_POR_PAGINA);
        int offset = (pagina - 1) * FORMULARIOS_POR_PAGINA;

        List<Formulario> formularios = formularioCoordinadorDao.obtenerFormulariosPaginados(offset, FORMULARIOS_POR_PAGINA);
        List<Integer> yaAsignados = asignacionDao.obtenerFormulariosAsignados(idEncuestador);

        request.setAttribute("idEncuestador", idEncuestador);
        request.setAttribute("formularios", formularios);
        request.setAttribute("yaAsignados", yaAsignados);
        request.setAttribute("paginaActual", pagina);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("titulo", filtroTitulo);  // por si se desea conservar filtro en el JSP

        request.getRequestDispatcher("/coordinador/jsp/asignarFormulario.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int idEncuestador = Integer.parseInt(request.getParameter("idEncuestador"));
        String[] idsFormulario = request.getParameterValues("idFormulario");

        if (idsFormulario != null) {
            for (String idFormStr : idsFormulario) {
                int idFormulario = Integer.parseInt(idFormStr);
                if (!asignacionDao.yaEstaAsignado(idEncuestador, idFormulario)) {
                    asignacionDao.asignarFormulario(idEncuestador, idFormulario);
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/GestionEncuestadoresServlet");
    }
}
