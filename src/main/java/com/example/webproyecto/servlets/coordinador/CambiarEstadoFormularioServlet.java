package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.daos.FormularioDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet(name = "CambiarEstadoFormularioServlet", value = "/CambiarEstadoFormularioServlet")
public class CambiarEstadoFormularioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("idUsuario") == null ||
                (int) session.getAttribute("idrol") != 2) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idCoordinador = (int) session.getAttribute("idUsuario");
        int idFormulario = Integer.parseInt(request.getParameter("idFormulario"));

        FormularioDao formularioDao = new FormularioDao();

        // Verificar si existen asignaciones activas para ese formulario en la zona del coordinador
        boolean estaActivo = formularioDao.existenAsignacionesActivas(idFormulario, idCoordinador);

        if (estaActivo) {
            // Si ya está activo, lo desactivamos
            formularioDao.desactivarFormularioParaZona(idFormulario, idCoordinador);
        } else {
            // Si está inactivo, lo activamos
            formularioDao.activarFormularioParaZona(idFormulario, idCoordinador);
        }

        // Redirigir de nuevo a la vista
        response.sendRedirect("GestionarFormulariosServlet");
    }
}
