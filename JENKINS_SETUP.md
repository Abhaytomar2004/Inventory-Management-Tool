# Jenkins CI/CD Pipeline Documentation

## 📋 Overview

This document provides detailed information about the Jenkins CI/CD pipeline for the Inventory Management Tool.

## 🎯 Pipeline Features

The Jenkins pipeline includes the following stages:

1. **Checkout** - Fetches the source code from the repository
2. **Build** - Compiles the application using Maven
3. **Unit Tests** - Runs JUnit tests and generates coverage reports
4. **Code Quality Analysis** - Performs static code analysis (Checkstyle, PMD, SpotBugs)
5. **SonarQube Analysis** - Analyzes code quality and security vulnerabilities
6. **Quality Gate** - Ensures code meets quality standards
7. **Package** - Creates the JAR artifact
8. **Build Docker Image** - Builds Docker container image
9. **Security Scan** - Scans Docker image for vulnerabilities
10. **Push Docker Image** - Pushes image to Docker registry (main/develop branches only)
11. **Deploy to Development** - Deploys to dev environment (develop branch)
12. **Deploy to Staging** - Deploys to staging environment (main branch)
13. **Integration Tests** - Runs end-to-end tests
14. **Deploy to Production** - Deploys to production with manual approval (main branch)

## 🛠️ Prerequisites

### Jenkins Server Requirements

1. **Jenkins Version**: 2.400 or higher
2. **Required Plugins**:
   - Pipeline
   - Git
   - Maven Integration
   - Docker Pipeline
   - Kubernetes
   - JUnit
   - Jacoco
   - SonarQube Scanner
   - Email Extension
   - Blue Ocean (optional, for better UI)

### Required Tools on Jenkins Server

```bash
# Java 21
java -version

# Maven 3.8.6+
mvn -version

# Docker
docker --version

# Kubernetes kubectl (if using K8s deployment)
kubectl version --client

# Python 3 (for integration tests)
python3 --version

# Trivy (for security scanning)
trivy --version
```

## ⚙️ Jenkins Configuration

### 1. Install Required Plugins

Navigate to **Manage Jenkins** → **Plugin Manager** → **Available Plugins** and install:

```
- Pipeline
- Pipeline: Stage View
- Git plugin
- Maven Integration plugin
- Docker Pipeline
- Docker plugin
- Kubernetes plugin
- JUnit Plugin
- JaCoCo plugin
- SonarQube Scanner
- Email Extension Plugin
- Blue Ocean (optional)
```

### 2. Configure Global Tools

Go to **Manage Jenkins** → **Tools**:

#### Maven Configuration
- Name: `Maven-3.8.6`
- Install automatically: Check
- Version: 3.8.6

#### JDK Configuration
- Name: `JDK-21`
- Install automatically: Check
- Version: Java 21

### 3. Set Up Credentials

Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**:

#### Docker Hub Credentials
- **ID**: `docker-hub-credentials`
- **Type**: Username with password
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub password/token

#### MySQL Database Credentials (for testing)
- **ID**: `mysql-credentials`
- **Type**: Username with password
- **Username**: `root`
- **Password**: Your MySQL password

#### GitHub/Git Credentials (if private repo)
- **ID**: `github-credentials`
- **Type**: Username with password or SSH key
- **Username**: Your GitHub username
- **Password**: Personal Access Token

### 4. Configure SonarQube (Optional)

Go to **Manage Jenkins** → **System** → **SonarQube servers**:

- **Name**: `SonarQube`
- **Server URL**: `http://your-sonarqube-server:9000`
- **Server authentication token**: Add SonarQube token via credentials

### 5. Configure Email Notifications (Optional)

Go to **Manage Jenkins** → **System** → **Extended E-mail Notification**:

- **SMTP server**: smtp.gmail.com (or your SMTP server)
- **SMTP Port**: 587
- **Credentials**: Add email credentials
- **Use SSL**: Check
- **Default Content Type**: HTML

## 🚀 Creating the Jenkins Pipeline Job

### Method 1: Multibranch Pipeline (Recommended)

1. Click **New Item**
2. Enter name: `Inventory-Management-Tool`
3. Select **Multibranch Pipeline**
4. Configure:
   - **Branch Sources** → **Git**
   - **Project Repository**: `https://github.com/YOUR_USERNAME/Inventory-Management-Tool.git`
   - **Credentials**: Select your Git credentials
   - **Behaviors**: Add "Discover branches" and "Discover tags"
   - **Build Configuration**: 
     - Mode: by Jenkinsfile
     - Script Path: `Jenkinsfile`
5. Click **Save**

### Method 2: Pipeline Job

1. Click **New Item**
2. Enter name: `Inventory-Management-Tool-Pipeline`
3. Select **Pipeline**
4. Configure:
   - **Pipeline** section:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/YOUR_USERNAME/Inventory-Management-Tool.git`
     - Credentials: Select your Git credentials
     - Branch: `*/main` or `*/develop`
     - Script Path: `Jenkinsfile`
5. Click **Save**

## 🔧 Environment Variables Configuration

You can customize the pipeline by modifying these environment variables in the Jenkinsfile:

```groovy
environment {
    DOCKER_IMAGE = 'your-dockerhub-username/inventory-management-tool'
    DOCKER_REGISTRY = 'docker.io'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
    
    DB_HOST = 'localhost'
    DB_PORT = '3306'
    DB_NAME = 'inventory_db_test'
    
    K8S_NAMESPACE = 'default'
    K8S_DEPLOYMENT = 'inventory-management-tool'
    
    SONAR_HOST_URL = 'http://your-sonarqube:9000'
    SONAR_PROJECT_KEY = 'inventory-management-tool'
}
```

## 📊 Pipeline Stages Explained

### Stage 1: Checkout
```groovy
- Checks out source code from Git
- Captures Git commit ID for tagging
```

### Stage 2: Build
```groovy
- Compiles the Java source code
- Downloads dependencies
- Command: mvn clean compile -DskipTests
```

### Stage 3: Unit Tests
```groovy
- Runs JUnit tests
- Generates test reports
- Generates code coverage with JaCoCo
- Command: mvn test
```

### Stage 4: Code Quality Analysis
```groovy
- Runs Checkstyle for code style violations
- Runs PMD for potential bugs
- Runs SpotBugs for bug detection
- Command: mvn checkstyle:checkstyle pmd:pmd spotbugs:spotbugs
```

### Stage 5: SonarQube Analysis
```groovy
- Performs comprehensive code quality analysis
- Checks for code smells, bugs, vulnerabilities
- Only runs on main/develop branches
```

### Stage 6: Quality Gate
```groovy
- Waits for SonarQube quality gate result
- Fails pipeline if quality gate fails
- Timeout: 5 minutes
```

### Stage 7: Package
```groovy
- Creates JAR file
- Archives artifact
- Command: mvn package -DskipTests
```

### Stage 8: Build Docker Image
```groovy
- Builds Docker image using Dockerfile
- Tags image with build number and 'latest'
- Command: docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
```

### Stage 9: Security Scan
```groovy
- Scans Docker image for vulnerabilities
- Uses Trivy or Docker Scout
- Can be configured to fail on HIGH/CRITICAL vulnerabilities
```

### Stage 10: Push Docker Image
```groovy
- Pushes image to Docker registry
- Only runs on main/develop branches
- Requires Docker credentials
```

### Stage 11: Deploy to Development
```groovy
- Deploys using docker-compose
- Only runs on develop branch
- Automatic deployment
```

### Stage 12: Deploy to Staging
```groovy
- Deploys to Kubernetes staging namespace
- Only runs on main branch
- Uses kubectl to update deployment
```

### Stage 13: Integration Tests
```groovy
- Runs integration/E2E tests
- Executes test.py script
- Verifies API endpoints
```

### Stage 14: Deploy to Production
```groovy
- Deploys to Kubernetes production namespace
- Only runs on main branch
- Requires manual approval
```

## 🎨 Customizing the Pipeline

### Disabling Stages

To disable a stage, comment it out or add a `when` condition:

```groovy
stage('SonarQube Analysis') {
    when {
        expression { return false } // Disable this stage
    }
    steps {
        // ...
    }
}
```

### Adding Custom Stages

Add your custom stage in the `stages` block:

```groovy
stage('Custom Stage') {
    steps {
        script {
            echo 'Running custom stage...'
        }
        sh '''
            # Your custom commands here
        '''
    }
}
```

### Branch-Specific Execution

Use `when` directive for branch-specific stages:

```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        // Production deployment steps
    }
}
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Docker Not Found in Jenkins Container

**Error**: `docker: not found` or `docker: command not found` with exit code 127

**Cause**: Docker CLI is not installed inside the Jenkins container, even though the Docker socket is mounted.

**Solution**:
```bash
# Connect to Jenkins container as root
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"

# Verify installation
docker exec jenkins docker --version

# Test Docker connectivity
docker exec jenkins docker ps
```

**Expected Output**:
```
Docker version 20.10.24+dfsg1, build 297e128
```

**Note**: This installs the Docker CLI from Debian repositories. The container uses the host's Docker daemon via the mounted `/var/run/docker.sock`.

#### 2. Code Quality Analysis Fails - Maven Plugins Not Configured

**Error**: `script returned exit code 1` during Code Quality Analysis stage

**Cause**: Maven plugins (checkstyle, pmd, spotbugs) are not configured in `pom.xml`

**Solution Option 1** - Skip code quality stages (Quick fix):
The Jenkinsfile has been updated to skip these stages gracefully with informative messages.

**Solution Option 2** - Add plugins to pom.xml (Complete fix):
```xml
<build>
    <plugins>
        <!-- Checkstyle Plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-checkstyle-plugin</artifactId>
            <version>3.3.0</version>
        </plugin>
        
        <!-- PMD Plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-pmd-plugin</artifactId>
            <version>3.21.0</version>
        </plugin>
        
        <!-- SpotBugs Plugin -->
        <plugin>
            <groupId>com.github.spotbugs</groupId>
            <artifactId>spotbugs-maven-plugin</artifactId>
            <version>4.7.3.5</version>
        </plugin>
    </plugins>
</build>
```

#### 3. Jenkins DSL Method Not Found

**Error**: `java.lang.NoSuchMethodError: No such DSL method 'checkStyle' found` or `recordIssues` not found

**Cause**: Jenkins Warnings Next Generation Plugin is not installed

**Solution Option 1** - Remove recordIssues calls (Implemented):
The Jenkinsfile has been simplified to not use these DSL methods.

**Solution Option 2** - Install the plugin:
1. Go to **Manage Jenkins** → **Plugins**
2. Search for "Warnings Next Generation Plugin"
3. Install and restart Jenkins

#### 4. Maven Build Fails
```bash
# Check Java version
java -version

# Check Maven version
mvn -version

# Clean Maven cache
mvn dependency:purge-local-repository
```

#### 5. Docker Build Fails
```bash
# Check Docker daemon
docker info

# Clean Docker cache
docker system prune -a

# Check Dockerfile syntax
docker build --no-cache -t test .
```

#### 6. Docker Push Fails
```bash
# Verify Docker credentials
docker login

# Check credential ID in Jenkins matches Jenkinsfile
```

#### 7. Kubernetes Deployment Fails
```bash
# Check kubectl configuration
kubectl cluster-info

# Verify namespace exists
kubectl get namespaces

# Check deployment exists
kubectl get deployment -n ${K8S_NAMESPACE}
```

#### 8. Tests Fail
```bash
# Run tests locally
mvn test

# Check test reports in target/surefire-reports/
```

#### 9. SonarQube Connection Issues

**Error**: SonarQube stages fail or timeout

**Solution**:
- Verify SonarQube server is running: `curl http://localhost:9000`
- Check SonarQube token is valid in Jenkins credentials
- Ensure SonarQube scanner plugin is installed in Jenkins
- If not using SonarQube, the stages will be skipped automatically

#### 10. Permission Denied Errors

**Error**: Permission denied when accessing files or Docker socket

**Solution**:
```bash
# For Docker socket permission issues
docker exec -u root jenkins chmod 666 /var/run/docker.sock

# For workspace permission issues
docker exec -u root jenkins chown -R jenkins:jenkins /var/jenkins_home/workspace
```

## 📧 Notifications

### Email Notifications

Uncomment the email notification sections in the Jenkinsfile `post` block:

```groovy
post {
    success {
        emailext(
            subject: "✅ Jenkins Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "Build completed successfully.\n\nBuild URL: ${env.BUILD_URL}",
            to: 'team@example.com'
        )
    }
}
```

### Slack Notifications (Optional)

Install Slack Notification plugin and add:

```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        )
    }
}
```

## 🔐 Security Best Practices

1. **Never commit credentials** - Use Jenkins Credentials Manager
2. **Use Jenkins Pipeline Shared Libraries** - For reusable pipeline code
3. **Enable RBAC** - Role-Based Access Control for Jenkins
4. **Regular Updates** - Keep Jenkins and plugins updated
5. **Scan Docker Images** - Always scan for vulnerabilities
6. **Use Secrets Management** - Kubernetes Secrets or HashiCorp Vault
7. **Enable Audit Logging** - Track all pipeline executions

## 📈 Monitoring and Metrics

### Jenkins Metrics
- Build success/failure rate
- Build duration trends
- Test coverage trends
- Code quality trends (via SonarQube)

### Application Metrics
- Deploy frequency
- Mean time to recovery (MTTR)
- Change failure rate
- Lead time for changes

## 🔄 CI/CD Workflow

```
Developer → Push Code → GitHub
                          ↓
                    Webhook triggers Jenkins
                          ↓
                    Pipeline Execution:
                    1. Build & Test
                    2. Code Quality Check
                    3. Build Docker Image
                    4. Security Scan
                    5. Push to Registry
                    6. Deploy to Environment
                          ↓
                    Notifications sent
```

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Maven Documentation](https://maven.apache.org/guides/)

## 🆘 Support

For issues or questions:
1. Check Jenkins console output
2. Review build logs
3. Consult troubleshooting section
4. Contact DevOps team

---

**Last Updated**: October 2025
**Maintained by**: DevOps Team
