package com.example.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@RestController
public class PythonController {

    private static final Logger log = LoggerFactory.getLogger(PythonController.class);

    @Value("${python.executable:python3}")
    private String pythonExecutable;

    @Value("${python.script.path:scripts/hello.py}")
    private String scriptPath;

    @GetMapping("/run-python")
    public String runPython() {
        log.info("Executing Python script: {} {}", pythonExecutable, scriptPath);
        try {
            ProcessBuilder pb = new ProcessBuilder(pythonExecutable, scriptPath);
            pb.redirectErrorStream(true);

            Process process = pb.start();

            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    log.info("[Python] {}", line);
                    output.append(line).append("\n");
                }
            }

            int exitCode = process.waitFor();
            log.info("Python script exited with code: {}", exitCode);

            if (exitCode != 0) {
                return "Python script failed with exit code: " + exitCode + "\n" + output;
            }
            return output.toString();
        } catch (Exception e) {
            log.error("Failed to execute Python script", e);
            return "Error: " + e.getMessage();
        }
    }
}
