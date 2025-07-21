package com.example.webproyecto.dtos;

import java.io.Serializable;

public class CredencialDTO implements Serializable {
    private String correo;

    public CredencialDTO() {}

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
}
