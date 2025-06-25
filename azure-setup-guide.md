# Microsoft Entra ID (Azure AD) Setup Guide

This guide will help you set up Microsoft Entra ID authentication for your Spring Boot application.

## Prerequisites
- An Azure account (you can create a free account at https://azure.microsoft.com/free/)
- Access to Azure Portal (https://portal.azure.com)

## Step 1: Create an Azure AD Application Registration

1. **Go to Azure Portal**
   - Visit https://portal.azure.com
   - Sign in with your Azure account

2. **Navigate to Azure Active Directory**
   - In the left sidebar, click on "Azure Active Directory" (or search for it)
   - If you don't see it, click "All services" and search for "Azure Active Directory"

3. **Create App Registration**
   - In the Azure AD overview, click on "App registrations" in the left menu
   - Click "New registration" button
   - Fill in the details:
     - **Name**: `Spring Boot Entra ID SSO App` (or any name you prefer)
     - **Supported account types**: Choose "Accounts in this organizational directory only" (single tenant)
     - **Redirect URI**: 
       - Platform: Web
       - URI: `http://localhost:8080/login/oauth2/code/azure`
   - Click "Register"

## Step 2: Collect Required Information

After registration, you'll be taken to the app overview page. Collect these values:

1. **Application (client) ID**
   - This is displayed on the overview page
   - Copy this value - you'll need it as `AZURE_CLIENT_ID`

2. **Directory (tenant) ID**
   - Also displayed on the overview page
   - Copy this value - you'll need it as `AZURE_TENANT_ID`

3. **Client Secret**
   - In the left menu, click "Certificates & secrets"
   - Click "New client secret"
   - Add a description: `Spring Boot App Secret`
   - Choose expiration: 24 months (or as per your organization's policy)
   - Click "Add"
   - **IMPORTANT**: Copy the secret VALUE immediately (not the ID) - you won't be able to see it again
   - This is your `AZURE_CLIENT_SECRET`

## Step 3: Configure API Permissions

1. **Add Permissions**
   - In the left menu, click "API permissions"
   - You should see "Microsoft Graph" with "User.Read" permission already added
   - If not, click "Add a permission"
   - Choose "Microsoft Graph" → "Delegated permissions"
   - Search for and add:
     - `openid`
     - `profile`
     - `email`
     - `User.Read`
   - Click "Add permissions"

2. **Grant Admin Consent** (if required)
   - If you see a yellow warning about admin consent
   - Click "Grant admin consent for [your directory]"
   - Click "Yes" to confirm

## Step 4: Configure Your Application

You have collected three important values:
- `AZURE_CLIENT_ID`: Your Application (client) ID
- `AZURE_CLIENT_SECRET`: Your Client Secret
- `AZURE_TENANT_ID`: Your Directory (tenant) ID

## Step 5: Set Environment Variables

Choose one of the following methods:

### Method A: Using the setup script (Recommended)

Run the interactive setup script:
```bash
./setup-env.sh
```

### Method B: Set environment variables manually

**On Linux/Mac:**
```bash
export AZURE_CLIENT_ID="your-actual-client-id"
export AZURE_CLIENT_SECRET="your-actual-client-secret"
export AZURE_TENANT_ID="your-actual-tenant-id"
```

**On Windows (Command Prompt):**
```cmd
set AZURE_CLIENT_ID=your-actual-client-id
set AZURE_CLIENT_SECRET=your-actual-client-secret
set AZURE_TENANT_ID=your-actual-tenant-id
```

**On Windows (PowerShell):**
```powershell
$env:AZURE_CLIENT_ID="your-actual-client-id"
$env:AZURE_CLIENT_SECRET="your-actual-client-secret"
$env:AZURE_TENANT_ID="your-actual-tenant-id"
```

### Method C: Create a .env file

Create a `.env` file in your project root (this file will be ignored by git):
```
AZURE_CLIENT_ID=your-actual-client-id
AZURE_CLIENT_SECRET=your-actual-client-secret
AZURE_TENANT_ID=your-actual-tenant-id
```

## Step 6: Test Your Setup

1. **Start the application:**
   ```bash
   ./run.sh
   ```

2. **Test the authentication:**
   - Open your browser and go to http://localhost:8080
   - Click "Sign Up" or "Sign In"
   - You should be redirected to Microsoft's login page
   - Sign in with your Azure account
   - You should be redirected back to your application

## Troubleshooting

### Common Issues:

1. **"AADSTS700016: Application not found"**
   - Check that your `AZURE_CLIENT_ID` is correct
   - Verify the application exists in Azure AD

2. **"AADSTS50011: Invalid redirect URI"**
   - Make sure the redirect URI in Azure AD matches exactly: `http://localhost:8080/login/oauth2/code/azure`
   - Check for trailing slashes or typos

3. **"AADSTS7000215: Invalid client secret"**
   - Your client secret might be expired or incorrect
   - Create a new client secret in Azure AD

4. **Environment variables not working**
   - Make sure you've exported the variables in the same terminal session
   - Try restarting your terminal after setting the variables
   - Use the setup script to ensure proper configuration

### Verification Commands:

Check if environment variables are set:
```bash
echo $AZURE_CLIENT_ID
echo $AZURE_TENANT_ID
echo "Client secret is set: $([ -n "$AZURE_CLIENT_SECRET" ] && echo "Yes" || echo "No")"
```

## Security Notes

- **Never commit secrets to version control**
- The client secret should be treated as a password
- Consider using Azure Key Vault for production applications
- Regularly rotate your client secrets
- Use appropriate expiration times for secrets

## Next Steps

Once authentication is working:
- You can customize the user experience
- Add additional scopes if needed
- Implement proper error handling
- Add logging for debugging
- Consider production deployment configurations

For production deployment, you'll need to:
- Update the redirect URI to your production domain
- Use proper environment variable management
- Configure proper logging
- Set up monitoring and alerts 