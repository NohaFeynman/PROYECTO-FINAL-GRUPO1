// filepath: c:\Users\FABRICIO\Documents\6to_ciclo\iweb\proyecto_actualizado_25_06_25\PROYECTO-OFICIAL-ONU-MUJERES\PROYECTO-OFICIAL-ONU-MUJERES\src\main\java\com\example\webproyecto\servlets\administrador\ExportarReporteDashboardServlet.java
package com.example.webproyecto.servlets.administrador;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@WebServlet(name = "ExportarReporteDashboardServlet", value = "/ExportarReporteDashboardServlet")
public class ExportarReporteDashboardServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Log para debug
        System.out.println("=== INICIANDO EXPORTAR REPORTE ===");
        
        // Verificar sesión
        Object idRol = request.getSession().getAttribute("idrol");
        System.out.println("ID Rol de sesión: " + idRol);
        
        if (idRol == null || !idRol.toString().equals("1")) {
            System.out.println("Usuario no autorizado");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "No autorizado");
            return;
        }
        
        try {
            // Obtener parámetros con logs
            String encActivosStr = request.getParameter("encuestadoresActivos");
            String encInactivosStr = request.getParameter("encuestadoresInactivos");
            String coordActivosStr = request.getParameter("coordinadoresActivos");
            String coordInactivosStr = request.getParameter("coordinadoresInactivos");
            String datosJson = request.getParameter("datosGraficoFormularios");
            String datosGraficasPreguntasJson = request.getParameter("datosGraficasPreguntas");
            
            System.out.println("Parámetros recibidos:");
            System.out.println("- Enc Activos: " + encActivosStr);
            System.out.println("- Enc Inactivos: " + encInactivosStr);
            System.out.println("- Coord Activos: " + coordActivosStr);
            System.out.println("- Coord Inactivos: " + coordInactivosStr);
            System.out.println("- Datos JSON: " + (datosJson != null ? datosJson.substring(0, Math.min(100, datosJson.length())) + "..." : "null"));
            System.out.println("- Datos Gráficas Preguntas: " + (datosGraficasPreguntasJson != null ? "Recibido (" + datosGraficasPreguntasJson.length() + " chars)" : "null"));
            
            // Validar parámetros
            if (encActivosStr == null || encInactivosStr == null || 
                coordActivosStr == null || coordInactivosStr == null) {
                System.out.println("ERROR: Parámetros faltantes");
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Parámetros faltantes");
                return;
            }
            
            // Convertir a números
            int encActivos = Integer.parseInt(encActivosStr);
            int encInactivos = Integer.parseInt(encInactivosStr);
            int coordActivos = Integer.parseInt(coordActivosStr);
            int coordInactivos = Integer.parseInt(coordInactivosStr);
            
            System.out.println("Números convertidos correctamente");
            
            // Parsear JSON (puede ser null o vacío)
            Map<String, int[]> datosGrafico = null;
            if (datosJson != null && !datosJson.trim().isEmpty() && !datosJson.equals("{}")) {
                try {
                    Gson gson = new Gson();
                    Type type = new TypeToken<Map<String, int[]>>(){}.getType();
                    datosGrafico = gson.fromJson(datosJson, type);
                    System.out.println("JSON parseado correctamente: " + datosGrafico.size() + " zonas");
                } catch (Exception e) {
                    System.out.println("Error al parsear JSON, continuando sin datos de gráfico: " + e.getMessage());
                }
            }

            // Parsear datos de gráficas de preguntas
            java.util.List<Map<String, Object>> datosGraficasPreguntas = null;
            if (datosGraficasPreguntasJson != null && !datosGraficasPreguntasJson.trim().isEmpty()) {
                try {
                    Gson gson = new Gson();
                    Type type = new TypeToken<java.util.List<Map<String, Object>>>(){}.getType();
                    datosGraficasPreguntas = gson.fromJson(datosGraficasPreguntasJson, type);
                    System.out.println("Datos de gráficas de preguntas parseados: " + datosGraficasPreguntas.size() + " preguntas");
                } catch (Exception e) {
                    System.out.println("Error al parsear datos de gráficas de preguntas: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            // Generar Excel
            System.out.println("Iniciando generación de Excel...");
            generarYDescargarExcel(response, encActivos, encInactivos, coordActivos, coordInactivos, datosGrafico, datosGraficasPreguntas);
            System.out.println("Excel generado exitosamente");
            
        } catch (NumberFormatException e) {
            System.out.println("ERROR: Error de formato de número: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Error en formato de números");
        } catch (Exception e) {
            System.out.println("ERROR: Error general: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error interno del servidor");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    private void generarYDescargarExcel(HttpServletResponse response, int encActivos, int encInactivos,
                                       int coordActivos, int coordInactivos, Map<String, int[]> datosGrafico,
                                       java.util.List<Map<String, Object>> datosGraficasPreguntas) 
            throws IOException {
        
        System.out.println("Creando workbook...");
        XSSFWorkbook workbook = new XSSFWorkbook();
        
        try {
            // Crear estilos básicos
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setAlignment(HorizontalAlignment.CENTER);
            
            // Crear hoja de resumen
            System.out.println("Creando hoja de resumen...");
            Sheet resumenSheet = workbook.createSheet("Resumen Dashboard");
            crearHojaResumen(resumenSheet, encActivos, encInactivos, coordActivos, coordInactivos, headerStyle, dataStyle);
            
            // Crear hoja de formularios si hay datos
            if (datosGrafico != null && !datosGrafico.isEmpty()) {
                System.out.println("Creando hoja de formularios...");
                Sheet formulariosSheet = workbook.createSheet("Formularios por Zona");
                crearHojaFormularios(formulariosSheet, datosGrafico, headerStyle, dataStyle);
            } else {
                System.out.println("No hay datos de formularios, omitiendo hoja...");
            }

            // Crear hojas de gráficas de preguntas si hay datos
            if (datosGraficasPreguntas != null && !datosGraficasPreguntas.isEmpty()) {
                System.out.println("Creando hojas de gráficas de preguntas...");
                crearHojasGraficasPreguntas(workbook, datosGraficasPreguntas, headerStyle, dataStyle);
            } else {
                System.out.println("No hay datos de gráficas de preguntas, omitiendo hojas...");
            }
            
            // Configurar respuesta
            String fileName = "Reporte_Dashboard_" + 
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".xlsx";
            
            System.out.println("Configurando respuesta HTTP para archivo: " + fileName);
            
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            response.setHeader("Cache-Control", "no-cache");
            response.setHeader("Pragma", "no-cache");
            
            // Escribir al output stream
            System.out.println("Escribiendo archivo...");
            workbook.write(response.getOutputStream());
            response.getOutputStream().flush();
            System.out.println("Archivo escrito exitosamente");
            
        } finally {
            workbook.close();
            System.out.println("Workbook cerrado");
        }
    }
    
    private void crearHojaResumen(Sheet sheet, int encActivos, int encInactivos, 
                                 int coordActivos, int coordInactivos, 
                                 CellStyle headerStyle, CellStyle dataStyle) {
        
        int rowNum = 0;
        
        // Título
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("REPORTE DASHBOARD ADMINISTRADOR");
        titleCell.setCellStyle(headerStyle);
        
        // Fecha
        Row fechaRow = sheet.createRow(rowNum++);
        fechaRow.createCell(0).setCellValue("Fecha de generación: " + 
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        
        rowNum++; // Línea en blanco
        
        // Encuestadores
        Row encTitleRow = sheet.createRow(rowNum++);
        encTitleRow.createCell(0).setCellValue("=== ENCUESTADORES ===");
        encTitleRow.getCell(0).setCellStyle(headerStyle);
        
        Row encHeaderRow = sheet.createRow(rowNum++);
        encHeaderRow.createCell(0).setCellValue("Estado");
        encHeaderRow.createCell(1).setCellValue("Cantidad");
        encHeaderRow.getCell(0).setCellStyle(headerStyle);
        encHeaderRow.getCell(1).setCellStyle(headerStyle);
        
        Row encActivosRow = sheet.createRow(rowNum++);
        encActivosRow.createCell(0).setCellValue("Activos");
        encActivosRow.createCell(1).setCellValue(encActivos);
        encActivosRow.getCell(0).setCellStyle(dataStyle);
        encActivosRow.getCell(1).setCellStyle(dataStyle);
        
        Row encInactivosRow = sheet.createRow(rowNum++);
        encInactivosRow.createCell(0).setCellValue("Inactivos");
        encInactivosRow.createCell(1).setCellValue(encInactivos);
        encInactivosRow.getCell(0).setCellStyle(dataStyle);
        encInactivosRow.getCell(1).setCellStyle(dataStyle);
        
        Row encTotalRow = sheet.createRow(rowNum++);
        encTotalRow.createCell(0).setCellValue("TOTAL ENCUESTADORES");
        encTotalRow.createCell(1).setCellValue(encActivos + encInactivos);
        encTotalRow.getCell(0).setCellStyle(headerStyle);
        encTotalRow.getCell(1).setCellStyle(headerStyle);
        
        rowNum++; // Línea en blanco
        
        // Coordinadores
        Row coordTitleRow = sheet.createRow(rowNum++);
        coordTitleRow.createCell(0).setCellValue("=== COORDINADORES ===");
        coordTitleRow.getCell(0).setCellStyle(headerStyle);
        
        Row coordHeaderRow = sheet.createRow(rowNum++);
        coordHeaderRow.createCell(0).setCellValue("Estado");
        coordHeaderRow.createCell(1).setCellValue("Cantidad");
        coordHeaderRow.getCell(0).setCellStyle(headerStyle);
        coordHeaderRow.getCell(1).setCellStyle(headerStyle);
        
        Row coordActivosRow = sheet.createRow(rowNum++);
        coordActivosRow.createCell(0).setCellValue("Activos");
        coordActivosRow.createCell(1).setCellValue(coordActivos);
        coordActivosRow.getCell(0).setCellStyle(dataStyle);
        coordActivosRow.getCell(1).setCellStyle(dataStyle);
        
        Row coordInactivosRow = sheet.createRow(rowNum++);
        coordInactivosRow.createCell(0).setCellValue("Inactivos");
        coordInactivosRow.createCell(1).setCellValue(coordInactivos);
        coordInactivosRow.getCell(0).setCellStyle(dataStyle);
        coordInactivosRow.getCell(1).setCellStyle(dataStyle);
        
        Row coordTotalRow = sheet.createRow(rowNum++);
        coordTotalRow.createCell(0).setCellValue("TOTAL COORDINADORES");
        coordTotalRow.createCell(1).setCellValue(coordActivos + coordInactivos);
        coordTotalRow.getCell(0).setCellStyle(headerStyle);
        coordTotalRow.getCell(1).setCellStyle(headerStyle);
        
        // Ajustar columnas
        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
    }
    
    private void crearHojaFormularios(Sheet sheet, Map<String, int[]> datosGrafico, 
                                     CellStyle headerStyle, CellStyle dataStyle) {
        
        String[] meses = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                         "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
        
        // Título
        Row titleRow = sheet.createRow(0);
        titleRow.createCell(0).setCellValue("FORMULARIOS POR ZONA GEOGRÁFICA");
        titleRow.getCell(0).setCellStyle(headerStyle);
        
        // Encabezados
        Row headerRow = sheet.createRow(2);
        headerRow.createCell(0).setCellValue("Zona Geográfica");
        headerRow.getCell(0).setCellStyle(headerStyle);
        
        for (int i = 0; i < meses.length; i++) {
            headerRow.createCell(i + 1).setCellValue(meses[i]);
            headerRow.getCell(i + 1).setCellStyle(headerStyle);
        }
        headerRow.createCell(13).setCellValue("Total Año");
        headerRow.getCell(13).setCellStyle(headerStyle);
        
        // Datos por zona
        int rowNum = 3;
        int[] totalesPorMes = new int[12];
        
        for (Map.Entry<String, int[]> entry : datosGrafico.entrySet()) {
            Row dataRow = sheet.createRow(rowNum++);
            dataRow.createCell(0).setCellValue(entry.getKey());
            dataRow.getCell(0).setCellStyle(dataStyle);
            
            int[] datos = entry.getValue();
            int totalZona = 0;
            
            for (int i = 0; i < 12; i++) {
                int valor = (i < datos.length) ? datos[i] : 0;
                dataRow.createCell(i + 1).setCellValue(valor);
                dataRow.getCell(i + 1).setCellStyle(dataStyle);
                totalZona += valor;
                totalesPorMes[i] += valor;
            }
            
            dataRow.createCell(13).setCellValue(totalZona);
            dataRow.getCell(13).setCellStyle(headerStyle);
        }
        
        // Fila de totales
        Row totalRow = sheet.createRow(rowNum);
        totalRow.createCell(0).setCellValue("=== TOTALES ===");
        totalRow.getCell(0).setCellStyle(headerStyle);
        
        int granTotal = 0;
        for (int i = 0; i < 12; i++) {
            totalRow.createCell(i + 1).setCellValue(totalesPorMes[i]);
            totalRow.getCell(i + 1).setCellStyle(headerStyle);
            granTotal += totalesPorMes[i];
        }
        
        totalRow.createCell(13).setCellValue(granTotal);
        totalRow.getCell(13).setCellStyle(headerStyle);
        
        // Ajustar columnas
        for (int i = 0; i < 14; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private void crearHojasGraficasPreguntas(XSSFWorkbook workbook, java.util.List<Map<String, Object>> datosGraficasPreguntas,
                                           CellStyle headerStyle, CellStyle dataStyle) {
        
        System.out.println("Procesando " + datosGraficasPreguntas.size() + " preguntas para Excel...");
        
        // Crear hoja de resumen de todas las preguntas
        Sheet resumenPreguntasSheet = workbook.createSheet("Resumen Preguntas");
        crearHojaResumenPreguntas(resumenPreguntasSheet, datosGraficasPreguntas, headerStyle, dataStyle);
        
        // Crear hojas individuales para preguntas con muchos datos
        int contadorHojas = 1;
        for (Map<String, Object> pregunta : datosGraficasPreguntas) {
            try {
                String textoPregunta = (String) pregunta.get("textoPregunta");
                String tipoAnalisis = (String) pregunta.get("tipoAnalisis");
                
                // Limitar el nombre de la hoja a 31 caracteres (límite de Excel)
                String nombreHoja = "Pregunta_" + contadorHojas;
                if (textoPregunta != null && textoPregunta.length() > 0) {
                    String textoLimpio = textoPregunta.replaceAll("[\\[\\]\\*\\?:/\\\\]", "").trim();
                    if (textoLimpio.length() > 20) {
                        textoLimpio = textoLimpio.substring(0, 20);
                    }
                    nombreHoja = "P" + contadorHojas + "_" + textoLimpio;
                }
                
                // Asegurar que el nombre no exceda 31 caracteres
                if (nombreHoja.length() > 31) {
                    nombreHoja = nombreHoja.substring(0, 31);
                }
                
                System.out.println("Creando hoja: " + nombreHoja + " para pregunta: " + textoPregunta);
                
                Sheet preguntaSheet = workbook.createSheet(nombreHoja);
                crearHojaPreguntaIndividual(preguntaSheet, pregunta, headerStyle, dataStyle);
                
                contadorHojas++;
                
                // Limitar a 10 hojas adicionales para evitar archivos muy grandes
                if (contadorHojas > 10) {
                    System.out.println("Límite de hojas alcanzado, omitiendo preguntas restantes...");
                    break;
                }
                
            } catch (Exception e) {
                System.out.println("Error creando hoja para pregunta: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    private void crearHojaResumenPreguntas(Sheet sheet, java.util.List<Map<String, Object>> datosGraficasPreguntas,
                                         CellStyle headerStyle, CellStyle dataStyle) {
        
        int rowNum = 0;
        
        // Título
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("RESUMEN DE TODAS LAS PREGUNTAS ANALIZADAS");
        titleCell.setCellStyle(headerStyle);
        
        // Fecha
        Row fechaRow = sheet.createRow(rowNum++);
        fechaRow.createCell(0).setCellValue("Fecha de generación: " + 
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        
        rowNum++; // Línea en blanco
        
        // Encabezados
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("N°");
        headerRow.createCell(1).setCellValue("Pregunta");
        headerRow.createCell(2).setCellValue("Tipo");
        headerRow.createCell(3).setCellValue("Total Respuestas");
        headerRow.createCell(4).setCellValue("Detalles");
        
        for (int i = 0; i < 5; i++) {
            headerRow.getCell(i).setCellStyle(headerStyle);
        }
        
        // Datos de cada pregunta
        int numeroPregunta = 1;
        for (Map<String, Object> pregunta : datosGraficasPreguntas) {
            Row dataRow = sheet.createRow(rowNum++);
            
            // Número
            dataRow.createCell(0).setCellValue(numeroPregunta++);
            dataRow.getCell(0).setCellStyle(dataStyle);
            
            // Pregunta
            String textoPregunta = (String) pregunta.get("textoPregunta");
            dataRow.createCell(1).setCellValue(textoPregunta != null ? textoPregunta : "Sin texto");
            dataRow.getCell(1).setCellStyle(dataStyle);
            
            // Tipo
            String tipoAnalisis = (String) pregunta.get("tipoAnalisis");
            dataRow.createCell(2).setCellValue(tipoAnalisis != null ? tipoAnalisis : "Desconocido");
            dataRow.getCell(2).setCellStyle(dataStyle);
            
            // Calcular total de respuestas
            int totalRespuestas = 0;
            String detalles = "";
            
            try {
                Boolean esPreguntaNumerica = (Boolean) pregunta.get("esPreguntaNumerica");
                
                if (esPreguntaNumerica != null && esPreguntaNumerica) {
                    // Para preguntas numéricas, contar respuestas de texto
                    @SuppressWarnings("unchecked")
                    java.util.List<String> respuestasTexto = (java.util.List<String>) pregunta.get("respuestasTexto");
                    if (respuestasTexto != null) {
                        totalRespuestas = respuestasTexto.size();
                        detalles = "Respuestas de texto: " + totalRespuestas;
                    }
                } else {
                    // Para preguntas de opción múltiple, sumar cantidades
                    @SuppressWarnings("unchecked")
                    java.util.List<Map<String, Object>> opciones = (java.util.List<Map<String, Object>>) pregunta.get("opcionesMultiples");
                    if (opciones != null) {
                        for (Map<String, Object> opcion : opciones) {
                            Object cantidadObj = opcion.get("cantidadRespuestas");
                            if (cantidadObj instanceof Number) {
                                totalRespuestas += ((Number) cantidadObj).intValue();
                            }
                        }
                        detalles = opciones.size() + " opciones disponibles";
                    }
                }
            } catch (Exception e) {
                detalles = "Error al procesar: " + e.getMessage();
            }
            
            dataRow.createCell(3).setCellValue(totalRespuestas);
            dataRow.getCell(3).setCellStyle(dataStyle);
            
            dataRow.createCell(4).setCellValue(detalles);
            dataRow.getCell(4).setCellStyle(dataStyle);
        }
        
        // Ajustar columnas
        for (int i = 0; i < 5; i++) {
            sheet.autoSizeColumn(i);
        }
    }
    
    private void crearHojaPreguntaIndividual(Sheet sheet, Map<String, Object> pregunta,
                                           CellStyle headerStyle, CellStyle dataStyle) {
        
        int rowNum = 0;
        
        // Título de la pregunta
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        String textoPregunta = (String) pregunta.get("textoPregunta");
        titleCell.setCellValue(textoPregunta != null ? textoPregunta : "Pregunta sin título");
        titleCell.setCellStyle(headerStyle);
        
        // Información de la pregunta
        Row infoRow = sheet.createRow(rowNum++);
        String tipoAnalisis = (String) pregunta.get("tipoAnalisis");
        infoRow.createCell(0).setCellValue("Tipo de análisis: " + (tipoAnalisis != null ? tipoAnalisis : "Desconocido"));
        
        rowNum++; // Línea en blanco
        
        try {
            Boolean esPreguntaNumerica = (Boolean) pregunta.get("esPreguntaNumerica");
            
            if (esPreguntaNumerica != null && esPreguntaNumerica) {
                // Procesar pregunta numérica
                crearSeccionPreguntaNumerica(sheet, pregunta, rowNum, headerStyle, dataStyle);
            } else {
                // Procesar pregunta de opciones múltiples
                crearSeccionOpcionesMultiples(sheet, pregunta, rowNum, headerStyle, dataStyle);
            }
        } catch (Exception e) {
            Row errorRow = sheet.createRow(rowNum);
            errorRow.createCell(0).setCellValue("Error al procesar datos: " + e.getMessage());
            System.out.println("Error procesando pregunta individual: " + e.getMessage());
        }
        
        // Ajustar columnas
        for (int i = 0; i < 4; i++) {
            sheet.autoSizeColumn(i);
        }
    }
    
    private int crearSeccionPreguntaNumerica(Sheet sheet, Map<String, Object> pregunta, int rowNum,
                                           CellStyle headerStyle, CellStyle dataStyle) {
        
        // Título de sección
        Row sectionTitleRow = sheet.createRow(rowNum++);
        sectionTitleRow.createCell(0).setCellValue("=== RESPUESTAS NUMÉRICAS ===");
        sectionTitleRow.getCell(0).setCellStyle(headerStyle);
        
        // Encabezados
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("N°");
        headerRow.createCell(1).setCellValue("Respuesta");
        headerRow.getCell(0).setCellStyle(headerStyle);
        headerRow.getCell(1).setCellStyle(headerStyle);
        
        // Datos
        @SuppressWarnings("unchecked")
        java.util.List<String> respuestasTexto = (java.util.List<String>) pregunta.get("respuestasTexto");
        
        if (respuestasTexto != null && !respuestasTexto.isEmpty()) {
            int contador = 1;
            for (String respuesta : respuestasTexto) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(contador++);
                dataRow.createCell(1).setCellValue(respuesta);
                dataRow.getCell(0).setCellStyle(dataStyle);
                dataRow.getCell(1).setCellStyle(dataStyle);
                
                // Limitar a 100 respuestas para evitar archivos muy grandes
                if (contador > 100) {
                    Row limitRow = sheet.createRow(rowNum++);
                    limitRow.createCell(0).setCellValue("...");
                    limitRow.createCell(1).setCellValue("(Se muestran solo las primeras 100 respuestas)");
                    break;
                }
            }
        } else {
            Row noDataRow = sheet.createRow(rowNum++);
            noDataRow.createCell(0).setCellValue("No hay respuestas de texto disponibles");
        }
        
        return rowNum;
    }
    
    private int crearSeccionOpcionesMultiples(Sheet sheet, Map<String, Object> pregunta, int rowNum,
                                            CellStyle headerStyle, CellStyle dataStyle) {
        
        // Título de sección
        Row sectionTitleRow = sheet.createRow(rowNum++);
        sectionTitleRow.createCell(0).setCellValue("=== OPCIONES Y RESPUESTAS ===");
        sectionTitleRow.getCell(0).setCellStyle(headerStyle);
        
        // Encabezados
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("Opción");
        headerRow.createCell(1).setCellValue("Cantidad");
        headerRow.createCell(2).setCellValue("Porcentaje");
        headerRow.getCell(0).setCellStyle(headerStyle);
        headerRow.getCell(1).setCellStyle(headerStyle);
        headerRow.getCell(2).setCellStyle(headerStyle);
        
        // Calcular total para porcentajes
        @SuppressWarnings("unchecked")
        java.util.List<Map<String, Object>> opciones = (java.util.List<Map<String, Object>>) pregunta.get("opcionesMultiples");
        
        int totalRespuestas = 0;
        if (opciones != null) {
            for (Map<String, Object> opcion : opciones) {
                Object cantidadObj = opcion.get("cantidadRespuestas");
                if (cantidadObj instanceof Number) {
                    totalRespuestas += ((Number) cantidadObj).intValue();
                }
            }
        }
        
        // Datos de opciones
        if (opciones != null && !opciones.isEmpty()) {
            for (Map<String, Object> opcion : opciones) {
                Row dataRow = sheet.createRow(rowNum++);
                
                // Opción
                String textoOpcion = (String) opcion.get("textoOpcion");
                dataRow.createCell(0).setCellValue(textoOpcion != null ? textoOpcion : "Sin texto");
                dataRow.getCell(0).setCellStyle(dataStyle);
                
                // Cantidad
                Object cantidadObj = opcion.get("cantidadRespuestas");
                int cantidad = cantidadObj instanceof Number ? ((Number) cantidadObj).intValue() : 0;
                dataRow.createCell(1).setCellValue(cantidad);
                dataRow.getCell(1).setCellStyle(dataStyle);
                
                // Porcentaje
                double porcentaje = totalRespuestas > 0 ? (cantidad * 100.0 / totalRespuestas) : 0.0;
                dataRow.createCell(2).setCellValue(String.format("%.1f%%", porcentaje));
                dataRow.getCell(2).setCellStyle(dataStyle);
            }
            
            // Fila de total
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(0).setCellValue("TOTAL");
            totalRow.createCell(1).setCellValue(totalRespuestas);
            totalRow.createCell(2).setCellValue("100.0%");
            totalRow.getCell(0).setCellStyle(headerStyle);
            totalRow.getCell(1).setCellStyle(headerStyle);
            totalRow.getCell(2).setCellStyle(headerStyle);
        } else {
            Row noDataRow = sheet.createRow(rowNum++);
            noDataRow.createCell(0).setCellValue("No hay opciones múltiples disponibles");
        }
        
        return rowNum;
    }
}
