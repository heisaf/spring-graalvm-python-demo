package com.exxeta.projectmatcher.configuration;

import com.exxeta.projectmatcher.service.RecommendationService;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Source;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.ResourceLoader;

import java.io.IOException;

@Configuration
public class PythonConfiguration {

    private static final Logger LOGGER = LoggerFactory.getLogger(PythonConfiguration.class);

    ResourceLoader resourceLoader;

    private static String pythonPath = "classpath:com/exxeta/projectmatcher/service";

    public PythonConfiguration(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @Bean
    public RecommendationService getRecommendationService() throws IOException {
        final var currDir = System.getProperty("user.dir") + "/venv/bin/graalpy";
        LOGGER.info("graalPy? {}", currDir);
        final var fileRes = new FileSystemResource(currDir).getPath();
        LOGGER.info("fileRes: {}", fileRes);
/*
        final String venvExePath = this.getClass().
                getClassLoader().
                getResource(currDir).
                getPath();
 */
        Context context = Context
            .newBuilder("python")
            .allowAllAccess(true)
            .option("python.Executable", fileRes)
            .option("python.ForceImportSite", "true")
            .option("python.PythonPath",
                    resourceLoader
                            .getResource(pythonPath)
                            .getFile()
                            .toPath()
                            .toString()
            )
            .build();

        Source source = Source
                .newBuilder("python",
                resourceLoader.getResource(pythonPath + "/RecommendationServiceImpl.py").getFile()
        ).build();

        context.eval(source);

        return context
                .getBindings("python")
                .getMember("RecommendationServiceImpl")
                .as(RecommendationService.class);
    }
}
