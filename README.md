# Microsoft Entra ID SSO with Spring Boot

A simple Spring Boot application demonstrating **Microsoft Entra ID (Azure AD)** integration using **OAuth2** for authentication with separate **Sign Up** and **Sign In** flows.

## ✨ Features

- ✅ Microsoft Entra ID OAuth2 Integration  
- ✅ Separate Sign Up and Sign In flows
- ✅ Secure authentication with Spring Security
- ✅ Simple, clean user interface with Bootstrap
- ✅ Automated setup scripts
- ✅ Environment variable management
- ✅ Comprehensive troubleshooting guide

## 📋 Prerequisites

1. **Java 17 or higher**
2. **Maven 3.6+**
3. **Microsoft Azure Account** (free account available)
4. **Microsoft Entra ID Tenant**

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

Run the interactive setup script that will guide you through the entire process:

```bash
./setup-env.sh
```

This script will:
- Check for existing configuration
- Guide you through Azure AD setup
- Help you configure environment variables
- Validate your configuration

### Option 2: Manual Setup

Follow the detailed guide in `azure-setup-guide.md` for step-by-step instructions.

## 🔧 Azure AD Setup

### 1. Create App Registration

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**
3. Set:
   - **Name**: `Spring Boot Entra ID SSO App`
   - **Supported account types**: `Accounts in this organizational directory only`
   - **Redirect URI**: `http://localhost:8080/login/oauth2/code/azure`

### 2. Get Configuration Values

From your App Registration, note down:
- **Application (client) ID**  
- **Directory (tenant) ID**

### 3. Create Client Secret

1. Go to **Certificates & secrets** > **New client secret**
2. Add description: `Spring Boot App Secret`
3. **Copy the secret VALUE immediately** (you won't see it again)

### 4. Set API Permissions

1. Go to **API permissions** > **Add a permission** > **Microsoft Graph**
2. Add these **Delegated permissions**:
   - `openid`
   - `profile` 
   - `email`
   - `User.Read`
3. **Grant admin consent** (if required)

## ⚙️ Configuration

### Automatic Configuration (Recommended)

The application automatically loads environment variables from a `.env` file:

```bash
# Run the setup script to create .env file
./setup-env.sh
```

### Manual Configuration

Set these environment variables:

```bash
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"  
export AZURE_TENANT_ID="your-tenant-id"
```

Or create a `.env` file in the project root:

```
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret
AZURE_TENANT_ID=your-tenant-id
```

## 🏃 Running the Application

### Using the Run Script (Recommended)

```bash
./run.sh
```

This script will:
- Check Java version and path
- Load environment variables from `.env` file
- Validate Azure AD configuration
- Start the Spring Boot application

### Manual Run

```bash
# Make sure environment variables are set
source .env

# Run the application
mvn spring-boot:run
```

### Access the Application

Open your browser and go to: **http://localhost:8080**

## 🔄 Application Flow

1. **Home Page** (`/`) - Welcome page with Sign Up/Sign In options
2. **Sign Up** (`/signup`) - For new users (redirects to Microsoft login)
3. **Sign In** (`/signin`) - For existing users (redirects to Microsoft login)
4. **Microsoft Login** - Authenticate with your Azure account
5. **Dashboard** (`/dashboard`) - Success page showing user information

## 📁 Project Structure

```
MicrosoftEntraID/
├── src/main/
│   ├── java/com/example/entraid/
│   │   ├── config/SecurityConfig.java        # Spring Security configuration
│   │   ├── controller/AuthController.java   # Web controllers
│   │   └── EntraIdSsoApplication.java       # Main application class
│   └── resources/
│       ├── templates/                        # Thymeleaf templates
│       │   ├── home.html                    # Landing page
│       │   ├── auth.html                    # Sign Up/Sign In page
│       │   └── dashboard.html               # Success dashboard
│       └── application.yml                   # Application configuration
├── .env                                      # Environment variables (auto-generated)
├── azure-setup-guide.md                     # Detailed setup guide
├── setup-env.sh                            # Interactive setup script
├── run.sh                                   # Application runner script
└── README.md                               # This file
```

## 🐛 Troubleshooting

### Quick Verification

Check if your environment variables are set correctly:

```bash
echo "Client ID: ${AZURE_CLIENT_ID:0:8}..."
echo "Tenant ID: ${AZURE_TENANT_ID:0:8}..."
echo "Client Secret: $([ -n "$AZURE_CLIENT_SECRET" ] && echo "Set" || echo "Not set")"
```

### Common Issues

1. **"AADSTS700016: Application not found"**
   - Verify your `AZURE_CLIENT_ID` is correct
   - Check the application exists in Azure AD

2. **"AADSTS50011: Invalid redirect URI"**
   - Ensure redirect URI in Azure AD is exactly: `http://localhost:8080/login/oauth2/code/azure`
   - No trailing slashes or extra characters

3. **"AADSTS7000215: Invalid client secret"**
   - Client secret might be expired or incorrect
   - Create a new client secret in Azure AD

4. **Environment variables not working**
   - Use the setup script: `./setup-env.sh`
   - Restart your terminal after setting variables
   - Check if `.env` file exists and has correct values

5. **Port 8080 already in use**
   - Stop existing instances: `pkill -f "spring-boot:run"`
   - Or configure a different port in `application.yml`

### Debug Mode

To see detailed Spring Security logs, add this to `application.yml`:

```yaml
logging:
  level:
    org.springframework.security: DEBUG
```

## 📚 Additional Resources

- **Detailed Setup Guide**: `azure-setup-guide.md`
- **Azure AD Documentation**: [Microsoft Identity Platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/)
- **Spring Security OAuth2**: [Spring Security Reference](https://docs.spring.io/spring-security/reference/servlet/oauth2/index.html)

## 🔒 Security Notes

- **Never commit `.env` file** to version control (already in `.gitignore`)
- **Rotate client secrets regularly** in production
- **Use Azure Key Vault** for production secret management
- **Set appropriate token expiration times**

## 🎯 Successful Test Results

✅ **Authentication Working**: The application successfully authenticates users with Microsoft Entra ID  
✅ **User Information Retrieved**: Dashboard displays user details (name, email, etc.)  
✅ **Session Management**: Proper login/logout functionality  
✅ **Security**: All endpoints properly secured with Spring Security  

---

**Ready to use Microsoft Entra ID SSO! 🚀**

Need help? Check `azure-setup-guide.md` for detailed instructions or run `./setup-env.sh` for interactive setup. 