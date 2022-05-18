# Security-Practices


What are the security challenges in iOS? And what are best security practices?


 1.Data Leaks - Storing sensitive data such as access token, secrets and API credentials in an unsecured way can lead to interception or stealing of the user data
 2.Unsecured communication - By making our application communicate with server using a non-secure connection, such as HTTP, will be risky can lead to potential and easy attacks
 3. Man in the middle attack - By using know techniques of faking Certifying Authority(CA) on the device, the attacker could imitate the target, and decrypt traffic. This could leak sensitive data

Some of the best security practices
1. Local Data Storage - We don’t use UserDefaults or Plist to store confidential information like password, authentication token, API keys etc. Because information present in an unencrypted format.
   Solution - use keychains - this is the best option to store the confidential information.

2. Enabling Debug Logs - print() to be strictly avoided. 
    - We should avoid logging sensitive information and use system features such as os_log with placeholders to hide private information in debug messages.

3. Web Views - use WKWebView

4. HTTP Requests with SSL Pinning -  Attackers can inject a 301 HTTP redirection response with an attacker-controlled server.  HTTPs should ne the standard for any communication between app and server. HTTPs encrypts all messages sent between client and server and protects against other attackers.
  - App Transport Security(ATS) - It forces mobile apps to connect to back-end servers using HTTPs, instead of HTTP to encrypt data in transit.
                                                   - NSAllowsArbitraryLoads key will be added in info.plist to enable or disable
  
- SSP Pinning - It can help to prevent the Man in middle attack. 
                       - We can use SSL Pinning to ensure that the app communicates only with he designated server itself (matching certificate or public key) and app will not allow any requests to be sent out to any untrusted server.
                       - When the communication starts, the client examines the servers SSL certificate and checks if the recieved certificate is trusted by the Trusted Root CA store or other user-trusted certificates.
                      - A potential drawback of this is you need to update the app as well if a server certificate expires or the servers SSL key is changed. Since you hardcode the trusted certificates, the app needs to be updated too.
 
5. Avoid Caching HTTPS Request/Responses
6. Disable Auto-Correction
7. Third-Party Library Usage Check
8. Clear the Pasteboad
9. Prevent system snapshots
10. Detect Screenshot
11. Detect Screen Recording
