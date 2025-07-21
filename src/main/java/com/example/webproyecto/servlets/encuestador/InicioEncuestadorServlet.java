package com.example.webproyecto.servlets.encuestador;

import com.example.webproyecto.daos.encuestador.SesionRespuestaDao;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InicioEncuestadorServlet", value = "/InicioEncuestadorServlet")
public class InicioEncuestadorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null ||
                (int) session.getAttribute("idrol") != 3) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idEncuestador = (int) session.getAttribute("idUsuario");

        System.out.println("DEBUG DASHBOARD: Cargando dashboard para encuestador ID=" + idEncuestador);

        SesionRespuestaDao srDao = new SesionRespuestaDao();
        List<Map<String, Object>> resumenSesiones = srDao.obtenerResumenSesionesPorEncuestador(idEncuestador);

        System.out.println("DEBUG DASHBOARD: Sesiones obtenidas para dashboard: " + resumenSesiones.size());

        request.setAttribute("resumenSesiones", resumenSesiones);
        request.setAttribute("nombre", session.getAttribute("nombre"));
        request.setAttribute("idUsuario", session.getAttribute("idUsuario"));
        request.setAttribute("idrol", session.getAttribute("idrol"));

        request.getRequestDispatcher("inicioEncuestador.jsp").forward(request, response);
    }
}
