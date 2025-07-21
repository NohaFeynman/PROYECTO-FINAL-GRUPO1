package com.example.webproyecto.servlets.administrador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.dtos.CoordinadorDTO;
import com.example.webproyecto.daos.encuestador.ZonaDao;
import com.example.webproyecto.beans.Zona;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet(name = "GenerarReportesCoordiServlet", value = "/GenerarReportesCoordiServlet")
public class GenerarReportesCoordiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Obtener la lista filtrada desde sesión (puesta por GestionarCoordinadoresServlet)
            List<CoordinadorDTO> coordinadores = (List<CoordinadorDTO>) request.getSession().getAttribute("coordinadoresFiltrados");
            if (coordinadores == null) {
                coordinadores = new ArrayList<>();
            }
            request.setAttribute("coordinadores", coordinadores);
            request.setAttribute("tipoReporte", "coordinadores");
            request.getSession().setAttribute("coordinadoresExcel", coordinadores);

            String action = request.getParameter("action");
            if ("excel".equals(action)) {
                List<CoordinadorDTO> excelList = (List<CoordinadorDTO>) request.getSession().getAttribute("coordinadoresExcel");
                if (excelList == null || excelList.isEmpty()) {
                    response.setContentType("text/html;charset=UTF-8");
                    java.io.PrintWriter out = response.getWriter();
                    out.println("<h3 style='color:#e74c3c;text-align:center;margin-top:40px;'>No hay datos para exportar en Excel según los filtros seleccionados.</h3>");
                    return;
                }
                response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                response.setHeader("Content-Disposition", "attachment; filename=ReporteCoordinadores.xlsx");
                try (Workbook workbook = new XSSFWorkbook()) {
                    Sheet sheet = workbook.createSheet("Coordinadores");
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
                    for (CoordinadorDTO c : excelList) {
                        com.example.webproyecto.beans.Usuario u = c.getUsuario();
                        Row row = sheet.createRow(rowIdx++);
                        row.createCell(0).setCellValue(u.getNombre());
                        row.createCell(1).setCellValue(u.getApellidopaterno());
                        row.createCell(2).setCellValue(u.getApellidomaterno());
                        row.createCell(3).setCellValue(u.getDni());
                        row.createCell(4).setCellValue(c.getCredencial() != null ? c.getCredencial().getCorreo() : "");
                        row.createCell(5).setCellValue(c.getZonaTrabajoNombre() != null ? c.getZonaTrabajoNombre() : "");
                        row.createCell(6).setCellValue(u.getIdEstado() == 2 ? "Activado" : "Desactivado");
                        row.createCell(7).setCellValue(u.getFechaRegistro() != null ? u.getFechaRegistro().toString() : "");
                    }
                    // Ajustar el ancho de todas las columnas
                    for (int i = 0; i <= 7; i++) {
                        sheet.autoSizeColumn(i);
                    }
                    workbook.write(response.getOutputStream());
                }
                return;
            }
            request.getRequestDispatcher("admin/generarReportesCoordi.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setContentType("text/html;charset=UTF-8");
            java.io.PrintWriter out = response.getWriter();
            out.println("<h2>Error en el servlet GenerarReportesCoordiServlet</h2>");
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
