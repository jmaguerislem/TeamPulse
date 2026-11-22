package com.teampulse.api.attachment;

import com.teampulse.api.task.Task;
import com.teampulse.api.workspace.Workspace;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "attachments")
public class Attachment {
    @Id
    private UUID id = UUID.randomUUID();

    @ManyToOne(optional = false)
    @JoinColumn(name = "workspace_id")
    private Workspace workspace;

    @ManyToOne(optional = false)
    @JoinColumn(name = "task_id")
    private Task task;

    @Column(nullable = false)
    private String fileName;

    private String contentType;

    @Column(nullable = false)
    private long size;

    /** Nom du fichier sur le disque (un UUID, jamais le nom d'origine). */
    @Column(nullable = false)
    private String storedName;

    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    protected Attachment() {}

    public Attachment(Workspace workspace, Task task, String fileName,
                      String contentType, long size, String storedName) {
        this.workspace = workspace;
        this.task = task;
        this.fileName = fileName;
        this.contentType = contentType;
        this.size = size;
        this.storedName = storedName;
    }

    public UUID getId() { return id; }
    public Task getTask() { return task; }
    public String getFileName() { return fileName; }
    public String getContentType() { return contentType; }
    public long getSize() { return size; }
    public String getStoredName() { return storedName; }
    public Instant getCreatedAt() { return createdAt; }
}