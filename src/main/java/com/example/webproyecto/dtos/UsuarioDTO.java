package com.example.webproyecto.dtos;

import java.io.Serializable;

public class UsuarioDTO implements Serializable {
    private Integer idUsuario;
    private String nombre;
    private String apellidopaterno;
    private String apellidomaterno;
    private String dni;
    private Integer idEstado;
    private Integer idDistrito;
    private Integer idZonaTrabajo;
    private java.util.Date fechaRegistro;

    public UsuarioDTO() {}

    public Integer getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Integer idUsuario) { this.idUsuario = idUsuario; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellidopaterno() { return apellidopaterno; }
    public void setApellidopaterno(String apellidopaterno) { this.apellidopaterno = apellidopaterno; }

    public String getApellidomaterno() { return apellidomaterno; }
    public void setApellidomaterno(String apellidomaterno) { this.apellidomaterno = apellidomaterno; }

    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }

    public Integer getIdEstado() { return idEstado; }
    public void setIdEstado(Integer idEstado) { this.idEstado = idEstado; }

    public Integer getIdDistrito() { return idDistrito; }
    public void setIdDistrito(Integer idDistrito) { this.idDistrito = idDistrito; }

    public Integer getIdZonaTrabajo() { return idZonaTrabajo; }
    public void setIdZonaTrabajo(Integer idZonaTrabajo) { this.idZonaTrabajo = idZonaTrabajo; }

    public java.util.Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(java.util.Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
