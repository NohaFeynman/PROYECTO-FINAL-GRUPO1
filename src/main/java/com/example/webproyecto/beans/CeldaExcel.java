package com.example.webproyecto.beans;

public class CeldaExcel {
    private String valor;
    private int rowspan;
    private int colspan;

    public CeldaExcel(String valor, int rowspan, int colspan) {
        this.valor = valor;
        this.rowspan = rowspan;
        this.colspan = colspan;
    }

    public String getValor() {
        return valor;
    }

    public int getRowspan() {
        return rowspan;
    }

    public int getColspan() {
        return colspan;
    }
}
