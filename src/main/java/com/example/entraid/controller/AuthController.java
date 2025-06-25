package com.example.entraid.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AuthController {
    
    @GetMapping("/")
    public String home() {
        return "home";
    }
    
    @GetMapping("/home")
    public String homeRedirect() {
        return "home";
    }
    
    /**
     * Sign Up Flow - New user registration
     */
    @GetMapping("/signup")
    public String signUp(@RequestParam(value = "error", required = false) String error, Model model) {
        if (error != null) {
            model.addAttribute("error", "Sign up failed. Please try again.");
        }
        model.addAttribute("isSignup", true);
        return "auth";
    }
    
    /**
     * Sign In Flow - Existing user login
     */
    @GetMapping("/signin")
    public String signIn(@RequestParam(value = "error", required = false) String error, Model model) {
        if (error != null) {
            model.addAttribute("error", "Sign in failed. Please try again.");
        }
        model.addAttribute("isSignup", false);
        return "auth";
    }
    
    /**
     * Dashboard - Protected page after successful authentication
     */
    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal OAuth2User principal, Model model) {
        if (principal != null) {
            model.addAttribute("name", principal.getAttribute("name"));
            model.addAttribute("email", principal.getAttribute("email"));
            model.addAttribute("attributes", principal.getAttributes());
        }
        return "dashboard";
    }
    
    /**
     * Profile page
     */
    @GetMapping("/profile")
    public String profile(@AuthenticationPrincipal OAuth2User principal, Model model) {
        if (principal != null) {
            model.addAttribute("name", principal.getAttribute("name"));
            model.addAttribute("email", principal.getAttribute("email"));
            model.addAttribute("attributes", principal.getAttributes());
        }
        return "profile";
    }
} 