#!/bin/bash

################################################################################
# Jenkins Quick Setup Script for Inventory Management Tool
# This script helps with initial Jenkins configuration
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Jenkins CI/CD Setup for Inventory Tool${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
else
    PLATFORM="Linux"
fi

print_info "Detected platform: $PLATFORM"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_info "Checking prerequisites..."

# Check Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)
    if [ "$JAVA_VERSION" -ge 21 ]; then
        print_success "Java $JAVA_VERSION is installed"
    else
        print_warning "Java version is $JAVA_VERSION. Java 21 or higher is recommended."
    fi
else
    print_error "Java is not installed. Please install Java 21 or higher."
    exit 1
fi

# Check Maven
if command_exists mvn; then
    MVN_VERSION=$(mvn -version | head -n 1 | awk '{print $3}')
    print_success "Maven $MVN_VERSION is installed"
else
    print_error "Maven is not installed. Please install Maven 3.8.6 or higher."
    exit 1
fi

# Check Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    print_success "Docker $DOCKER_VERSION is installed"
else
    print_warning "Docker is not installed. Docker is required for containerization."
fi

# Check kubectl
if command_exists kubectl; then
    print_success "kubectl is installed"
else
    print_warning "kubectl is not installed. Required for Kubernetes deployment."
fi

# Check Python3
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    print_success "Python $PYTHON_VERSION is installed"
else
    print_warning "Python3 is not installed. Required for integration tests."
fi

echo ""
print_info "Building the project to verify setup..."

# Build the project
if mvn clean package -DskipTests; then
    print_success "Project build successful!"
else
    print_error "Project build failed. Please check the errors above."
    exit 1
fi

echo ""
print_info "Checking if Docker image can be built..."

# Build Docker image
if docker build -t inventory-management-tool:test . > /dev/null 2>&1; then
    print_success "Docker image built successfully!"
    docker rmi inventory-management-tool:test > /dev/null 2>&1
else
    print_warning "Docker image build failed. Please check Dockerfile."
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Prerequisites Check Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Jenkins Installation Options
echo -e "${BLUE}Jenkins Installation Options:${NC}\n"

echo "1. Install Jenkins using Docker:"
echo -e "${YELLOW}   docker run -d -p 8080:8080 -p 50000:50000 \\"
echo "     -v jenkins_home:/var/jenkins_home \\"
echo "     -v /var/run/docker.sock:/var/run/docker.sock \\"
echo -e "     --name jenkins jenkins/jenkins:lts${NC}\n"

if [[ "$PLATFORM" == "macOS" ]]; then
    echo "2. Install Jenkins using Homebrew:"
    echo -e "${YELLOW}   brew install jenkins-lts${NC}"
    echo -e "${YELLOW}   brew services start jenkins-lts${NC}\n"
else
    echo "2. Install Jenkins on Ubuntu/Debian:"
    echo -e "${YELLOW}   wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -${NC}"
    echo -e "${YELLOW}   sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'${NC}"
    echo -e "${YELLOW}   sudo apt update${NC}"
    echo -e "${YELLOW}   sudo apt install jenkins${NC}\n"
fi

echo "3. Access Jenkins:"
echo "   - URL: http://localhost:8080"
echo "   - Initial admin password: Check Jenkins logs or /var/jenkins_home/secrets/initialAdminPassword"
echo ""

# Required Jenkins Plugins
echo -e "${BLUE}Required Jenkins Plugins:${NC}"
echo "   - Pipeline"
echo "   - Git"
echo "   - Maven Integration"
echo "   - Docker Pipeline"
echo "   - Docker"
echo "   - Kubernetes"
echo "   - JUnit"
echo "   - Jacoco"
echo "   - Email Extension"
echo "   - Blue Ocean (optional)"
echo ""

# Jenkins Configuration Steps
echo -e "${BLUE}Jenkins Configuration Steps:${NC}\n"

echo "1. Configure Maven:"
echo "   - Go to: Manage Jenkins → Tools"
echo "   - Maven installations → Add Maven"
echo "   - Name: Maven-3.8.6"
echo "   - Install automatically: ✓"
echo "   - Version: 3.8.6"
echo ""

echo "2. Configure JDK:"
echo "   - Go to: Manage Jenkins → Tools"
echo "   - JDK installations → Add JDK"
echo "   - Name: JDK-21"
echo "   - Install automatically: ✓"
echo "   - Version: java.net → Java 21"
echo ""

echo "3. Add Docker Hub Credentials:"
echo "   - Go to: Manage Jenkins → Credentials → System → Global credentials"
echo "   - Kind: Username with password"
echo "   - ID: docker-hub-credentials"
echo "   - Username: <your-dockerhub-username>"
echo "   - Password: <your-dockerhub-password>"
echo ""

echo "4. Add MySQL Credentials:"
echo "   - Go to: Manage Jenkins → Credentials → System → Global credentials"
echo "   - Kind: Username with password"
echo "   - ID: mysql-credentials"
echo "   - Username: root"
echo "   - Password: <your-mysql-password>"
echo ""

echo "5. Create Pipeline Job:"
echo "   - New Item → Multibranch Pipeline"
echo "   - Name: Inventory-Management-Tool"
echo "   - Branch Sources → Add source → Git"
echo "   - Project Repository: <your-git-repo-url>"
echo "   - Build Configuration → Mode: by Jenkinsfile"
echo "   - Script Path: Jenkinsfile"
echo "   - Save"
echo ""

echo -e "${BLUE}Environment Variables to Configure in Jenkinsfile:${NC}"
echo "   - DOCKER_IMAGE: your-dockerhub-username/inventory-management-tool"
echo "   - DOCKER_REGISTRY: docker.io"
echo "   - SONAR_HOST_URL: http://your-sonarqube-server:9000 (if using SonarQube)"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo "1. Install Jenkins using one of the methods above"
echo "2. Access Jenkins at http://localhost:8080"
echo "3. Install required plugins"
echo "4. Configure tools (Maven, JDK)"
echo "5. Add credentials (Docker Hub, MySQL, Git)"
echo "6. Create the pipeline job"
echo "7. Push code to trigger the pipeline"
echo ""

echo -e "${BLUE}For detailed documentation, see:${NC}"
echo "   📖 JENKINS_SETUP.md"
echo ""

echo -e "${GREEN}Setup verification complete! ✓${NC}"
echo ""

# Optional: Ask if user wants to start Docker Compose
read -p "Would you like to start the application with Docker Compose? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Starting application with Docker Compose..."
    if docker-compose up -d; then
        print_success "Application started successfully!"
        echo ""
        echo "Application is running at: http://localhost:8082"
        echo "MySQL is running on port: 3306"
        echo ""
        echo "To stop: docker-compose down"
        echo "To view logs: docker-compose logs -f"
    else
        print_error "Failed to start application. Check docker-compose.yaml configuration."
    fi
fi

echo ""
print_success "All done! Happy coding! 🚀"
