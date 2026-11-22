package com.teampulse.api.attachment;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Component
public class AttachmentStorage {
    private final Path root;

    public AttachmentStorage(@Value("${app.upload-dir}") String dir) throws IOException {
        this.root = Path.of(dir).toAbsolutePath().normalize();
        Files.createDirectories(root);
    }

    /** Enregistre le fichier et retourne son nom sur le disque. */
    public String save(MultipartFile file) throws IOException {
        String stored = UUID.randomUUID().toString();
        try (InputStream in = file.getInputStream()) {
            Files.copy(in, root.resolve(stored), StandardCopyOption.REPLACE_EXISTING);
        }
        return stored;
    }

    public Resource load(String storedName) {
        return new FileSystemResource(root.resolve(storedName));
    }

    public void delete(String storedName) {
        try {
            Files.deleteIfExists(root.resolve(storedName));
        } catch (IOException ignored) {
            // le fichier sera simplement orphelin sur le disque
        }
    }
}