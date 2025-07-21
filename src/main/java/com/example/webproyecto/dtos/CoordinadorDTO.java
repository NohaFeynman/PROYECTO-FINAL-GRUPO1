package com.example.webproyecto.dtos;

import com.example.webproyecto.beans.Usuario;
import com.example.webproyecto.beans.Credencial;

public class CoordinadorDTO {
    private Usuario usuario;
    private Credencial credencial;
    private String zonaTrabajoNombre;
    private String distritoNombre;

    public String getDistritoNombre() { return distritoNombre; }
    public void setDistritoNombre(String distritoNombre) { this.distritoNombre = distritoNombre; }

    public String getZonaTrabajoNombre() {
        return zonaTrabajoNombre;
    }

    public void setZonaTrabajoNombre(String zonaTrabajoNombre) {
        this.zonaTrabajoNombre = zonaTrabajoNombre;
    }

    public CoordinadorDTO(Usuario usuario, Credencial credencial) {
        this.usuario = usuario;
        this.credencial = credencial;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public Credencial getCredencial() {
        return credencial;
    }
}
