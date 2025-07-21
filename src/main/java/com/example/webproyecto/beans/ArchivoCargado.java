package com.example.webproyecto.beans;

import java.time.LocalDateTime;

public class ArchivoCargado {
    private int idArchivoCargado;
    private String nombreArchivoOriginal;
    private byte[] contenido;
    private LocalDateTime fechaCarga;
    private int idUsuarioQueCargo; // Foreign Key a Usuario
    private String estadoProcesamiento; // Ej: "EXITOSO", "CON_ERRORES", "PENDIENTE"
    private String mensajeProcesamiento; // Detalles del procesamiento (ej: errores)
    private Integer idFormularioAsociado; // Opcional: si la carga crea/modifica un Formulario
    private String nombreUsuarioQueCargo;
    private String tipoArchivo;

    // Constructor vacío (necesario para frameworks/mapeos)
    public ArchivoCargado() {
    }
  //  Constructor con todos los campos
    //cosaaaa
    //hola
    //lalalallaa
    // Constructor con los campos más importantes
    public ArchivoCargado(String nombreArchivoOriginal, byte[] contenido, LocalDateTime fechaCarga, int idUsuarioQueCargo, String estadoProcesamiento, String mensajeProcesamiento, Integer idFormularioAsociado) {
        this.nombreArchivoOriginal = nombreArchivoOriginal;
        this.contenido = contenido;
        this.fechaCarga = fechaCarga;
        this.idUsuarioQueCargo = idUsuarioQueCargo;
        this.estadoProcesamiento = estadoProcesamiento;
        this.mensajeProcesamiento = mensajeProcesamiento;
        this.idFormularioAsociado = idFormularioAsociado;
    }

    // Getters y Setters
    public int getIdArchivoCargado() {
        return idArchivoCargado;
    }

    public void setIdArchivoCargado(int idArchivoCargado) {
        this.idArchivoCargado = idArchivoCargado;
    }

    public String getNombreArchivoOriginal() {
        return nombreArchivoOriginal;
    }

    public void setNombreArchivoOriginal(String nombreArchivoOriginal) {
        this.nombreArchivoOriginal = nombreArchivoOriginal;
    }

    public byte[] getContenido() {
        return contenido;
    }

    public void setContenido(byte[] contenido) {
        this.contenido = contenido;
    }

    public LocalDateTime getFechaCarga() {
        return fechaCarga;
    }

    public void setFechaCarga(LocalDateTime fechaCarga) {
        this.fechaCarga = fechaCarga;
    }

    public int getIdUsuarioQueCargo() {
        return idUsuarioQueCargo;
    }

    public void setIdUsuarioQueCargo(int idUsuarioQueCargo) {
        this.idUsuarioQueCargo = idUsuarioQueCargo;
    }

    public String getEstadoProcesamiento() {
        return estadoProcesamiento;
    }

    public void setEstadoProcesamiento(String estadoProcesamiento) {
        this.estadoProcesamiento = estadoProcesamiento;
    }

    public String getMensajeProcesamiento() {
        return mensajeProcesamiento;
    }

    public void setMensajeProcesamiento(String mensajeProcesamiento) {
        this.mensajeProcesamiento = mensajeProcesamiento;
    }

    public Integer getIdFormularioAsociado() {
        return idFormularioAsociado;
    }

    public void setIdFormularioAsociado(Integer idFormularioAsociado) {
        this.idFormularioAsociado = idFormularioAsociado;
    }

    public String getNombreUsuarioQueCargo() {
        return nombreUsuarioQueCargo;
    }

    public void setNombreUsuarioQueCargo(String nombreUsuarioQueCargo) {
        this.nombreUsuarioQueCargo = nombreUsuarioQueCargo;
    }

    public String getTipoArchivo() {
        return tipoArchivo;
    }

    public void setTipoArchivo(String tipoArchivo) {
        this.tipoArchivo = tipoArchivo;
    }

    public java.util.Date getFechaCargaDate() {
        return (fechaCarga != null) ? java.sql.Timestamp.valueOf(fechaCarga) : null;
    }

}
