#!/bin/bash

# Microsoft Entra ID SSO Configuration Script
echo "=========================================="
echo "Microsoft Entra ID SSO Configuration"
echo "=========================================="
echo ""

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "Java is not installed or not in PATH. Please install Java 17 or later."
    exit 1
fi

# Set JAVA_HOME to user's specific JDK path
export JAVA_HOME="/home/tracxn-lp-703/.java/jdk-17"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Using Java from: $JAVA_HOME"
java -version
echo ""

# Function to check if Azure CLI is installed
check_azure_cli() {
    if command -v az &> /dev/null; then
        echo "✓ Azure CLI is installed"
        return 0
    else
        echo "✗ Azure CLI is not installed"
        return 1
    fi
}

# Function to install Azure CLI
install_azure_cli() {
    echo "Would you like to install Azure CLI to help with setup? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        if [ $? -eq 0 ]; then
            echo "✓ Azure CLI installed successfully"
        else
            echo "✗ Failed to install Azure CLI. You can still configure manually."
        fi
    fi
}

# Function to prompt for manual configuration
configure_manually() {
    echo ""
    echo "Manual Configuration"
    echo "===================="
    echo ""
    echo "You'll need to create an Azure AD Application Registration first."
    echo "Please follow the detailed guide in 'azure-setup-guide.md'"
    echo ""
    echo "After creating the Azure AD app registration, you'll have these values:"
    echo "1. Application (client) ID"
    echo "2. Directory (tenant) ID" 
    echo "3. Client Secret"
    echo ""
    
    # Check if user wants to configure now
    echo "Do you have these values ready to configure now? (y/n)"
    read -r ready
    
    if [[ "$ready" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Please enter your Azure AD configuration:"
        echo ""
        
        # Get Client ID
        echo -n "Enter your Application (client) ID: "
        read -r client_id
        while [[ -z "$client_id" ]]; do
            echo -n "Client ID cannot be empty. Please enter your Application (client) ID: "
            read -r client_id
        done
        
        # Get Tenant ID
        echo -n "Enter your Directory (tenant) ID: "
        read -r tenant_id
        while [[ -z "$tenant_id" ]]; do
            echo -n "Tenant ID cannot be empty. Please enter your Directory (tenant) ID: "
            read -r tenant_id
        done
        
        # Get Client Secret
        echo -n "Enter your Client Secret: "
        read -rs client_secret
        echo ""
        while [[ -z "$client_secret" ]]; do
            echo -n "Client Secret cannot be empty. Please enter your Client Secret: "
            read -rs client_secret
            echo ""
        done
        
        # Validate the format (basic check)
        if [[ ! "$client_id" =~ ^[0-9a-f-]{36}$ ]]; then
            echo "⚠️  Warning: Client ID doesn't look like a typical GUID format"
        fi
        
        if [[ ! "$tenant_id" =~ ^[0-9a-f-]{36}$ ]]; then
            echo "⚠️  Warning: Tenant ID doesn't look like a typical GUID format"
        fi
        
        # Export environment variables
        export AZURE_CLIENT_ID="$client_id"
        export AZURE_CLIENT_SECRET="$client_secret"
        export AZURE_TENANT_ID="$tenant_id"
        
        # Save to .env file for persistence
        echo "AZURE_CLIENT_ID=$client_id" > .env
        echo "AZURE_CLIENT_SECRET=$client_secret" >> .env
        echo "AZURE_TENANT_ID=$tenant_id" >> .env
        
        echo ""
        echo "✓ Configuration saved to .env file"
        echo "✓ Environment variables set for current session"
        echo ""
        
        # Verify configuration
        echo "Configuration Summary:"
        echo "====================="
        echo "Client ID: $AZURE_CLIENT_ID"
        echo "Tenant ID: $AZURE_TENANT_ID"
        echo "Client Secret: $(echo $AZURE_CLIENT_SECRET | sed 's/./*/g')"
        echo ""
        
        return 0
    else
        echo ""
        echo "No problem! Please follow these steps:"
        echo ""
        echo "1. Open the 'azure-setup-guide.md' file for detailed instructions"
        echo "2. Create your Azure AD Application Registration"
        echo "3. Run this script again when you have the credentials"
        echo ""
        echo "Quick setup URL: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade"
        echo ""
        return 1
    fi
}

# Function to test configuration
test_configuration() {
    echo "Testing Configuration..."
    echo "======================="
    
    if [[ -z "$AZURE_CLIENT_ID" || -z "$AZURE_CLIENT_SECRET" || -z "$AZURE_TENANT_ID" ]]; then
        echo "✗ Missing environment variables"
        return 1
    fi
    
    if [[ "$AZURE_CLIENT_ID" == "your-client-id" || "$AZURE_TENANT_ID" == "your-tenant-id" ]]; then
        echo "✗ Still using placeholder values"
        return 1
    fi
    
    echo "✓ All environment variables are set"
    echo "✓ No placeholder values detected"
    
    # Test Azure endpoint accessibility
    echo "Testing Azure endpoint connectivity..."
    if curl -s --connect-timeout 5 "https://login.microsoftonline.com/$AZURE_TENANT_ID/v2.0/.well-known/openid_configuration" > /dev/null; then
        echo "✓ Azure endpoint is accessible"
        return 0
    else
        echo "⚠️  Could not reach Azure endpoint. Check your internet connection and tenant ID."
        return 1
    fi
}

# Function to show startup instructions
show_startup_instructions() {
    echo ""
    echo "Next Steps:"
    echo "==========="
    echo ""
    echo "1. Start the application:"
    echo "   ./run.sh"
    echo ""
    echo "2. Open your browser and go to:"
    echo "   http://localhost:8080"
    echo ""
    echo "3. Click 'Sign Up' or 'Sign In' to test the authentication"
    echo ""
    echo "4. You should be redirected to Microsoft's login page"
    echo ""
    echo "If you encounter issues, check the troubleshooting section in azure-setup-guide.md"
    echo ""
}

# Main execution
echo "Let's configure your Microsoft Entra ID SSO application!"
echo ""

# Check for existing configuration
if [[ -f ".env" ]]; then
    echo "Found existing .env file. Loading configuration..."
    source .env
    
    if [[ -n "$AZURE_CLIENT_ID" && -n "$AZURE_CLIENT_SECRET" && -n "$AZURE_TENANT_ID" ]]; then
        echo "✓ Existing configuration loaded"
        
        if test_configuration; then
            echo "✓ Configuration appears to be valid"
            show_startup_instructions
            exit 0
        else
            echo "⚠️  Configuration may have issues. Would you like to reconfigure? (y/n)"
            read -r reconfig
            if [[ ! "$reconfig" =~ ^[Yy]$ ]]; then
                show_startup_instructions
                exit 0
            fi
        fi
    fi
fi

# Check current environment variables
if [[ -n "$AZURE_CLIENT_ID" && -n "$AZURE_CLIENT_SECRET" && -n "$AZURE_TENANT_ID" ]]; then
    echo "Found existing environment variables:"
    echo "Client ID: $AZURE_CLIENT_ID"
    echo "Tenant ID: $AZURE_TENANT_ID"
    echo ""
    
    if test_configuration; then
        echo "✓ Configuration appears to be valid"
        show_startup_instructions
        exit 0
    fi
fi

echo "Configuration needed. Let's set up your Azure AD credentials."
echo ""

# Check if Azure CLI is available
if ! check_azure_cli; then
    echo ""
    echo "Azure CLI can help automate some setup steps."
    install_azure_cli
fi

echo ""
echo "Choose setup method:"
echo "1. Manual configuration (enter credentials manually)"
echo "2. View setup guide only"
echo "3. Exit"
echo ""
echo -n "Enter your choice (1-3): "
read -r choice

case $choice in
    1)
        if configure_manually; then
            if test_configuration; then
                echo "✓ Configuration completed successfully!"
                show_startup_instructions
            else
                echo "⚠️  Configuration completed but there may be issues."
                echo "Please check the troubleshooting section in azure-setup-guide.md"
                show_startup_instructions
            fi
        fi
        ;;
    2)
        echo ""
        echo "Please open and follow the guide in: azure-setup-guide.md"
        echo ""
        echo "Key points:"
        echo "- You need an Azure account (free account available)"
        echo "- Create an App Registration in Azure AD"
        echo "- Set redirect URI to: http://localhost:8080/login/oauth2/code/azure"
        echo "- Collect Client ID, Tenant ID, and Client Secret"
        echo ""
        echo "Run this script again after completing the setup."
        ;;
    3)
        echo "Setup cancelled. Run this script again when ready to configure."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please run the script again."
        exit 1
        ;;
esac 