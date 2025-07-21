package com.example.webproyecto.beans;

public class Zona {
    private int idzona;
    private String nombrezona;

    // Getters y Setters existentes
    public int getIdzona() { return idzona; }
    public void setIdzona(int idzona) { this.idzona = idzona; }
    public String getNombrezona() { return nombrezona; }
    public void setNombrezona(String nombrezona) { this.nombrezona = nombrezona; }

    // ¡¡¡CAMBIO AQUÍ: El constructor ahora acepta 'int' en lugar de 'Integer' para idZona!!!
    public Zona(int idZona, String nombreZona) { // Cambiado 'Integer' a 'int'
        this.idzona = idZona;
        this.nombrezona = nombreZona;
    }

    // Mantén estos getters/setters si los usas en otros lugares y necesitas la envoltura Integer
    public Integer getIdZona() {
        return idzona; // El int se autoboxeará a Integer aquí
    }

    public void setIdZona(Integer idzona) {
        this.idzona = idzona; // El Integer se auto-unboxeará a int aquí
    }

    public String getNombreZona() {
        return nombrezona;
    }

    public void setNombreZona(String nombrezona) {this.nombrezona = nombrezona;}
}
