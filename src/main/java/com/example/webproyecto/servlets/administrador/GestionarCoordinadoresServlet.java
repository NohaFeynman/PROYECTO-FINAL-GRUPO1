package com.example.webproyecto.servlets.administrador;

import com.example.webproyecto.dtos.CoordinadorDTO;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.daos.encuestador.ZonaDao;
import com.example.webproyecto.beans.Zona;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONObject;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "GestionarCoordinadoresServlet", value = "/GestionarCoordinadoresServlet")
public class GestionarCoordinadoresServlet extends HttpServlet {
    private static final int COORDINADORES_POR_PAGINA = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[DEBUG] Entrando a doGet de GestionarCoordinadoresServlet");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("idUsuario") == null) {
            System.out.println("[DEBUG] Sesión nula o sin idUsuario, redirigiendo a login.jsp");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Object idrolObj = session.getAttribute("idrol");
        int idrol = (idrolObj instanceof Integer) ? (Integer) idrolObj : Integer.parseInt(idrolObj.toString());
        if (idrol != 1) {
            System.out.println("[DEBUG] idrol != 1, redirigiendo a login.jsp");
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

        List<CoordinadorDTO> coordinadores = usuarioDao.listarCoordinadoresConCorreo();
        System.out.println("[DEBUG] coordinadores.size()=" + (coordinadores != null ? coordinadores.size() : "null"));

        if (nombreFiltro != null && !nombreFiltro.trim().isEmpty()) {
            String filtroLower = nombreFiltro.trim().toLowerCase();
            coordinadores.removeIf(e ->
                    !(e.getUsuario().getNombre() + " " + e.getUsuario().getApellidopaterno() + " " + e.getUsuario().getApellidomaterno()).toLowerCase().contains(filtroLower)
                            && !e.getUsuario().getDni().contains(filtroLower)
            );
        }

        if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
            try {
                int estadoInt = Integer.parseInt(estadoFiltro);
                coordinadores.removeIf(e -> e.getUsuario().getIdEstado() != estadoInt);
            } catch (NumberFormatException ignored) {}
        }

        if (zonaFiltro != null && !zonaFiltro.isEmpty()) {
            try {
                int zonaInt = Integer.parseInt(zonaFiltro);
                coordinadores.removeIf(e -> e.getUsuario().getIdZonaTrabajo() == null || e.getUsuario().getIdZonaTrabajo() != zonaInt);
            } catch (NumberFormatException ignored) {}
        }

        int totalCoordinadores = coordinadores.size();
        int totalPaginas = (int) Math.ceil((double) totalCoordinadores / COORDINADORES_POR_PAGINA);
        if (totalPaginas == 0) totalPaginas = 1;
        if (paginaActual < 1) paginaActual = 1;
        if (paginaActual > totalPaginas) paginaActual = totalPaginas;

        int desde = (paginaActual - 1) * COORDINADORES_POR_PAGINA;
        int hasta = Math.min(desde + COORDINADORES_POR_PAGINA, totalCoordinadores);
        if (desde < 0) desde = 0;
        if (desde > hasta) desde = hasta;

        // Guardar la lista completa filtrada en sesión para reportes
        session.setAttribute("coordinadoresFiltrados", coordinadores);

        List<CoordinadorDTO> coordinadoresPagina = (totalCoordinadores == 0) ? java.util.Collections.emptyList() : coordinadores.subList(desde, hasta);
        System.out.println("[DEBUG] coordinadoresPagina.size()=" + (coordinadoresPagina != null ? coordinadoresPagina.size() : "null"));
        request.setAttribute("coordinadores", coordinadoresPagina);
        request.setAttribute("paginaActual", paginaActual);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("zonaSeleccionada", zonaFiltro);

        // Manejar mensajes de éxito para coordinadores creados
        String creado = request.getParameter("creado");
        String correoEnviado = request.getParameter("correoEnviado");
        
        if ("1".equals(creado)) {
            if ("1".equals(correoEnviado)) {
                request.setAttribute("success", "Coordinador creado exitosamente. Se ha enviado un correo de verificación para que active su cuenta.");
            } else if ("0".equals(correoEnviado)) {
                request.setAttribute("warning", "Coordinador creado exitosamente, pero hubo un problema al enviar el correo de verificación. Contacte al coordinador manualmente.");
            } else {
                request.setAttribute("success", "Coordinador creado exitosamente.");
            }
        }

        System.out.println("[DEBUG] Antes de forward a gestionarCoordinadores.jsp");
        request.getRequestDispatcher("admin/gestionarCoordinadores.jsp").forward(request, response);
        System.out.println("[DEBUG] Después de forward (esto no debería verse)");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        String accion = request.getParameter("accion");

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
                    System.out.println("[DEBUG] Cambiando estado de usuario id=" + idUsuario + " a estado=" + nuevoEstado);
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
                System.out.println("[FLAG] Estado recibido: " + nuevoEstado);

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

        response.getWriter().write("{\"success\": false, \"message\": \"Acción no reconocida\"}");
    }
}
