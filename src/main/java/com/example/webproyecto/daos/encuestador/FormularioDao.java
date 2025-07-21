package com.example.webproyecto.daos.encuestador;
import com.example.webproyecto.beans.Formulario;
import com.example.webproyecto.daos.BaseDao;
import java.util.List;
import java.util.ArrayList;
import java.sql.*;

public class FormularioDao extends BaseDao {

    /**
     * Retorna el título de un formulario dado su ID.
     *
     * @param idFormulario ID del formulario
     * @return título del formulario si existe, cadena vacía si no
     */
    public String obtenerTituloFormularioPorId(int idFormulario) {
        String titulo = "";
        // La consulta debe tener un WHERE con el placeholder '?'
        String sql = "SELECT titulo FROM formulario WHERE idFormulario = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario); // Ahora sí hay un placeholder para este parámetro

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    titulo = rs.getString("titulo");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return titulo;
    }

    public List<Formulario> obtenerFormularioPorId(int idFormulario) throws SQLException {
        List<Formulario> formularios = new ArrayList<>();
        String sql = "SELECT idFormulario, titulo, activo FROM formulario WHERE idFormulario = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idFormulario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Formulario f = new Formulario();
                    f.setIdFormulario(rs.getInt("idFormulario"));
                    f.setTitulo(rs.getString("titulo"));
                    f.setActivo(rs.getBoolean("activo"));
                    formularios.add(f);
                }
            }
        }
        return formularios;
    }
    public List<Formulario> obtenerTodosLosFormularios() throws SQLException {
        List<Formulario> formularios = new ArrayList<>();
        String sql = "SELECT idFormulario, titulo, activo FROM formulario";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Formulario f = new Formulario();
                f.setIdFormulario(rs.getInt("idFormulario"));
                f.setTitulo(rs.getString("titulo"));
                f.setActivo(rs.getBoolean("activo"));
                formularios.add(f);
            }
        }
        return formularios;
    }
    public Formulario obtenerFormularioPorIdUnico(int idFormulario) throws SQLException {
        Formulario formulario = null;
        String sql = "SELECT * FROM formulario WHERE idFormulario = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idFormulario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                formulario = new Formulario();
                formulario.setIdFormulario(rs.getInt("idFormulario"));
                formulario.setTitulo(rs.getString("titulo"));
                formulario.setDescripcion(rs.getString("descripcion"));
                formulario.setFechaCreacion(rs.getTimestamp("fechaCreacion"));
                formulario.setIdCoordinador(rs.getInt("idCoordinador"));
                formulario.setIdCarpeta(rs.getInt("idCarpeta"));
                // formulario.setActivo(rs.getBoolean("activo")); // si usas este campo

            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return formulario;
    }


    public void actualizarFormulario(Formulario formulario) throws SQLException {
        String sql = "UPDATE formulario SET titulo = ?, activo = ? WHERE idFormulario = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, formulario.getTitulo());
            ps.setBoolean(2, formulario.isActivo());
            ps.setInt(3, formulario.getIdFormulario());
            ps.executeUpdate();
        }
    }

    public void eliminarFormulario(int idFormulario) throws SQLException {
        String sql = "DELETE FROM formulario WHERE idFormulario = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idFormulario);
            ps.executeUpdate();
        }
    }
    public void insertarFormulario(Formulario formulario) throws SQLException {
        String sql = "INSERT INTO formulario (titulo, descripcion, fechaCreacion, idCoordinador, idCarpeta, activo) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, formulario.getTitulo());
            ps.setString(2, formulario.getDescripcion());
            ps.setDate(3, new java.sql.Date(formulario.getFechaCreacion().getTime()));
            ps.setInt(4, formulario.getIdCoordinador());
            ps.setInt(5, formulario.getIdCarpeta());
            ps.setBoolean(6, formulario.isActivo());
            ps.executeUpdate();
        }
    }
    public List<Formulario> listarFormularios() throws SQLException {
        List<Formulario> formularios = new ArrayList<>();
        String sql = "SELECT idFormulario, titulo, descripcion, fechaCreacion, idCoordinador, idCarpeta FROM formulario ORDER BY titulo";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Formulario f = new Formulario();
                f.setIdFormulario(rs.getInt("idFormulario"));
                f.setTitulo(rs.getString("titulo"));
                f.setDescripcion(rs.getString("descripcion"));
                f.setFechaCreacion(new java.util.Date(rs.getDate("fechaCreacion").getTime()));
                f.setIdCoordinador(rs.getInt("idCoordinador"));
                f.setIdCarpeta(rs.getInt("idCarpeta"));
                formularios.add(f);
            }
        } catch (SQLException e) {
            throw e;
        }
        return formularios;
    }

    public List<Formulario> obtenerTodos() {
        List<Formulario> lista = new ArrayList<>();
        String sql = "SELECT idformulario, titulo, descripcion, fechacreacion FROM formulario";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Formulario form = new Formulario();
                form.setIdFormulario(rs.getInt("idformulario"));
                form.setTitulo(rs.getString("titulo"));
                form.setDescripcion(rs.getString("descripcion"));
                form.setFechaCreacion(rs.getDate("fechacreacion"));
                lista.add(form);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<Formulario> buscarPorTitulo(String titulo) {
        List<Formulario> lista = new ArrayList<>();
        String sql = "SELECT idformulario, titulo, descripcion, fechacreacion FROM formulario WHERE titulo LIKE ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + titulo + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Formulario form = new Formulario();
                form.setIdFormulario(rs.getInt("idformulario"));
                form.setTitulo(rs.getString("titulo"));
                form.setDescripcion(rs.getString("descripcion"));
                form.setFechaCreacion(rs.getDate("fechacreacion"));
                lista.add(form);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}

