package com.example.webproyecto.daos;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public abstract class BaseDao {
    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            ex.printStackTrace();
        }
        String user = "root";
        String pass = "root";
        String url = "jdbc:mysql://localhost:3306/proyecto";
        return DriverManager.getConnection(url, user, pass);
    }
}
/*
* String user = "admin";
  String pass = "8uEdUfPSs6C6f4Cnw8Oj";
  String url = "jdbc:mysql://database-iweb-grupo1.c5hy9g2gcf2c.us-east-1.rds.amazonaws.com:3306/proyecto?serverTimezone=America/Lima";
*
*
* */
