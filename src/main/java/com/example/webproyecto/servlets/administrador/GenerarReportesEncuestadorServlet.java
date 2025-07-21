package com.example.webproyecto.servlets.administrador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.example.webproyecto.daos.UsuarioDao;
import com.example.webproyecto.dtos.EncuestadorDTO;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet(name = "GenerarReportesEncuestadorServlet", value = "/GenerarReportesEncuestadorServlet")
public class GenerarReportesEncuestadorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Obtener la lista filtrada desde sesión (puesta por GestionarEncuestadoresServlet)
            List<EncuestadorDTO> encuestadores = (List<EncuestadorDTO>) request.getSession().getAttribute("encuestadoresFiltrados");
            if (encuestadores == null) {
                encuestadores = new ArrayList<>();
            }
            request.setAttribute("encuestadores", encuestadores);
            request.setAttribute("tipoReporte", "encuestadores");
            request.getSession().setAttribute("encuestadoresExcel", encuestadores);

            String action = request.getParameter("action");
            if ("excel".equals(action)) {
                List<EncuestadorDTO> excelList = (List<EncuestadorDTO>) request.getSession().getAttribute("encuestadoresExcel");
                if (excelList == null || excelList.isEmpty()) {
                    request.setAttribute("errorExcel", "No hay datos para exportar en Excel según los filtros seleccionados.");
                    request.getRequestDispatcher("admin/generarReportesEncuestador.jsp").forward(request, response);
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
                    for (EncuestadorDTO e : excelList) {
                        com.example.webproyecto.dtos.UsuarioDTO u = e.getUsuario();
                        Row row = sheet.createRow(rowIdx++);
                        row.createCell(0).setCellValue(u.getNombre());
                        row.createCell(1).setCellValue(u.getApellidopaterno());
                        row.createCell(2).setCellValue(u.getApellidomaterno());
                        row.createCell(3).setCellValue(u.getDni());
                        row.createCell(4).setCellValue(e.getCredencial() != null ? e.getCredencial().getCorreo() : "");
                        row.createCell(5).setCellValue(e.getZonaTrabajoNombre() != null ? e.getZonaTrabajoNombre() : "");
                        row.createCell(6).setCellValue(u.getIdEstado() != null && u.getIdEstado() == 2 ? "Activado" : "Desactivado");
                        row.createCell(7).setCellValue(u.getFechaRegistro() != null ? u.getFechaRegistro().toString() : "");
                    }
                    for (int i = 0; i <= 7; i++) {
                        sheet.autoSizeColumn(i);
                    }
                    workbook.write(response.getOutputStream());
                }
                return;
            }
            request.getRequestDispatcher("admin/generarReportesEncuestador.jsp").forward(request, response);
        } catch (Exception ex) {
            response.setContentType("text/html;charset=UTF-8");
            java.io.PrintWriter out = response.getWriter();
            out.println("<h2>Error en el servlet GenerarReportesEncuestadorServlet</h2>");
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
