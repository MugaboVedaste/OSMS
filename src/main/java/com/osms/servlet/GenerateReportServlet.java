package com.osms.servlet;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.osms.dao.ReportDAO;
import com.osms.model.SalesReport;
import com.osms.model.InventoryReport;
import com.osms.model.CategoryReport;

/**
 * Servlet to handle report generation requests
 */
public class GenerateReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public GenerateReportServlet() {
        super();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is an admin
        String userType = (String) request.getSession().getAttribute("userType");
        if (userType == null || !userType.equals("Admin")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get report parameters
        String reportType = request.getParameter("reportType");
        if (reportType == null) {
            reportType = "SalesReport"; // Default report type
        }
        
        String dateRange = request.getParameter("dateRange");
        if (dateRange == null) {
            dateRange = "Last7Days"; // Default date range
        }
        
        // Set up the date range based on selection
        Date startDate = null;
        Date endDate = null;
        
        // Get the current date for end date by default
        Calendar cal = Calendar.getInstance();
        endDate = cal.getTime();
        
        // Determine start date based on selected range
        switch (dateRange) {
            case "Today":
                startDate = endDate;
                break;
            case "Yesterday":
                cal.add(Calendar.DAY_OF_MONTH, -1);
                startDate = cal.getTime();
                break;
            case "Last7Days":
                cal.add(Calendar.DAY_OF_MONTH, -6); // Last 7 days including today
                startDate = cal.getTime();
                break;
            case "Last30Days":
                cal.add(Calendar.DAY_OF_MONTH, -29); // Last 30 days including today
                startDate = cal.getTime();
                break;
            case "ThisMonth":
                cal.set(Calendar.DAY_OF_MONTH, 1);
                startDate = cal.getTime();
                break;
            case "LastMonth":
                cal.add(Calendar.MONTH, -1);
                cal.set(Calendar.DAY_OF_MONTH, 1);
                startDate = cal.getTime();
                cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
                endDate = cal.getTime();
                break;
            case "CustomRange":
                // Parse custom start and end dates
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                try {
                    String startDateStr = request.getParameter("startDate");
                    String endDateStr = request.getParameter("endDate");
                    
                    if (startDateStr != null && !startDateStr.isEmpty()) {
                        startDate = dateFormat.parse(startDateStr);
                    } else {
                        cal.add(Calendar.DAY_OF_MONTH, -29);
                        startDate = cal.getTime();
                    }
                    
                    if (endDateStr != null && !endDateStr.isEmpty()) {
                        endDate = dateFormat.parse(endDateStr);
                        // Set to end of day
                        cal.setTime(endDate);
                        cal.set(Calendar.HOUR_OF_DAY, 23);
                        cal.set(Calendar.MINUTE, 59);
                        cal.set(Calendar.SECOND, 59);
                        endDate = cal.getTime();
                    }
                } catch (ParseException e) {
                    e.printStackTrace();
                    // Default to last 30 days if date parsing fails
                    cal = Calendar.getInstance();
                    endDate = cal.getTime();
                    cal.add(Calendar.DAY_OF_MONTH, -29);
                    startDate = cal.getTime();
                }
                break;
            default:
                cal.add(Calendar.DAY_OF_MONTH, -6);
                startDate = cal.getTime();
        }
        
        // Format dates for display
        SimpleDateFormat displayFormat = new SimpleDateFormat("MMM dd, yyyy");
        request.setAttribute("startDateDisplay", displayFormat.format(startDate));
        request.setAttribute("endDateDisplay", displayFormat.format(endDate));
        
        // Create report DAO
        ReportDAO reportDAO = new ReportDAO();
        
        // Generate the requested report
        switch (reportType) {
            case "SalesReport":
                List<SalesReport> salesReport = reportDAO.getSalesReport(startDate, endDate);
                request.setAttribute("salesReport", salesReport);
                
                // Get daily sales summary for the sales chart
                Map<String, Double> dailySales = reportDAO.getDailySalesSummary(7);
                request.setAttribute("dailySales", dailySales);
                
                // Get total sales
                double totalSales = reportDAO.getTotalSales(startDate, endDate);
                request.setAttribute("totalSales", totalSales);
                break;
                
            case "InventoryReport":
                List<InventoryReport> inventoryReport = reportDAO.getInventoryReport();
                request.setAttribute("inventoryReport", inventoryReport);
                break;
                
            default:
                // Default to sales report
                salesReport = reportDAO.getSalesReport(startDate, endDate);
                request.setAttribute("salesReport", salesReport);
        }
        
        // Get category distribution for the pie chart (for all report types)
        Map<String, Integer> categoryDistribution = reportDAO.getProductCategoryDistribution();
        request.setAttribute("categoryDistribution", categoryDistribution);
        
        // Store the report parameters for the form
        request.setAttribute("reportType", reportType);
        request.setAttribute("dateRange", dateRange);
        
        // Forward to the reports page
        request.getRequestDispatcher("reports.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
} 