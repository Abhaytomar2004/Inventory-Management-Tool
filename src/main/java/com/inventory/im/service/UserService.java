package com.inventory.im.service;

import com.inventory.im.model.User;
import com.inventory.im.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    public boolean registerUser(String username, String password) {
        if (userRepository.findByUsername(username).isPresent()) {
            return false;
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        userRepository.save(user);
        return true;
    }

    public Optional<User> authenticate(String username, String password) {
    Optional<User> userOpt = userRepository.findByUsername(username);
    if (userOpt.isPresent()) {
        User user = userOpt.get();
        System.out.println("Stored encoded password: " + user.getPassword());
        System.out.println("Input password encoded: " + passwordEncoder.encode(password));
        System.out.println("Matches: " + passwordEncoder.matches(password, user.getPassword()));
        if (passwordEncoder.matches(password, user.getPassword())) {
            return userOpt;
        }
    }
    return Optional.empty();
}
} 