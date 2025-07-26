"""
Inventory Management Tool - API Test Script
Final optimized version with fixes for observed issues
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8082" 
def print_result(test_name, passed, expected=None, got=None, request_data=None, response=None):
    """
    Enhanced test result printer with better formatting
    """
    print(f"\n{'='*50}")
    print(f"Test: {test_name}")
    print(f"Status: {'PASSED' if passed else 'FAILED'}")
    
    if request_data:
        print("\nRequest Data:")
        print(json.dumps(request_data, indent=2))
    
    if expected is not None and got is not None:
        print(f"\nExpected: {expected} | Got: {got}")
    
    if response:
        print("\nResponse Details:")
        print(f"Status Code: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")
        try:
            json_data = response.json()
            print("JSON Response:")
            print(json.dumps(json_data, indent=2))
        except ValueError:
            print(f"Raw Response: {response.text}")
    print('='*50)

def test_server_connection():
    """Test if server is reachable"""
    try:
        res = requests.get(f"{BASE_URL}/", timeout=5)
        # Accept both 200 (OK) and 403 (Forbidden) as successful connection
        passed = res.status_code in [200, 403]
        print_result("Server Connection", passed, "200 or 403", res.status_code, None, res)
        return True
    except requests.exceptions.ConnectionError:
        print_result("Server Connection", False, "Server running", "Connection failed")
        return False
    except Exception as e:
        print_result("Server Connection", False, "200 or 403", f"Exception: {str(e)}")
        return False

def test_register_user():
    """Test user registration endpoint"""
    payload = {
        "username": "testuser",
        "password": "testpassword"
    }
    
    try:
        res = requests.post(f"{BASE_URL}/register", json=payload, timeout=5)
        passed = res.status_code in [201, 409]
        print_result("User Registration", passed, "201 or 409", res.status_code, payload, res)
        return passed
    except Exception as e:
        print_result("User Registration", False, "201 or 409", f"Exception: {str(e)}", payload)
        return False

def test_login():
    """Test login endpoint and return token"""
    payload = {
        "username": "testuser",
        "password": "testpassword"
    }
    
    try:
        res = requests.post(f"{BASE_URL}/login", json=payload, timeout=5)
        if res.status_code == 200:
            try:
                token = res.json().get("access_token")
                if token:
                    print_result("Login Test", True, 200, res.status_code, payload, res)
                    return token
            except ValueError:
                pass
        print_result("Login Test", False, 200, res.status_code, payload, res)
        return None
    except Exception as e:
        print_result("Login Test", False, "200", f"Exception: {str(e)}", payload)
        return None

def test_get_products(token):
    """Test getting products with authentication"""
    headers = {"Authorization": f"Bearer {token}"}
    try:
        res = requests.get(f"{BASE_URL}/products", headers=headers, timeout=5)
        passed = res.status_code == 200
        print_result("Get Products", passed, 200, res.status_code, None, res)
        return passed
    except Exception as e:
        print_result("Get Products", False, "200", f"Exception: {str(e)}")
        return False

def test_add_product(token):
    """Test adding a new product with proper authorization"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "name": "Test Product",
        "type": "Electronics",
        "sku": f"SKU-{datetime.now().strftime('%Y%m%d%H%M%S')}",
        "imageUrl": "https://example.com/product.jpg",  
        "description": "Test product description",
        "quantity": 10,
        "price": 99.99
    }
    
    try:
        res = requests.post(
            f"{BASE_URL}/products", 
            json=payload,
            headers=headers,
            timeout=5
        )
        
        passed = res.status_code == 201
        print_result("Add Product", passed, 201, res.status_code, payload, res)
        
        if passed:
            try:
                return res.json().get("id")
            except ValueError:
                return None
        return None
    except Exception as e:
        print_result("Add Product", False, "201", f"Exception: {str(e)}", payload)
        return None

def test_update_quantity(token, product_id):
    """Test updating product quantity"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {"quantity": 15}
    
    try:
        res = requests.put(
            f"{BASE_URL}/products/{product_id}/quantity",
            json=payload,
            headers=headers,
            timeout=5
        )
        passed = res.status_code == 200
        print_result("Update Quantity", passed, 200, res.status_code, payload, res)
        return passed
    except Exception as e:
        print_result("Update Quantity", False, "200", f"Exception: {str(e)}", payload)
        return False

def run_all_tests():
    """Main test runner with proper sequencing"""
    print("\n" + "="*50)
    print("Starting API Test Sequence")
    print("="*50)
    
    # 1. Test server connection
    if not test_server_connection():
        print("\n[!] Server not reachable. Please start your Flask application first.")
        return
    
    # 2. Test registration
    if not test_register_user():
        print("\n[!] Registration test failed. Trying to continue with login...")
    
    # 3. Test login
    token = test_login()
    if not token:
        print("\n[!] Login failed. Skipping authenticated tests.")
        return
    
    # 4. Test get products
    if not test_get_products(token):
        print("\n[!] Get products failed. Trying to continue...")
    
    # 5. Test add product
    product_id = test_add_product(token)
    if not product_id:
        print("\n[!] Product creation failed. Trying with existing product...")
        # Try with existing product ID (2 from your response)
        product_id = 2
    
    # 6. Test update quantity
    if product_id:
        test_update_quantity(token, product_id)
    
    print("\n" + "="*50)
    print("Test Sequence Completed")
    print("="*50)

if __name__ == "__main__":
    run_all_tests()