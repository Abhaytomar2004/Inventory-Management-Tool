package com.inventory.im.controller;

import com.inventory.im.dto.UserRegisterRequest;
import com.inventory.im.dto.UserLoginRequest;
import com.inventory.im.dto.AuthResponse;
import com.inventory.im.model.User;
import com.inventory.im.service.UserService;
import com.inventory.im.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
public class AuthController {
    @Autowired
    private UserService userService;

    @PostMapping("/register")
    // public String getProducts() {
    //     return "Hello, this is the ProductController!";
    // }
    public ResponseEntity<?> register(@RequestBody UserRegisterRequest request) {
        boolean created = userService.registerUser(request.getUsername(), request.getPassword());
        if (created) {
            return ResponseEntity.status(HttpStatus.CREATED).build();
        } else {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User already exists");
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserLoginRequest request) {
        Optional<User> userOpt = userService.authenticate(request.getUsername(), request.getPassword());
        if (userOpt.isPresent()) {
            String token = JwtUtil.generateToken(userOpt.get().getUsername());
            return ResponseEntity.ok(new AuthResponse(token));
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }
    }
} 