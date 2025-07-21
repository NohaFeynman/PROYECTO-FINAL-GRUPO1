package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.daos.encuestador.SesionRespuestaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.example.webproyecto.daos.administrador.DashboardAnalyticsDao;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InicioAdminServlet", value = "/InicioAdminServlet")
public class InicioAdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Solo permite acceso a usuarios con rol de administrador (por ejemplo, rolId == 1)
        if (session == null || session.getAttribute("idUsuario") == null || session.getAttribute("idrol") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int idrol = (session.getAttribute("idrol") instanceof Integer)
                ? (Integer) session.getAttribute("idrol")
                : Integer.parseInt(session.getAttribute("idrol").toString());
        if (idrol != 1) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }        // Obtener datos dinámicos para el dashboard
        UsuarioDao usuarioDao = new UsuarioDao();
        int encuestadoresActivos = usuarioDao.contarEncuestadoresActivos();
        int encuestadoresDesactivos = usuarioDao.contarEncuestadoresDesactivos();
        int coordinadoresActivos = usuarioDao.contarCoordinadoresActivos();
        int coordinadoresDesactivos = usuarioDao.contarCoordinadoresDesactivos();

        // Obtener datos para el gráfico de líneas
        SesionRespuestaDao sesionRespuestaDao = new SesionRespuestaDao();
        List<Map<String, Object>> datosGraficoLineas = sesionRespuestaDao.obtenerFormulariosCompletadosPorZonaYMes();
        System.out.println("[DEBUG] datosGraficoLineas size: " + (datosGraficoLineas != null ? datosGraficoLineas.size() : "null"));
        if (datosGraficoLineas != null) {
            for (Map<String, Object> fila : datosGraficoLineas) {
                System.out.println("[DEBUG] " + fila);
            }
        }

        // Obtener datos analíticos detallados usando DashboardAnalyticsDao
        DashboardAnalyticsDao analyticsDao = new DashboardAnalyticsDao();

        // DEBUG: Verificar datos básicos primero
        Map<String, Object> datosDebug = analyticsDao.obtenerDatosDebug();
        System.out.println("[DEBUG] Datos básicos de la BD: " + datosDebug);
        request.setAttribute("datosDebug", datosDebug);

        // Análisis completo de formularios con preguntas y respuestas agrupadas
        System.out.println("=============================================");
        System.out.println("[SERVLET] Iniciando obtenerAnalisisCompletoFormularios...");
        List<Map<String, Object>> analisisFormularios = analyticsDao.obtenerAnalisisCompletoFormularios();
        System.out.println("[SERVLET] analisisFormularios recibido:");
        System.out.println("[SERVLET] - Es null? " + (analisisFormularios == null));
        System.out.println("[SERVLET] - Tamaño: " + (analisisFormularios != null ? analisisFormularios.size() : "N/A"));

        if (analisisFormularios != null && !analisisFormularios.isEmpty()) {
            for (int i = 0; i < Math.min(analisisFormularios.size(), 3); i++) {
                Map<String, Object> form = analisisFormularios.get(i);
                System.out.println("[SERVLET] Formulario " + (i+1) + ":");
                System.out.println("  - ID: " + form.get("idFormulario"));
                System.out.println("  - Nombre: " + form.get("nombreFormulario"));
                System.out.println("  - Respuestas: " + form.get("totalRespuestas"));
                System.out.println("  - Preguntas: " + (form.get("preguntas") != null ?
                        ((List<?>) form.get("preguntas")).size() : "null"));

                if (form.get("preguntas") != null) {
                    List<?> preguntas = (List<?>) form.get("preguntas");
                    for (int j = 0; j < Math.min(preguntas.size(), 2); j++) {
                        Map<?, ?> pregunta = (Map<?, ?>) preguntas.get(j);
                        System.out.println("    Pregunta " + (j+1) + ": " + pregunta.get("textoPregunta"));
                        System.out.println("      Tipo: " + pregunta.get("tipoAnalisis"));
                        System.out.println("      Opciones: " + pregunta.get("tieneOpciones"));
                    }
                }
            }
        } else {
            System.out.println("[SERVLET] ❌ Lista analisisFormularios vacía o null");
        }
        System.out.println("=============================================");

        // Métricas generales
        Map<String, Object> metricasGenerales = analyticsDao.obtenerMetricasGenerales();

        // Análisis de satisfacción
        List<Map<String, Object>> datosSatisfaccion = analyticsDao.obtenerAnalisisSatisfaccion();

        // Respuestas abiertas recientes
        List<Map<String, Object>> respuestasAbiertas = analyticsDao.obtenerRespuestasAbiertasRecientes(15);

        // Estadísticas por zona
        List<Map<String, Object>> estadisticasZona = analyticsDao.obtenerEstadisticasPorZona();

        // Palabras clave más frecuentes
        List<Map<String, Object>> palabrasClave = analyticsDao.obtenerPalabrasClaveRespuestas();

        request.setAttribute("encuestadoresActivos", encuestadoresActivos);
        request.setAttribute("encuestadoresDesactivos", encuestadoresDesactivos);
        request.setAttribute("coordinadoresActivos", coordinadoresActivos);
        request.setAttribute("coordinadoresDesactivos", coordinadoresDesactivos);
        request.setAttribute("datosGraficoLineas", datosGraficoLineas);

        // Atributos para análisis detallado
        request.setAttribute("analisisFormularios", analisisFormularios);
        request.setAttribute("metricasGenerales", metricasGenerales);
        request.setAttribute("datosSatisfaccion", datosSatisfaccion);
        request.setAttribute("respuestasAbiertas", respuestasAbiertas);
        request.setAttribute("estadisticasZona", estadisticasZona);
        request.setAttribute("palabrasClave", palabrasClave);

        request.setAttribute("nombre", session.getAttribute("nombre"));
        request.setAttribute("idUsuario", session.getAttribute("idUsuario"));
        request.setAttribute("idrol", session.getAttribute("idrol"));

        request.getRequestDispatcher("admin/dashboardAdmin.jsp").forward(request, response);
    }
}
