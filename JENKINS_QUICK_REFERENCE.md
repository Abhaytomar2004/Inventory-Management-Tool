# Jenkins Pipeline Quick Reference

## 🚀 Quick Start

### 1. Run Setup Script
```bash
./jenkins-setup.sh
```

### 2. Install Jenkins (Choose one method)

#### Option A: Docker (Recommended)
```bash
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts
```

#### Option B: macOS (Homebrew)
```bash
brew install jenkins-lts
brew services start jenkins-lts
```

#### Option C: Ubuntu/Debian
```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins
```

### 3. Access Jenkins
- URL: http://localhost:8080
- Get initial password: 
  ```bash
  # Docker
  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
  
  # macOS/Linux
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```

### 4. Install Required Plugins
1. Go to **Manage Jenkins** → **Plugin Manager**
2. Install these plugins:
   - Pipeline
   - Git
   - Maven Integration
   - Docker Pipeline
   - Kubernetes
   - JUnit
   - Jacoco
   - Email Extension

### 5. Configure Tools
**Manage Jenkins** → **Tools**

#### Maven
- Name: `Maven-3.8.6`
- ✓ Install automatically
- Version: 3.8.6

#### JDK
- Name: `JDK-21`
- ✓ Install automatically
- Version: Java 21

### 6. Add Credentials
**Manage Jenkins** → **Credentials** → **System** → **Global credentials**

#### Docker Hub
- ID: `docker-hub-credentials`
- Type: Username with password
- Username: `your-dockerhub-username`
- Password: `your-dockerhub-token`

#### MySQL (for tests)
- ID: `mysql-credentials`
- Type: Username with password
- Username: `root`
- Password: `your-mysql-password`

### 7. Create Pipeline Job

#### Multibranch Pipeline (Recommended)
1. **New Item** → Name: `Inventory-Management-Tool`
2. Select **Multibranch Pipeline**
3. **Branch Sources** → **Add source** → **Git**
4. **Project Repository**: `https://github.com/YOUR_USERNAME/Inventory-Management-Tool.git`
5. **Credentials**: (Select or add your Git credentials)
6. **Build Configuration**: 
   - Mode: by Jenkinsfile
   - Script Path: `Jenkinsfile`
7. **Save**

## 📝 Customization Checklist

Before running the pipeline, update these in `Jenkinsfile`:

```groovy
environment {
    // Update with your Docker Hub username
    DOCKER_IMAGE = 'your-username/inventory-management-tool'
    DOCKER_REGISTRY = 'docker.io'
    
    // Update with your SonarQube server (if using)
    SONAR_HOST_URL = 'http://your-sonarqube:9000'
    
    // Keep these as is or customize
    APP_PORT = '8082'
    K8S_NAMESPACE = 'default'
}
```

## 🎯 Pipeline Triggers

### Automatic Trigger (Recommended)
Set up GitHub webhook:
1. Go to your GitHub repo → Settings → Webhooks
2. Add webhook:
   - Payload URL: `http://your-jenkins-server:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Push events
3. Save

### Manual Trigger
1. Go to your pipeline job in Jenkins
2. Click **Build Now**

### Scheduled Build (Optional)
In pipeline configuration → Build Triggers → Build periodically
```
# Every night at 2 AM
H 2 * * *

# Every 4 hours
H */4 * * *
```

## 🌿 Branch Strategy

The pipeline behaves differently based on branches:

### `develop` branch
- ✅ Full pipeline execution
- ✅ Push Docker image to registry
- ✅ Auto-deploy to Development environment
- ✅ Run integration tests
- ❌ No production deployment

### `main` branch
- ✅ Full pipeline execution
- ✅ Push Docker image to registry
- ✅ Deploy to Staging environment
- ✅ Run integration tests
- ✅ Deploy to Production (with manual approval)

### Feature branches
- ✅ Build and compile
- ✅ Run unit tests
- ✅ Code quality checks
- ✅ Build Docker image (not pushed)
- ❌ No deployment

## 🐛 Common Issues & Solutions

### Issue 1: Maven Build Fails
```bash
# Solution: Clear Maven cache
docker exec jenkins rm -rf /var/jenkins_home/.m2/repository
# Or in Jenkinsfile, add:
sh 'mvn dependency:purge-local-repository'
```

### Issue 2: Docker Permission Denied
```bash
# Solution: Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue 3: Cannot Connect to Docker Daemon
```bash
# Solution: Mount Docker socket when running Jenkins
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

### Issue 4: Kubernetes Connection Failed
```bash
# Solution: Configure kubectl in Jenkins
kubectl config view --raw > ~/.kube/config
# Or use Kubernetes plugin configuration
```

### Issue 5: Tests Fail in Pipeline
```bash
# Solution: Check test database configuration
# Update application-test.properties or use H2 in-memory DB
```

## 📊 Monitoring Pipeline

### View Build Status
- Dashboard shows all builds
- Blue Ocean provides visual pipeline view

### Check Console Output
- Click on build number → Console Output
- Shows detailed logs

### Test Reports
- Build → Test Result
- Shows passed/failed tests

### Code Coverage
- Build → Coverage Report
- View JaCoCo coverage

### SonarQube Results
- Build → SonarQube Analysis
- View code quality metrics

## 🔔 Notifications

### Email Setup
1. **Manage Jenkins** → **System** → **Extended E-mail Notification**
2. Configure SMTP server (e.g., Gmail):
   - SMTP server: `smtp.gmail.com`
   - SMTP Port: `587`
   - Use SSL: ✓
3. Add credentials (email + app password)
4. Uncomment email sections in Jenkinsfile

### Slack Setup (Optional)
1. Install Slack Notification plugin
2. Get Slack webhook URL
3. Add to Jenkins system configuration
4. Add Slack notification in Jenkinsfile

## 🎨 Customizing Pipeline

### Disable a Stage
```groovy
stage('SonarQube Analysis') {
    when {
        expression { return false } // Disable
    }
    steps { /* ... */ }
}
```

### Add Custom Stage
```groovy
stage('My Custom Stage') {
    steps {
        script {
            echo 'Running custom task...'
        }
        sh 'your-custom-command'
    }
}
```

### Run Stage Only on Specific Branch
```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps { /* ... */ }
}
```

## 🧪 Testing Pipeline Locally

### Test Docker Build
```bash
docker build -t inventory-management-tool:test .
```

### Test Maven Build
```bash
mvn clean package -DskipTests
```

### Test Integration Script
```bash
python3 test.py
```

### Test Kubernetes Deployment
```bash
kubectl apply -f k8s/ --dry-run=client
```

## 📈 Best Practices

1. **Always use credentials manager** - Never hardcode secrets
2. **Tag Docker images** with build numbers
3. **Run tests before deploying**
4. **Use quality gates** to prevent bad code
5. **Monitor build times** and optimize
6. **Archive artifacts** for traceability
7. **Set up notifications** for quick feedback
8. **Use Blue Ocean** for better visualization

## 🔗 Useful Commands

### Jenkins Management
```bash
# Restart Jenkins (Docker)
docker restart jenkins

# View Jenkins logs
docker logs -f jenkins

# Backup Jenkins
docker exec jenkins tar -czf /tmp/jenkins-backup.tar.gz /var/jenkins_home
docker cp jenkins:/tmp/jenkins-backup.tar.gz ./
```

### Pipeline Management
```bash
# Validate Jenkinsfile syntax
curl -X POST -F "jenkinsfile=<Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate

# Trigger build via API
curl -X POST http://admin:token@localhost:8080/job/Inventory-Management-Tool/build
```

## 📚 Resources

- 📖 [JENKINS_SETUP.md](JENKINS_SETUP.md) - Detailed setup guide
- 🌐 [Jenkins Documentation](https://www.jenkins.io/doc/)
- 🐳 [Docker Documentation](https://docs.docker.com/)
- ☸️ [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🆘 Getting Help

1. Check Jenkins console output for errors
2. Review this quick reference
3. Consult JENKINS_SETUP.md for details
4. Check Jenkins logs: `docker logs jenkins`
5. Visit Jenkins community forums

---

**Last Updated**: October 2025
