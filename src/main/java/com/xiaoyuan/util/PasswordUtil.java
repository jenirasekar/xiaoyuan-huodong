package com.xiaoyuan.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility class for password hashing using SHA-256.
 */
public class PasswordUtil {

    private static final String SALT = "XiaoYuanHuoDong2026";

    /**
     * Hash a password with SHA-256 + salt.
     */
    public static String hash(String plainPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String salted = plainPassword + SALT;
            byte[] hashBytes = digest.digest(salted.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    /**
     * Verify a plain text password against a stored hash.
     */
    public static boolean verify(String plainPassword, String storedHash) {
        String computedHash = hash(plainPassword);
        return computedHash.equals(storedHash);
    }
}
