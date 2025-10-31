// Email sending is handled by a local backend (Express + Nodemailer)

// Gmail SMTP Configuration (for reference)
const SMTP_CONFIG = {
  host: 'REMOVED_SECRET',
  port: 587,
  secure: false,
  auth: {
    user: 'REMOVED_SECRET',
    pass: 'REMOVED_SECRET'
  },
  from: {
    email: 'REMOVED_SECRET',
    name: 'UmmaHub'
  }
};

// HTML Email Templates
const getEmailTemplate = (type, organizationData) => {
  const { organizationName } = organizationData;
  const contactName = (organizationData?.userDetails?.name) || (organizationData?.contactPerson) || 'User';
  
  if (type === 'accepted') {
    return {
      subject: `🎉 Organization Verification Approved - ${organizationName}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Organization Verification Approved</title>
          <style>
            body { 
              font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
              margin: 0; 
              padding: 0; 
              background-color: #f5f7fa; 
            }
            .container { 
              max-width: 600px; 
              margin: 0 auto; 
              background-color: #ffffff; 
              border-radius: 12px; 
              overflow: hidden; 
              box-shadow: 0 8px 32px rgba(0, 105, 92, 0.15); 
            }
            .header { 
              background: linear-gradient(135deg, #00695c 0%, #00897b 100%); 
              color: white; 
              padding: 30px; 
              text-align: center; 
            }
            .header h1 { 
              margin: 0; 
              font-size: 28px; 
              font-weight: 600; 
            }
            .header .subtitle { 
              margin: 8px 0 0 0; 
              font-size: 16px; 
              opacity: 0.9; 
            }
            .content { 
              padding: 40px 30px; 
            }
            .greeting { 
              font-size: 18px; 
              color: #2c3e50; 
              margin-bottom: 20px; 
            }
            .message { 
              font-size: 16px; 
              line-height: 1.6; 
              color: #34495e; 
              margin-bottom: 30px; 
            }
            .status-badge { 
              display: inline-block; 
              padding: 12px 24px; 
              border-radius: 25px; 
              font-weight: 600; 
              font-size: 16px; 
              margin: 20px 0; 
              background-color: #e8f5e8; 
              color: #2e7d32; 
              border: 2px solid #4caf50; 
            }
            .organization-info { 
              background-color: #f8f9fa; 
              border-left: 4px solid #00695c; 
              padding: 20px; 
              margin: 20px 0; 
              border-radius: 0 8px 8px 0; 
            }
            .footer { 
              background-color: #f8f9fa; 
              padding: 30px; 
              text-align: center; 
              border-top: 1px solid #e9ecef; 
            }
            .footer p { 
              margin: 5px 0; 
              color: #6c757d; 
              font-size: 14px; 
            }
            .mosque-icon { 
              font-size: 32px; 
              margin-bottom: 10px; 
            }
            .contact-info { 
              margin-top: 20px; 
              padding-top: 20px; 
              border-top: 1px solid #e9ecef; 
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <div class="mosque-icon">🕌</div>
              <h1>UmmaHub</h1>
              <p class="subtitle">Mosque Community Platform</p>
            </div>
            
            <div class="content">
              <p class="greeting">Dear ${contactName},</p>
              
              <div class="status-badge">✅ VERIFICATION APPROVED</div>
              
              <div class="message">
                <p>We are delighted to inform you that your organization verification request has been <strong>successfully approved</strong>!</p>
                
                <div class="organization-info">
                  <h3 style="margin-top: 0; color: #00695c;">Organization Details:</h3>
                  <p><strong>Organization Name:</strong> ${organizationName}</p>
                  <p><strong>Contact Person:</strong> ${contactName}</p>
                  <p><strong>Status:</strong> <span style="color: #2e7d32; font-weight: 600;">Verified ✓</span></p>
                </div>
                
                <p>Your organization is now officially verified and can access all premium features of our mosque community platform. You can now:</p>
                
                <ul style="color: #34495e; line-height: 1.8;">
                  <li>Create and manage events for the community</li>
                  <li>Access advanced organizational tools</li>
                  <li>Connect with other verified organizations</li>
                  <li>Utilize our comprehensive reporting features</li>
                </ul>
                
                <p>Thank you for being part of our growing mosque community. We look forward to supporting your organization's mission and activities.</p>
              </div>
              
              <div class="contact-info">
                <p><strong>Need assistance?</strong> Our support team is here to help you get started with your verified account.</p>
              </div>
            </div>
            
            <div class="footer">
              <p><strong>UmmaHub - Mosque Community Platform</strong></p>
              <p>Connecting communities, strengthening faith</p>
              <p style="margin-top: 15px;">This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </body>
        </html>
      `
    };
  } else if (type === 'declined') {
    return {
      subject: `📋 Organization Verification Update - ${organizationName}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Organization Verification Update</title>
          <style>
            body { 
              font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
              margin: 0; 
              padding: 0; 
              background-color: #f5f7fa; 
            }
            .container { 
              max-width: 600px; 
              margin: 0 auto; 
              background-color: #ffffff; 
              border-radius: 12px; 
              overflow: hidden; 
              box-shadow: 0 8px 32px rgba(0, 105, 92, 0.15); 
            }
            .header { 
              background: linear-gradient(135deg, #00695c 0%, #00897b 100%); 
              color: white; 
              padding: 30px; 
              text-align: center; 
            }
            .header h1 { 
              margin: 0; 
              font-size: 28px; 
              font-weight: 600; 
            }
            .header .subtitle { 
              margin: 8px 0 0 0; 
              font-size: 16px; 
              opacity: 0.9; 
            }
            .content { 
              padding: 40px 30px; 
            }
            .greeting { 
              font-size: 18px; 
              color: #2c3e50; 
              margin-bottom: 20px; 
            }
            .message { 
              font-size: 16px; 
              line-height: 1.6; 
              color: #34495e; 
              margin-bottom: 30px; 
            }
            .status-badge { 
              display: inline-block; 
              padding: 12px 24px; 
              border-radius: 25px; 
              font-weight: 600; 
              font-size: 16px; 
              margin: 20px 0; 
              background-color: #ffebee; 
              color: #c62828; 
              border: 2px solid #f44336; 
            }
            .organization-info { 
              background-color: #f8f9fa; 
              border-left: 4px solid #00695c; 
              padding: 20px; 
              margin: 20px 0; 
              border-radius: 0 8px 8px 0; 
            }
            .footer { 
              background-color: #f8f9fa; 
              padding: 30px; 
              text-align: center; 
              border-top: 1px solid #e9ecef; 
            }
            .footer p { 
              margin: 5px 0; 
              color: #6c757d; 
              font-size: 14px; 
            }
            .mosque-icon { 
              font-size: 32px; 
              margin-bottom: 10px; 
            }
            .contact-info { 
              margin-top: 20px; 
              padding-top: 20px; 
              border-top: 1px solid #e9ecef; 
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <div class="mosque-icon">🕌</div>
              <h1>UmmaHub</h1>
              <p class="subtitle">Mosque Community Platform</p>
            </div>
            
            <div class="content">
              <p class="greeting">Dear ${contactName},</p>
              
              <div class="status-badge">❌ VERIFICATION REQUIRES REVIEW</div>
              
              <div class="message">
                <p>Thank you for your interest in joining our verified organization network. After careful review, we need additional information to complete your verification process.</p>
                
                <div class="organization-info">
                  <h3 style="margin-top: 0; color: #00695c;">Application Details:</h3>
                  <p><strong>Organization Name:</strong> ${organizationName}</p>
                  <p><strong>Contact Person:</strong> ${contactName}</p>
                  <p><strong>Status:</strong> <span style="color: #c62828; font-weight: 600;">Requires Additional Review</span></p>
                </div>
                
                <p>This decision does not reflect the quality or legitimacy of your organization. Common reasons for additional review include:</p>
                
                <ul style="color: #34495e; line-height: 1.8;">
                  <li>Incomplete documentation or information</li>
                  <li>Need for additional verification documents</li>
                  <li>Clarification required on organizational activities</li>
                  <li>Technical issues with submitted materials</li>
                </ul>
                
                <p><strong>Next Steps:</strong></p>
                <p>Please review your application and ensure all required information is complete and accurate. You may resubmit your verification request at any time through our platform.</p>
                
                <p>We appreciate your understanding and look forward to welcoming your organization to our verified community once the review process is complete.</p>
              </div>
              
              <div class="contact-info">
                <p><strong>Questions or concerns?</strong> Please don't hesitate to contact our support team for guidance on the verification process.</p>
              </div>
            </div>
            
            <div class="footer">
              <p><strong>UmmaHub - Mosque Community Platform</strong></p>
              <p>Connecting communities, strengthening faith</p>
              <p style="margin-top: 15px;">This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </body>
        </html>
      `
    };
  }
};

// Alternative: Simple email sending using fetch to a backend API
const sendEmailViaAPI = async (type, recipientEmail, organizationData) => {
  try {
    const template = getEmailTemplate(type, organizationData);
    
    const API_BASE = process.env.REACT_APP_EMAIL_API_BASE || 'http://localhost:4000';
    console.log('Sending real email to:', recipientEmail);
    console.log('Email Subject:', template.subject);
    console.log('Using backend API:', `${API_BASE}/api/send-email`);

    const response = await fetch(`${API_BASE}/api/send-email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: recipientEmail,
        subject: template.subject,
        html: template.html
      })
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok || !data.success) {
      const errorMsg = data?.error || `Email API error (status ${response.status})`;
      console.error('Email API failed:', errorMsg);
      return { success: false, error: errorMsg };
    }

    console.log('Email sent successfully via SMTP backend!', data.messageId);
    return { 
      success: true, 
      messageId: data.messageId,
      message: `${type === 'accepted' ? 'Acceptance' : 'Decline'} notification email sent to ${recipientEmail}`
    };
    
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: error.message };
  }
};

// Send email function using direct SMTP (for demonstration)
const sendVerificationEmail = async (type, recipientEmail, organizationData) => {
  try {
    // For now, we'll use the API simulation approach
    // In production, you would either:
    // 1. Use EmailJS with proper configuration
    // 2. Send to your backend API that handles SMTP
    // 3. Use a service like SendGrid, Mailgun, etc.
    
    const result = await sendEmailViaAPI(type, recipientEmail, organizationData);
    
    if (result.success) {
      console.log('Email notification prepared successfully:', result.messageId);
      
      // Show the email content in console for demonstration
      const template = getEmailTemplate(type, organizationData);
      console.log('Email Subject:', template.subject);
      console.log('Email Recipient:', recipientEmail);
      console.log('Organization:', organizationData.organizationName);
      console.log('Contact Person:', organizationData?.userDetails?.name || organizationData?.contactPerson || 'User');
    }
    
    return result;
    
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: error.message };
  }
};

// Export functions
export const emailService = {
  sendVerificationEmail
};

export default emailService;