package com.teampulse.api.workspace;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "workspaces")
public class Workspace {
    @Id
    private UUID id = UUID.randomUUID();

    @Column(nullable = false, unique = true, length = 16)
    private String code;

    protected Workspace() {}

    public Workspace(String code) { this.code = code; }

    public UUID getId() { return id; }
    public String getCode() { return code; }
}