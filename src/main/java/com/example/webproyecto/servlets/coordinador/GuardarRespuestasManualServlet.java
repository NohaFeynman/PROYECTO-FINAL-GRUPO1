package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.beans.Respuesta;
import com.example.webproyecto.beans.SesionRespuesta;
import com.example.webproyecto.beans.Pregunta;
import com.example.webproyecto.daos.encuestador.PreguntaDao;
import com.example.webproyecto.daos.encuestador.RespuestaDao;
import com.example.webproyecto.daos.encuestador.SesionRespuestaDao;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(name = "GuardarRespuestasManualServlet", value = "/GuardarRespuestasManualServlet")
public class GuardarRespuestasManualServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros
        int idAsignacionFormulario = Integer.parseInt(request.getParameter("idAsignacionFormulario"));
        int idFormulario = Integer.parseInt(request.getParameter("idFormulario"));

        // Crear sesión de respuesta sin idEncuestado (coordinador)
        SesionRespuestaDao sesionDao = new SesionRespuestaDao();
        SesionRespuesta sesion = new SesionRespuesta();
        sesion.setFechaInicio(LocalDateTime.now());
        sesion.setFechaEnvio(LocalDateTime.now());
        sesion.setEstadoTerminado(1);
        sesion.setIdAsignacionFormulario(idAsignacionFormulario);
        sesion.setIdEncuestado(null); // <- Aquí no se asigna encuestado

        int idSesion = sesionDao.crearSesionRespuesta(sesion);
        if (idSesion <= 0) {
            response.sendRedirect("error.jsp");
            return;
        }

        // Asignar número de sesión
        int anio = LocalDateTime.now().getYear();
        int numeroSesion = anio * 1000 + 999;
        sesionDao.actualizarNumeroSesion(idSesion, numeroSesion);

        // Recolectar respuestas
        List<Respuesta> listaRespuestas = new ArrayList<>();
        Enumeration<String> paramNames = request.getParameterNames();

        while (paramNames.hasMoreElements()) {
            String param = paramNames.nextElement();
            if (param.startsWith("respuesta_")) {
                int idPregunta = Integer.parseInt(param.substring(10));
                String valor = request.getParameter(param);
                String tipoStr = request.getParameter("tipo_" + idPregunta);
                int tipoPregunta = tipoStr != null ? Integer.parseInt(tipoStr) : 1;

                if (valor != null && !valor.trim().isEmpty()) {
                    Respuesta r = new Respuesta();
                    r.setIdSesion(idSesion);
                    r.setIdPregunta(idPregunta);

                    if (tipoPregunta == 0) {
                        r.setIdOpcion(Integer.parseInt(valor));
                    } else {
                        r.setTextoRespuesta(valor);
                    }

                    listaRespuestas.add(r);
                }
            }
        }

        // Validar que haya al menos una respuesta
        if (listaRespuestas.isEmpty()) {
            response.sendRedirect("CrearRespuestaManual.jsp?error=vacio");
            return;
        }

        // Validar obligatorias
        PreguntaDao preguntaDao = new PreguntaDao();
        List<Pregunta> todas = preguntaDao.obtenerPreguntasPorFormulario(idFormulario);

        int ordenMaxSeccionC = todas.stream()
                .filter(p -> "C".equalsIgnoreCase(p.getSeccion()))
                .mapToInt(Pregunta::getOrden).max().orElse(-1);

        for (Pregunta p : todas) {
            if (p.getObligatorio() == 1) {
                if ("C".equalsIgnoreCase(p.getSeccion()) && p.getOrden() == ordenMaxSeccionC) continue;

                boolean respondida = listaRespuestas.stream()
                        .anyMatch(r -> r.getIdPregunta() == p.getIdPregunta());

                if (!respondida) {
                    response.sendRedirect("CrearRespuestaManual.jsp?error=obligatorias");
                    return;
                }
            }
        }

        // Guardar respuestas
        RespuestaDao respuestaDao = new RespuestaDao();
        respuestaDao.guardarRespuestas(listaRespuestas);

        // Mensaje de éxito
        request.getSession().setAttribute("mensajeAlerta", "¡El formulario fue completado y enviado exitosamente!");
        response.sendRedirect("GestionarFormulariosServlet");
    }
}
