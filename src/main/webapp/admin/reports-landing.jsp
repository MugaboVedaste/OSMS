<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect to the report generator servlet with default parameters
    response.sendRedirect(request.getContextPath() + "/admin/generateReport?reportType=SalesReport&dateRange=Last7Days");
%> 