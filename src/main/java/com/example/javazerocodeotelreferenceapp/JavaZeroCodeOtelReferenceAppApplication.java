package com.example.javazerocodeotelreferenceapp;

import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class JavaZeroCodeOtelReferenceAppApplication {
    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(JavaZeroCodeOtelReferenceAppApplication.class);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
    }
}
