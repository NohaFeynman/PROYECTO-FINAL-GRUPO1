// GestionEncuestadoresServlet.java actualizado para Coordinador
package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.dtos.CoordinadorDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "GestionEncuestadoresServlet", value = "/GestionEncuestadoresServlet")
public class GestionEncuestadoresServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object idrolObj = session.getAttribute("idrol");
        int idrol = (idrolObj instanceof Integer) ? (Integer) idrolObj : Integer.parseInt(idrolObj.toString());
        if (idrol != 2) { // Solo coordinador
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int idCoordinador = (Integer) session.getAttribute("idUsuario");

        UsuarioDao usuarioDao = new UsuarioDao();
        List<CoordinadorDTO> encuestadores = usuarioDao.listarEncuestadoresPorZonaCoordinador(idCoordinador);
        System.out.println("[DEBUG] Encuestadores encontrados: " + encuestadores.size());

        String nombreFiltro = request.getParameter("nombre");
        String estadoFiltro = request.getParameter("estado");

        if (nombreFiltro != null && !nombreFiltro.trim().isEmpty()) {
            String filtroLower = nombreFiltro.trim().toLowerCase();
            encuestadores.removeIf(e ->
                    !(e.getUsuario().getNombre() + " " + e.getUsuario().getApellidopaterno() + " " + e.getUsuario().getApellidomaterno()).toLowerCase().contains(filtroLower)
                            && !e.getUsuario().getDni().contains(filtroLower)
            );
        }

        if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
            try {
                int estadoInt = Integer.parseInt(estadoFiltro);
                encuestadores.removeIf(e -> e.getUsuario().getIdEstado() != estadoInt);
            } catch (NumberFormatException ex) {
                System.out.println("Estado inválido recibido: " + estadoFiltro);
            }
        }

        // PAGINACIÓN
        int paginaActual = 1;
        int elementosPorPagina = 4;
        try {
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        } catch (Exception ignored) {}

        int totalEncuestadores = encuestadores.size();
        int totalPaginas = (int) Math.ceil((double) totalEncuestadores / elementosPorPagina);
        int inicio = (paginaActual - 1) * elementosPorPagina;
        int fin = Math.min(inicio + elementosPorPagina, totalEncuestadores);

        List<CoordinadorDTO> encuestadoresPaginados = encuestadores.subList(inicio, fin);

        request.setAttribute("encuestadores", encuestadoresPaginados);
        request.setAttribute("paginaActual", paginaActual);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("nombreFiltro", nombreFiltro);
        request.setAttribute("estadoFiltro", estadoFiltro);

        request.getRequestDispatcher("coordinador/jsp/VerFormularios.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");

        String accion = request.getParameter("accion");
        if ("cambiarEstado".equals(accion)) {
            try {
                int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
                int estadoRecibido = Integer.parseInt(request.getParameter("nuevoEstado"));
                int nuevoEstado = (estadoRecibido == 2) ? 3 : 2;  // Si estaba activo (2), lo pongo en inactivo (3). Si estaba inactivo, lo reactivo (2)
                if (nuevoEstado == 2) {
                    nuevoEstado = 3; // Cambiar a inactivo
                } else {
                    nuevoEstado = 2; // Cambiar a activo
                }

                UsuarioDao usuarioDao = new UsuarioDao();
                boolean actualizado = usuarioDao.cambiarEstadoUsuario(idUsuario, nuevoEstado);

                response.getWriter().write("{\"success\": " + actualizado + "}");
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\": false, \"message\": \"Error en servidor\"}");
            }
        }
    }
}
