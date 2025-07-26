# 📦 Inventory Management Tool

![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.7.0-green.svg)
![Java](https://img.shields.io/badge/Java-21-blue.svg)
![JWT](https://img.shields.io/badge/JWT-Authentication-orange)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue).

A robust Spring Boot application for managing inventory with secure authentication and RESTful API endpoints.

## ✨ Features

- 🔐 JWT-based user authentication
- 📝 Add, update, and view products
- 📊 Manage product quantities
- 📱 Responsive API design
- 🔄 Paginated product listings
- 🐳 Docker container support

## 🛠️ Prerequisites

Before you begin, ensure you have installed:

- Java 21 or higher
- Maven 3.8.6 or higher
- MySQL 8.0 or compatible database
- Postman (for API testing)

## 🚀 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone -b im-01 https://github.com/Abhaytomar2004/Inventory-Management-Tool.git
   cd Inventory-Management-Tool
   
  2. **Configure database**

Create a MySQL database named inventory_db


Update application.properties with your credentials:

spring.datasource.url=jdbc:mysql://localhost:3306/inventory_db

spring.datasource.username=your_username

spring.datasource.password=your_password


3. **Build and run**
 ```bash
mvn clean install

mvn spring-boot:run
```

Option 2: **Docker Deployment**
1. Build Docker image
```
docker build -t inventory-management .
```
2. Run with Docker Compose
```
docker-compose up -d
```

This will start:

MySQL container

Spring Boot application container

Automatic database initialization

Access the application

API will be available at http://localhost:8082


🌐 API Endpoints

1. User Authentication

Endpoint: POST /login'

Request:
{

  "username": "string",
  
  "password": "string"
  
}

Response:

Success: JWT token

Failure: Invalid credentials
<img width="1920" height="1080" alt="Screenshot (84)" src="https://github.com/user-attachments/assets/e6325944-1c47-4aad-8115-3061414013ee" />

2. Add Product

Endpoint: POST /products

Payload:

{

  "name": "string",
  
  "type": "string",
  
  "sku": "string",
  
  "image_url": "string",
  
  "description": "string",
  
  "quantity": 10,
  
  "price": 99.99
  
}

Authentication: Required (JWT)
Response: Product ID and confirmation

<img width="1920" height="1080" alt="Screenshot (81)" src="https://github.com/user-attachments/assets/21dfd8f8-5ad2-40c1-8c05-0a8ef1adb87e" />


3. Update Product Quantity

Endpoint: PUT /products/{id}/quantity

Payload:
{

  "quantity": 10
  
}

Authentication: Required (JWT)
Response: Updated product details

<img width="1920" height="1080" alt="Screenshot (82)" src="https://github.com/user-attachments/assets/38d357f0-8044-46fc-b013-17a1ce55e051" />


5. Get Products
   
Endpoint: GET /products

Parameters: page, size (for pagination)

Authentication: Required (JWT)


Response: Paginated list of products

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2814fd24-8cf7-4aa0-8430-a1cda6f5d5e5" />

🐳 Docker Configuration Details

The application includes:

Dockerfile for building the Spring Boot application image

docker-compose.yml for orchestration with MySQL

Automatic database schema initialization

Environment variables for easy configuration



