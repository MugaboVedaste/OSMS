package com.osms.util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

/**
 * Utility class for sending email notifications
 */
public class EmailUtil {
    
    // Email configuration
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_FROM = "your-email@gmail.com"; // Replace with your email
    private static final String EMAIL_PASSWORD = "your-password"; // Replace with your password or app password
    
    /**
     * Send an email notification
     * 
     * @param to Recipient email address
     * @param subject Email subject
     * @param body Email body
     * @return true if email was sent successfully, false otherwise
     */
    public static boolean sendEmail(String to, String subject, String body) {
        try {
            // Set mail properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            
            // Create a Session object
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });
            
            // Create a MimeMessage object
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);
            
            // Send the message
            Transport.send(message);
            
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Send a notification about low inventory levels
     * 
     * @param supplierEmail Supplier's email address
     * @param productName Name of the product with low inventory
     * @param storeLocation Location of the store
     * @return true if notification was sent successfully, false otherwise
     */
    public static boolean sendLowInventoryNotification(String supplierEmail, String productName, String storeLocation) {
        String subject = "Low Inventory Alert: " + productName;
        String body = "Dear Supplier,\n\n"
                + "This is to inform you that the inventory level for " + productName 
                + " at store location " + storeLocation + " has fallen below 20% of its capacity.\n\n"
                + "Please arrange for a new supply as soon as possible.\n\n"
                + "Regards,\n"
                + "Online Shop Management System";
        
        return sendEmail(supplierEmail, subject, body);
    }
} 