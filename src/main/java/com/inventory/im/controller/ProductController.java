package com.inventory.im.controller;

import com.inventory.im.dto.ProductRequest;
import com.inventory.im.dto.QuantityUpdateRequest;
import com.inventory.im.model.Product;
import com.inventory.im.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/products")
public class ProductController {
    @Autowired
    private ProductService productService;

    @PostMapping
    public ResponseEntity<?> addProduct(@RequestBody ProductRequest request) {
        Product product = new Product();
        product.setName(request.getName());
        product.setType(request.getType());
        product.setSku(request.getSku());
        product.setImageUrl(request.getImage_url());
        product.setDescription(request.getDescription());
        product.setQuantity(request.getQuantity());
        product.setPrice(request.getPrice());
        Product saved = productService.addProduct(product);
        Map<String, Object> resp = new HashMap<>();
        resp.put("product_id", saved.getId());
        resp.put("message", "Product added successfully");
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PutMapping("/{id}/quantity")
    public ResponseEntity<?> updateQuantity(@PathVariable Long id, @RequestBody QuantityUpdateRequest request) {
        return productService.updateQuantity(id, request.getQuantity())
                .<ResponseEntity<?>>map(product -> ResponseEntity.ok(product))
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body("Product not found"));
    }

    @GetMapping
    public ResponseEntity<?> getProducts(@RequestParam(defaultValue = "0") int page,
                                         @RequestParam(defaultValue = "10") int size) {
        Page<Product> products = productService.getProducts(page, size);
        return ResponseEntity.ok(products.getContent());
    }
} 