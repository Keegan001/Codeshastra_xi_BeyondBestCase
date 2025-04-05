import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

/**
 * EmailService - Handles sending emails
 */
class EmailService {
  constructor() {
    // Create reusable transporter
    this.transporter = nodemailer.createTransport({
        service: "Gmail",
        host: "smtp.gmail.com",
        port: 587,
        secure: true,
        auth: {
          user: process.env.GMAIL_USERNAME,
          pass: process.env.GMAIL_PASSWORD,
        },
      });
  }

  /**
   * Send OTP email to the user
   * @param {String} to - Recipient email
   * @param {String} otp - One-time password
   * @returns {Promise} Nodemailer response
   */
  async sendOTPEmail(to, otp) {
    console.log(to, otp);
    const mailOptions = {
      from: process.env.GMAIL_USERNAME,
      to,
      subject: 'Your Login OTP Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
          <h2 style="color: #4a6fa5;">Travel Planner - Login Verification</h2>
          <p>Hello,</p>
          <p>Your one-time password (OTP) for login is:</p>
          <div style="background-color: #f5f5f5; padding: 12px; text-align: center; font-size: 24px; letter-spacing: 5px; font-weight: bold; margin: 20px 0; border-radius: 5px;">
            ${otp}
          </div>
          <p>This OTP will expire in 10 minutes.</p>
          <p>If you didn't request this OTP, please ignore this message.</p>
          <p>Regards,<br>Travel Planner Team</p>
        </div>
      `
    };

    return this.transporter.sendMail(mailOptions);
  }
}

export default new EmailService(); 