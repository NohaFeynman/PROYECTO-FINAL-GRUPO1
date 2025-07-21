package com.example.webproyecto.servlets.administrador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.dtos.CoordinadorDTO;
import com.example.webproyecto.dtos.EncuestadorDTO;
import com.example.webproyecto.daos.encuestador.ZonaDao;
import com.example.webproyecto.beans.Zona;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.example.webproyecto.dtos.UsuarioDTO;

@WebServlet(name = "GenerarReportesServlet", value = "/GenerarReportesServlet")
public class GenerarReportesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<EncuestadorDTO> encuestadoresFiltrados = (List<EncuestadorDTO>) session.getAttribute("encuestadoresFiltrados");
        request.setAttribute("encuestadores", encuestadoresFiltrados);
        request.getRequestDispatcher("admin/generarReportes.jsp").forward(request, response);
        try {
            String tipo = request.getParameter("tipo");
            String action = request.getParameter("action");
            if (tipo == null) tipo = "encuestadores";
            if (tipo.equals("coordinadores")) {
                UsuarioDao usuarioDao = new UsuarioDao();
                List<CoordinadorDTO> coordinadores = usuarioDao.obtenerCoordinadores();
                request.setAttribute("coordinadores", coordinadores);
                request.setAttribute("tipoReporte", "coordinadores");
            } else {
                String nombre = request.getParameter("nombre");
                String apellidopaterno = request.getParameter("apellidopaterno");
                String dni = request.getParameter("dni");
                String zonaTrabajo = request.getParameter("zonaTrabajo");
                String rangoFechas = request.getParameter("rangoFechas");

                // Cargar zonas
                ZonaDao zonaDao = new ZonaDao();
                List<Zona> zonas = zonaDao.listarZonas();
                request.setAttribute("zonas", zonas);

                UsuarioDao usuarioDao = new UsuarioDao();
                List<EncuestadorDTO> encuestadores = usuarioDao.obtenerEncuestadoresFiltrado(nombre, apellidopaterno, dni, zonaTrabajo, rangoFechas);
                request.setAttribute("encuestadores", encuestadores);
                request.setAttribute("tipoReporte", "encuestadores");

                if ("excel".equals(action)) {
                    if (encuestadores == null || encuestadores.isEmpty()) {
                        response.setContentType("text/html;charset=UTF-8");
                        java.io.PrintWriter out = response.getWriter();
                        out.println("<h3 style='color:#e74c3c;text-align:center;margin-top:40px;'>No hay datos para exportar en Excel según los filtros seleccionados.</h3>");
                        return;
                    }
                    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                    response.setHeader("Content-Disposition", "attachment; filename=ReporteEncuestadores.xlsx");
                    try (Workbook workbook = new XSSFWorkbook()) {
                        Sheet sheet = workbook.createSheet("Encuestadores");
                        int rowIdx = 0;
                        Row header = sheet.createRow(rowIdx++);
                        header.createCell(0).setCellValue("Nombre");
                        header.createCell(1).setCellValue("Apellido Paterno");
                        header.createCell(2).setCellValue("Apellido Materno");
                        header.createCell(3).setCellValue("DNI");
                        header.createCell(4).setCellValue("Correo Electrónico");
                        header.createCell(5).setCellValue("Zona");
                        header.createCell(6).setCellValue("Estado");
                        header.createCell(7).setCellValue("Fecha Registro");
                        for (EncuestadorDTO e : encuestadores) {
                            Row row = sheet.createRow(rowIdx++);
                                UsuarioDTO u = e.getUsuario();
                            row.createCell(0).setCellValue(u.getNombre());
                            row.createCell(1).setCellValue(u.getApellidopaterno());
                            row.createCell(2).setCellValue(u.getApellidomaterno());
                            row.createCell(3).setCellValue(u.getDni());
                            row.createCell(4).setCellValue(e.getCredencial() != null ? e.getCredencial().getCorreo() : "");
                            row.createCell(5).setCellValue(e.getZonaTrabajoNombre() != null ? e.getZonaTrabajoNombre() : "");
                            row.createCell(6).setCellValue(u.getIdEstado() != null && u.getIdEstado() == 2 ? "Activado" : "Desactivado");
                            row.createCell(7).setCellValue(u.getFechaRegistro() != null ? u.getFechaRegistro().toString() : "");
                        }
                        workbook.write(response.getOutputStream());
                    }
                    return;
                }
            }
            request.getRequestDispatcher("admin/generarReportes.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setContentType("text/html;charset=UTF-8");
            java.io.PrintWriter out = response.getWriter();
            out.println("<h2>Error en el servlet GenerarReportesServlet</h2>");
            out.println("<pre>");
            ex.printStackTrace(out);
            out.println("</pre>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
