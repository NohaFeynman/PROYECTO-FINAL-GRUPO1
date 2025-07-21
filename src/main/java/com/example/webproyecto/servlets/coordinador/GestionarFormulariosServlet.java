package com.example.webproyecto.servlets.coordinador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import com.example.webproyecto.daos.FormularioDao;
import com.example.webproyecto.daos.encuestador.AsignacionFormularioDao;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.beans.Formulario;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "GestionarFormulariosServlet", value = "/GestionarFormulariosServlet")
public class GestionarFormulariosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null ||
                (int) session.getAttribute("idrol") != 2) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idCoordinador = (int) session.getAttribute("idUsuario");

        FormularioDao formularioDao = new FormularioDao();
        AsignacionFormularioDao asignacionDao = new AsignacionFormularioDao();
        UsuarioDao usuarioDao = new UsuarioDao();

        // ✅ Obtener la zona de trabajo del coordinador
        int idZona = usuarioDao.obtenerZonaPorId(idCoordinador);

        // ✅ Obtener formularios asignados a ese coordinador
        List<Formulario> listaFormularios = formularioDao.obtenerFormulariosAsignadosAlCoordinador(idCoordinador);

        // ✅ Crear un mapa que indique si el formulario está activo en su zona
        Map<Integer, Boolean> estadoFormularios = new HashMap<>();
        for (Formulario f : listaFormularios) {
            boolean activo = asignacionDao.existenAsignacionesActivas(f.getIdFormulario(), idZona);
            estadoFormularios.put(f.getIdFormulario(), activo);
        }

        // ✅ Enviar datos al JSP
        request.setAttribute("formularios", listaFormularios);
        request.setAttribute("estadoFormularios", estadoFormularios);

        request.setAttribute("nombre", session.getAttribute("nombre"));
        request.setAttribute("idUsuario", idCoordinador);
        request.setAttribute("idrol", session.getAttribute("idrol"));

        request.getRequestDispatcher("coordinador/jsp/GestionarFormularios.jsp").forward(request, response);
    }
}
