package com.xiaoyuan.util;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Database connection manager using JDBC.
 * Manages MySQL connections for the application.
 */
public class DBConnectionManager {

    private static DataSource dataSource;

    static {
        try {
            Context ctx = new InitialContext();
            dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/xiaoyuan_huodong");
        } catch (NamingException e) {
            throw new RuntimeException(
                    "JNDI DataSource lookup failed. Check META-INF/context.xml is configured correctly.", e);
        }
    }

    /**
     * Get a new database connection.
     * Callers are responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Test if database connection is working.
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("Database connection test failed: " + e.getMessage());
            return false;
        }
    }
}
