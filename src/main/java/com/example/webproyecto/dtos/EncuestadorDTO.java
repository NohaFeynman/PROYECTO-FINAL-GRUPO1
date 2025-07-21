package com.example.webproyecto.dtos;

import java.io.Serializable;

public class EncuestadorDTO implements Serializable {
    private UsuarioDTO usuario;
    private CredencialDTO credencial;
    private String zonaTrabajoNombre;

    public EncuestadorDTO() {}

    public UsuarioDTO getUsuario() {
        return usuario;
    }
    public void setUsuario(UsuarioDTO usuario) {
        this.usuario = usuario;
    }

    public CredencialDTO getCredencial() {
        return credencial;
    }
    public void setCredencial(CredencialDTO credencial) {
        this.credencial = credencial;
    }

    public String getZonaTrabajoNombre() {
        return zonaTrabajoNombre;
    }
    public void setZonaTrabajoNombre(String zonaTrabajoNombre) {
        this.zonaTrabajoNombre = zonaTrabajoNombre;
    }
}
