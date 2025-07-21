package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.beans.Formulario;
import com.example.webproyecto.beans.Pregunta;
import com.example.webproyecto.daos.encuestador.FormularioDao;
import com.example.webproyecto.daos.encuestador.PreguntaDao;
import com.example.webproyecto.daos.encuestador.AsignacionFormularioDao;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "CrearRespuestaManualServlet", value = "/CrearRespuestaManualServlet")
public class CrearRespuestaManualServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Obtener el idFormulario desde el parámetro
        String idFormularioStr = request.getParameter("idFormulario");
        if (idFormularioStr == null || idFormularioStr.isEmpty()) {
            response.sendRedirect("GestionarFormulariosServlet?error=formulario_id_faltante");
            return;
        }

        int idFormulario;
        try {
            idFormulario = Integer.parseInt(idFormularioStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("GestionarFormulariosServlet?error=formato_invalido");
            return;
        }

        try {
            // Obtener datos del usuario actual (coordinador)
            HttpSession session = request.getSession();
            int idUsuario = (int) session.getAttribute("idUsuario");

            // Obtener datos del formulario y sus preguntas
            FormularioDao formularioDao = new FormularioDao();
            PreguntaDao preguntaDao = new PreguntaDao();
            AsignacionFormularioDao asignacionDao = new AsignacionFormularioDao();

            Formulario formulario = formularioDao.obtenerFormularioPorIdUnico(idFormulario);

            if (formulario == null) {
                response.sendRedirect("GestionarFormulariosServlet?error=formulario_no_encontrado");
                return;
            }

            List<Pregunta> preguntas = preguntaDao.obtenerPreguntasPorFormulario(idFormulario);

            // Obtener la asignación activa para este coordinador
            int idAsignacionFormulario = asignacionDao.obtenerIdAsignacionFormulario(idFormulario, idUsuario);
            if (idAsignacionFormulario == -1) {
                response.sendRedirect("GestionarFormulariosServlet?error=asignacion_no_encontrada");
                return;
            }

            // Setear atributos para el JSP
            request.setAttribute("formulario", formulario);
            request.setAttribute("preguntas", preguntas);
            request.setAttribute("idAsignacionFormulario", idAsignacionFormulario);

            // Redirigir al JSP que mostrará el formulario al coordinador
            request.getRequestDispatcher("coordinador/jsp/CrearRespuestaManual.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("GestionarFormulariosServlet?error=error_bd");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("GestionarFormulariosServlet?error=error_general");
        }
    }
}
