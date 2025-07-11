package com.java.ivr.demo_ivr;

import org.springframework.stereotype.Service;

@Service
public class IVRService {
    public String processUserInput(String userInput) {
        switch (userInput) {
            case "1":
                return "You selected option 1. Please wait while we connect you to retention support.";
            case "2":
                return "You selected option 2. Please hold for billing and other account inquiries.";
            case "3":
                return "You selected option 3. Redirecting you to technical support.";
            default:
                return "Invalid option. Please try again.";
        }
    }

}
