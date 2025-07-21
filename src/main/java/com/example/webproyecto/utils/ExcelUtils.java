package com.example.webproyecto.utils;

import com.example.webproyecto.modelos.RespuestaCompleta;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class ExcelUtils {

    public static List<RespuestaCompleta> leerRespuestasDesdeExcel(InputStream inputStream) {
        List<RespuestaCompleta> respuestas = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0); // Primera hoja
            int filaInicio = 5; // Línea 6 en Excel (índice 5)

            for (int i = filaInicio; i <= sheet.getLastRowNum(); i++) {
                Row fila = sheet.getRow(i);
                if (fila == null) continue;

                // Asumimos que las columnas están organizadas como:
                // A: idPregunta
                // B: textoRespuesta
                // C: idOpcion (opcional, puede ser vacío)

                Cell celdaIdPregunta = fila.getCell(0);
                Cell celdaTexto = fila.getCell(1);
                Cell celdaOpcion = fila.getCell(2);

                int idPregunta = (int) celdaIdPregunta.getNumericCellValue();
                String textoRespuesta = (celdaTexto != null) ? celdaTexto.toString().trim() : null;

                Integer idOpcion = null;
                if (celdaOpcion != null && celdaOpcion.getCellType() == CellType.NUMERIC) {
                    idOpcion = (int) celdaOpcion.getNumericCellValue();
                }

                respuestas.add(new RespuestaCompleta(idPregunta, textoRespuesta, idOpcion));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return respuestas;
    }
}
