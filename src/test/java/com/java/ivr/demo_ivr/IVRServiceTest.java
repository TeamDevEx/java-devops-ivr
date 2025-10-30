package com.java.ivr.demo_ivr;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class IVRServiceTest {

    private IVRService ivrService;

    @BeforeEach
    public void setUp() {
        ivrService = new IVRService();
    }

    @Test
    public void testOption1() {
        String result = ivrService.processUserInput("1");
        assertEquals("You selected option 1. Please wait while we connect you to retention support.", result);
    }

    @Test
    public void testOption2() {
        String result = ivrService.processUserInput("2");
        assertEquals("You selected option 2. Please hold for billing and other account inquiries.", result);
    }

    @Test
    public void testOption3() {
        String result = ivrService.processUserInput("3");
        assertEquals("You selected option 3. Redirecting you to technical support.", result);
    }

    @Test
    public void testInvalidOption() {
        String result = ivrService.processUserInput("9");
        assertEquals("Invalid option. Please try again.", result);
    }

}
