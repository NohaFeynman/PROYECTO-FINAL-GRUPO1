package com.example.webproyecto.modelos;

public class RespuestaCompleta {
    private int idPregunta;
    private String textoRespuesta;
    private Integer idOpcion; // Puede ser null

    public RespuestaCompleta(int idPregunta, String textoRespuesta, Integer idOpcion) {
        this.idPregunta = idPregunta;
        this.textoRespuesta = textoRespuesta;
        this.idOpcion = idOpcion;
    }

    public int getIdPregunta() {
        return idPregunta;
    }

    public String getTextoRespuesta() {
        return textoRespuesta;
    }

    public Integer getIdOpcion() {
        return idOpcion;
    }
}
