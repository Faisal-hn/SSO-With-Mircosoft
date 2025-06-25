#!/bin/bash

# Set JAVA_HOME to the specific JDK path
export JAVA_HOME=/home/tracxn-lp-703/.java/jdk-17
export PATH=$JAVA_HOME/bin:$PATH

echo "============================================"
echo "Microsoft Entra ID SSO - Spring Boot App"
echo "============================================"
echo "Using Java: $JAVA_HOME"
echo "Java Version:"
java -version
echo "============================================"

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env file..."
    # Export each line from .env file
    export $(grep -v '^#' .env | xargs)
    echo "✅ Environment variables loaded successfully"
    echo ""
else
    echo "⚠️  No .env file found"
fi

# Check if environment variables are set
if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ] || [ -z "$AZURE_TENANT_ID" ]; then
    echo "❌ ERROR: Azure AD environment variables not set!"
    echo ""
    echo "Please run the setup script first:"
    echo "./setup-env.sh"
    echo ""
    echo "Or manually set the following environment variables:"
    echo "export AZURE_CLIENT_ID='your-client-id'"
    echo "export AZURE_CLIENT_SECRET='your-client-secret'"
    echo "export AZURE_TENANT_ID='your-tenant-id'"
    echo ""
    echo "Exiting..."
    exit 1
else
    echo "✅ Azure AD Configuration:"
    echo "   Client ID: ${AZURE_CLIENT_ID:0:8}..."
    echo "   Tenant ID: ${AZURE_TENANT_ID:0:8}..."
    echo "   Client Secret: ✅ Set"
fi

echo "============================================"
echo "🚀 Starting Spring Boot application..."
echo "   Access the app at: http://localhost:8080"
echo "   Press Ctrl+C to stop the application"
echo "============================================"

# Run the Spring Boot application with environment variables explicitly set
AZURE_CLIENT_ID="$AZURE_CLIENT_ID" \
AZURE_CLIENT_SECRET="$AZURE_CLIENT_SECRET" \
AZURE_TENANT_ID="$AZURE_TENANT_ID" \
mvn spring-boot:run 