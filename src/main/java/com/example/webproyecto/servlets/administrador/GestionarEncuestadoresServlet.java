package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.dtos.EncuestadorDTO;
import com.example.webproyecto.daos.encuestador.ZonaDao;
import com.example.webproyecto.beans.Zona;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.json.JSONObject;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "GestionarEncuestadoresServlet", value = "/GestionarEncuestadoresServlet")
public class GestionarEncuestadoresServlet extends HttpServlet {
    private static final int ENCUESTADORES_POR_PAGINA = 10;

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
        if (idrol != 1) { // 1 para administrador
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        UsuarioDao usuarioDao = new UsuarioDao();
        ZonaDao zonaDao = new ZonaDao();
        List<Zona> zonas = zonaDao.listarZonas();
        request.setAttribute("zonas", zonas);
        String nombreFiltro = request.getParameter("nombre");
        String estadoFiltro = request.getParameter("estado");
        String zonaFiltro = request.getParameter("zona");
        int paginaActual = 1;
        try {
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        } catch (Exception ignored) {}

        List<EncuestadorDTO> encuestadores = usuarioDao.listarEncuestadoresConCorreo();

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

        if (zonaFiltro != null && !zonaFiltro.isEmpty()) {
            try {
                int zonaInt = Integer.parseInt(zonaFiltro);
                encuestadores.removeIf(e -> e.getUsuario().getIdZonaTrabajo() == null || e.getUsuario().getIdZonaTrabajo() != zonaInt);
            } catch (NumberFormatException ignored) {}
        }

        int totalEncuestadores = encuestadores.size();
        int totalPaginas = (int) Math.ceil((double) totalEncuestadores / ENCUESTADORES_POR_PAGINA);
        if (totalPaginas == 0) totalPaginas = 1;
        if (paginaActual < 1) paginaActual = 1;
        if (paginaActual > totalPaginas) paginaActual = totalPaginas;

        int desde = (paginaActual - 1) * ENCUESTADORES_POR_PAGINA;
        int hasta = Math.min(desde + ENCUESTADORES_POR_PAGINA, totalEncuestadores);
        if (desde < 0) desde = 0;
        if (desde > hasta) desde = hasta;

        // Guardar la lista completa filtrada en sesión para reportes
        session.setAttribute("encuestadoresFiltrados", encuestadores);

        List<EncuestadorDTO> encuestadoresPagina = (totalEncuestadores == 0) ? java.util.Collections.emptyList() : encuestadores.subList(desde, hasta);
        request.setAttribute("encuestadores", encuestadoresPagina);
        request.setAttribute("paginaActual", paginaActual);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("zonaSeleccionada", zonaFiltro);

        request.getRequestDispatcher("admin/gestionarEncuestadores.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        String accion = request.getParameter("accion");

        // NUEVO: Cambiar estado individual
        if ("cambiarEstado".equals(accion)) {
            String idUsuarioStr = request.getParameter("idUsuario");
            String nuevoEstadoStr = request.getParameter("nuevoEstado");
            System.out.println("[DEBUG] Recibido cambiarEstado: idUsuario=" + idUsuarioStr + ", nuevoEstado=" + nuevoEstadoStr);
            if (idUsuarioStr == null || nuevoEstadoStr == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Datos incompletos\"}");
                return;
            }
            try {
                int idUsuario = Integer.parseInt(idUsuarioStr);
                int nuevoEstado = Integer.parseInt(nuevoEstadoStr);

                System.out.println("[DEBUG] Llamando cambiarEstadoUsuario(" + idUsuario + ", " + nuevoEstado + ")");
                UsuarioDao usuarioDao = new UsuarioDao();
                boolean actualizado = usuarioDao.cambiarEstadoUsuario(idUsuario, nuevoEstado);
                System.out.println("[DEBUG] Resultado cambiarEstadoUsuario: " + actualizado);
                if (actualizado) {
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"No se pudo actualizar\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\": false, \"message\": \"Error al procesar\"}");
            }
            return;
        }

        if ("guardarCambiosMasivos".equals(accion)) {
            String cambiosJson = request.getParameter("cambios");
            if (cambiosJson == null || cambiosJson.isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Sin datos\"}");
                return;
            }

            try {
                UsuarioDao usuarioDao = new UsuarioDao();
                JSONObject obj = new JSONObject(cambiosJson);

                boolean exito = true;
                for (String key : obj.keySet()) {
                    int idUsuario = Integer.parseInt(key);
                    int nuevoEstado = obj.getInt(key);
                    boolean actualizado = usuarioDao.cambiarEstadoUsuario(idUsuario, nuevoEstado);
                    if (!actualizado) exito = false;
                }

                if (exito) {
                    response.getWriter().write("{\"success\": true}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Algunos cambios no se guardaron\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\": false, \"message\": \"Error al procesar cambios\"}");
            }
            return;
        }

        response.getWriter().write("{\"success\": false, \"message\": \"Acción no reconocida\"}");
    }
}
