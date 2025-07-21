package com.example.webproyecto.beans;
import java.util.Date;

public class Usuario {
    private int idUsuario;
    private String nombre;
    private String apellidopaterno;
    private String apellidomaterno;
    private String dni;
    private String direccion;
    private int idDistrito; // Distrito de Residencia
    private int idRol;
    private int idEstado;
    private String foto; // Esta propiedad se usará para el contenido BLOB (Base64)

    // --- NUEVAS PROPIEDADES ---
    private Integer idDistritoTrabajo; // Nuevo: Distrito de Trabajo
    private Integer idZonaTrabajo;     // Nuevo: Zona de Trabajo
    // -------------------------

    private java.util.Date fechaRegistro;

    // Getters y Setters
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getApellidopaterno() { return apellidopaterno; }
    public void setApellidopaterno(String apellidopaterno) { this.apellidopaterno = apellidopaterno; }
    public String getApellidomaterno() { return apellidomaterno; }
    public void setApellidomaterno(String apellidomaterno) { this.apellidomaterno = apellidomaterno; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public int getIdDistrito() { return idDistrito; }
    public void setIdDistrito(int idDistrito) { this.idDistrito = idDistrito; }
    public int getIdRol() { return idRol; }
    public void setIdRol(int idRol) { this.idRol = idRol; }
    public int getIdEstado() { return idEstado; }
    public void setIdEstado(int idEstado) { this.idEstado = idEstado; }

    public String getFoto() { return foto; } // Getter para el contenido de la foto (Base64)
    public void setFoto(String foto) { this.foto = foto; } // Setter para el contenido de la foto (Base64)

    // --- NUEVOS GETTERS Y SETTERS ---
    public Integer getIdDistritoTrabajo() { return idDistritoTrabajo; }
    public void setIdDistritoTrabajo(Integer idDistritoTrabajo) { this.idDistritoTrabajo = idDistritoTrabajo; }

    public Integer getIdZonaTrabajo() { return idZonaTrabajo; }
    public void setIdZonaTrabajo(Integer idZonaTrabajo) { this.idZonaTrabajo = idZonaTrabajo; }
    // ---------------------------------

    public java.util.Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(java.util.Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
