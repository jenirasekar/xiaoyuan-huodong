package com.xiaoyuan.servlet;

import com.xiaoyuan.dao.ActivityDAO;
import com.xiaoyuan.dao.RegistrationDAO;
import com.xiaoyuan.model.Activity;
import com.xiaoyuan.model.Registration;
import com.xiaoyuan.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Handles Excel export for activity participant lists.
 */
public class ExportServlet extends HttpServlet {

    private final RegistrationDAO registrationDAO = new RegistrationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

        // Only organizers and admins can export
        if (!"organizer".equals(user.getRole()) && !"admin".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String activityIdStr = req.getParameter("activityId");
        if (activityIdStr == null || activityIdStr.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing activityId parameter.");
            return;
        }

        try {
            int activityId = Integer.parseInt(activityIdStr);
            Activity activity = activityDAO.findById(activityId);
            if (activity == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Activity not found.");
                return;
            }

            List<Registration> registrations = registrationDAO.findByActivity(activityId);

            // Build Excel workbook
            Workbook workbook = new XSSFWorkbook();

            // Create styles
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);

            CellStyle centerStyle = workbook.createCellStyle();
            centerStyle.cloneStyleFrom(dataStyle);
            centerStyle.setAlignment(HorizontalAlignment.CENTER);

            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

            Sheet sheet = workbook.createSheet("Participants");

            // ---- Header info rows ----
            int rowIdx = 0;

            Row titleRow = sheet.createRow(rowIdx++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Activity: " + activity.getTitle());
            Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 14);
            CellStyle titleStyle = workbook.createCellStyle();
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);

            Row infoRow1 = sheet.createRow(rowIdx++);
            infoRow1.createCell(0).setCellValue("Location: " + activity.getLocation());
            infoRow1.createCell(1).setCellValue("Time: " + activity.getActivityTime().format(dtf));

            Row infoRow2 = sheet.createRow(rowIdx++);
            infoRow2.createCell(0).setCellValue("Category: " + activity.getCategoryName());
            infoRow2.createCell(1).setCellValue("Max Participants: " + activity.getMaxParticipants());
            infoRow2.createCell(2).setCellValue("Points: " + activity.getPoints());

            Row infoRow3 = sheet.createRow(rowIdx++);
            infoRow3.createCell(0).setCellValue("Status: " + activity.getStatus());
            infoRow3.createCell(1).setCellValue("Total Registered: " + activity.getRegisteredCount());

            // blank row
            rowIdx++;

            // ---- Table header ----
            Row headerRow = sheet.createRow(rowIdx++);
            String[] headers = {"No.", "Student Name", "Status", "Registered At", "Checked In", "Review Comment"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // ---- Data rows ----
            int no = 1;
            for (Registration reg : registrations) {
                Row row = sheet.createRow(rowIdx++);
                Cell cell0 = row.createCell(0);
                cell0.setCellValue(no++);
                cell0.setCellStyle(centerStyle);

                Cell cell1 = row.createCell(1);
                cell1.setCellValue(reg.getStudentName());
                cell1.setCellStyle(dataStyle);

                Cell cell2 = row.createCell(2);
                cell2.setCellValue(reg.getStatus());
                cell2.setCellStyle(centerStyle);

                Cell cell3 = row.createCell(3);
                cell3.setCellValue(reg.getRegisteredAt() != null ? reg.getRegisteredAt().format(dtf) : "-");
                cell3.setCellStyle(centerStyle);

                Cell cell4 = row.createCell(4);
                cell4.setCellValue(reg.isCheckedIn() ? "Yes" : "No");
                cell4.setCellStyle(centerStyle);

                Cell cell5 = row.createCell(5);
                cell5.setCellValue(reg.getReviewComment() != null ? reg.getReviewComment() : "");
                cell5.setCellStyle(dataStyle);
            }

            // Auto-size columns (with reasonable max width)
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                int width = sheet.getColumnWidth(i);
                if (width > 15000) {
                    sheet.setColumnWidth(i, 15000);
                } else if (width < 3000) {
                    sheet.setColumnWidth(i, 3000);
                }
            }

            // Set response headers for Excel download
            String filename = "participants_" + activity.getTitle().replaceAll("[^a-zA-Z0-9_\\-\\u4e00-\\u9fa5]", "_") + ".xlsx";
            resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            resp.setHeader("Content-Disposition", "attachment; filename=\"" +
                    java.net.URLEncoder.encode(filename, "UTF-8") + "\"");
            resp.setHeader("Cache-Control", "no-cache");

            workbook.write(resp.getOutputStream());
            workbook.close();

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid activityId.");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to generate Excel: " + e.getMessage());
        }
    }
}
