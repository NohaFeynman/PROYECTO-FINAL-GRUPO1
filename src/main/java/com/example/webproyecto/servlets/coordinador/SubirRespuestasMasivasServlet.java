package com.example.webproyecto.servlets.coordinador;

import com.example.webproyecto.beans.Pregunta;
import com.example.webproyecto.daos.coordinador.SubidaMasivaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/SubirRespuestasMasivasServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10 MB
public class SubirRespuestasMasivasServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer idUsuario = (Integer) session.getAttribute("idUsuario");
        if (idUsuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int idFormulario = Integer.parseInt(request.getParameter("idFormulario"));
        SubidaMasivaDao dao = new SubidaMasivaDao();

        Part archivoPart = request.getPart("archivoExcel");
        String nombreOriginal = archivoPart.getSubmittedFileName();

        if (!nombreOriginal.endsWith(".xlsx")) {
            request.setAttribute("error", "El archivo debe ser de tipo .xlsx");
            request.getRequestDispatcher("IrASubirRespuestasMasivasServlet?idFormulario=" + idFormulario).forward(request, response);
            return;
        }

        byte[] contenidoArchivo = archivoPart.getInputStream().readAllBytes();
        List<String> errores = new ArrayList<>();
        int numeroSesionBase = dao.obtenerUltimoNumeroSesion(idUsuario, idFormulario);

        try (Workbook workbook = new XSSFWorkbook(archivoPart.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            List<Pregunta> preguntas = dao.obtenerPreguntasOrdenadasPorFormulario(idFormulario);

            for (int filaIdx = 5; filaIdx <= sheet.getLastRowNum(); filaIdx++) {
                Row fila = sheet.getRow(filaIdx);
                if (fila == null) continue;

                int numeroSesion = ++numeroSesionBase;
                int idSesion = dao.insertarSesionRespuesta(idFormulario, numeroSesion, idUsuario);
                if (idSesion == -1) {
                    errores.add("Error al crear la sesión en la fila " + (filaIdx + 1));
                    continue;
                }

                boolean registroAlgunaRespuesta = false;

                for (int col = 0; col < preguntas.size(); col++) {
                    Pregunta p = preguntas.get(col);
                    Cell celda = fila.getCell(col);
                    if (celda == null) continue;

                    String valor = "";
                    if (celda.getCellType() == CellType.STRING) {
                        valor = celda.getStringCellValue().trim();
                    } else if (celda.getCellType() == CellType.NUMERIC) {
                        valor = String.valueOf((int) celda.getNumericCellValue()).trim();
                    }

                    if (valor.isEmpty()) continue;

                    if (p.getTipoPregunta() == 1) {
                        dao.insertarRespuestaAbierta(idSesion, p.getIdPregunta(), valor);
                        registroAlgunaRespuesta = true;
                    } else {
                        Integer idOpcion = dao.obtenerIdOpcionPorTexto(p.getIdPregunta(), valor);
                        if (idOpcion != null) {
                            dao.insertarRespuestaOpcion(idSesion, p.getIdPregunta(), idOpcion);
                            registroAlgunaRespuesta = true;
                        } else {
                            errores.add("Fila " + (filaIdx + 1) + ", pregunta '" + p.getTextoPregunta() + "': opción '" + valor + "' no válida.");
                        }
                    }
                }

                // Si no se registró ninguna respuesta útil, opcionalmente podrías eliminar la sesión si ya fue insertada
            }

            String nombreGenerado = dao.generarNombreArchivo(nombreOriginal, idUsuario);
            // Determinar estado final
            String estadoFinal;
            if (errores.isEmpty()) {
                estadoFinal = "EXITOSO";
            } else if (numeroSesionBase == dao.obtenerUltimoNumeroSesion(idUsuario, idFormulario)) {
                // No se creó ninguna nueva sesión, por tanto no se insertaron respuestas válidas
                estadoFinal = "PENDIENTE";
            } else {
                estadoFinal = "CON_ERRORES";
            }
            System.out.println("Nombre original: " + nombreOriginal);
            System.out.println("Tamaño leído: " + contenidoArchivo.length);
            System.out.println("Estado final: " + estadoFinal);

            System.out.println("ERRORES:");
            errores.forEach(System.out::println);

            dao.insertarArchivo(nombreGenerado, contenidoArchivo, idUsuario, estadoFinal,
                    errores.isEmpty() ? null : String.join("\n", errores), idFormulario);
            System.out.println("Insertando archivo con nombre: " + nombreGenerado + " y tamaño: " + contenidoArchivo.length);

            if (errores.isEmpty()) {
                request.setAttribute("exito", "Archivo subido correctamente.");
            } else {
                request.setAttribute("error", "Archivo subido, pero contiene errores.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            dao.insertarArchivo(nombreOriginal, contenidoArchivo, idUsuario, "ERROR", "Error al procesar el archivo: " + e.getMessage(), idFormulario);
            request.setAttribute("error", "Ocurrió un error: " + e.getMessage());
        }

        response.sendRedirect("IrASubirRespuestasMasivasServlet?idFormulario=" + idFormulario);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idFormulario = request.getParameter("idFormulario");
        if (idFormulario != null) {
            response.sendRedirect("IrASubirRespuestasMasivasServlet?idFormulario=" + idFormulario);
        } else {
            response.sendRedirect("coordinador/jsp/VerDashboard.jsp");
        }
    }

}
