package com.example.webproyecto.servlets.coordinador;
import com.example.webproyecto.daos.coordinador.DashboardAnalyticsCoordinadorDao;
import com.example.webproyecto.daos.UsuarioDao;
import com.google.gson.Gson;

import com.example.webproyecto.daos.encuestador.SesionRespuestaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InicioCoordinadorServlet", value = "/InicioCoordinadorServlet")

public class InicioCoordinadorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object idrolObj = session.getAttribute("idrol");
        if (idrolObj == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idrol = (idrolObj instanceof Integer) ? (Integer) idrolObj : Integer.parseInt(idrolObj.toString());
        if (idrol != 2) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idUsuarioCoordinador = (int) session.getAttribute("idUsuario");

        // Obtener análisis detallado usando DashboardAnalyticsCoordinadorDao
        DashboardAnalyticsCoordinadorDao analyticsDao = new DashboardAnalyticsCoordinadorDao();
        
        // Obtener métricas generales
        Map<String, Object> metricasGenerales = analyticsDao.obtenerMetricasGeneralesPorZona(idUsuarioCoordinador);
        
        // Análisis completo de formularios
        List<Map<String, Object>> analisisFormularios = analyticsDao.obtenerAnalisisCompletoFormulariosPorZona(idUsuarioCoordinador);
        
        // DEBUG: Verificar datos recibidos
        System.out.println("=============================================");
        System.out.println("[SERVLET COORDINADOR] Métricas generales: " + metricasGenerales);
        System.out.println("[SERVLET COORDINADOR] Análisis formularios size: " + 
            (analisisFormularios != null ? analisisFormularios.size() : "null"));
        
        if (analisisFormularios != null && !analisisFormularios.isEmpty()) {
            System.out.println("[SERVLET COORDINADOR] Mostrando primeros 3 formularios:");
            for (int i = 0; i < Math.min(analisisFormularios.size(), 3); i++) {
                Map<String, Object> form = analisisFormularios.get(i);
                System.out.println("  Formulario " + (i+1) + ":");
                System.out.println("    - ID: " + form.get("idFormulario"));
                System.out.println("    - Nombre: " + form.get("nombreFormulario"));
                System.out.println("    - Total Respuestas: " + form.get("totalRespuestas"));
            }
        }
        
        // Establecer atributos para la vista
        request.setAttribute("metricasGenerales", metricasGenerales);
        request.setAttribute("analisisFormularios", analisisFormularios);
        request.setAttribute("nombre", session.getAttribute("nombre"));
        request.setAttribute("idUsuario", session.getAttribute("idUsuario"));
        request.setAttribute("idrol", session.getAttribute("idrol"));

        // Renderiza el dashboard
        request.getRequestDispatcher("coordinador/jsp/VerDashboard.jsp").forward(request, response);
    }
}
