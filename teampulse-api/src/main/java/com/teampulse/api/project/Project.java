package com.teampulse.api.project;

import com.teampulse.api.workspace.Workspace;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "projects")
public class Project {
    @Id
    private UUID id = UUID.randomUUID();

    @ManyToOne(optional = false)
    @JoinColumn(name = "workspace_id")
    private Workspace workspace;

    @Column(nullable = false)
    private String name;

    @Column(length = 2000)
    private String description = "";

    @Column(nullable = false)
    private LocalDate startDate;

    @Column(nullable = false)
    private LocalDate deadline;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProjectStatus status = ProjectStatus.IN_PROGRESS;

    protected Project() {}

    public Project(Workspace workspace, String name, String description,
                   LocalDate startDate, LocalDate deadline, ProjectStatus status) {
        this.workspace = workspace;
        update(name, description, startDate, deadline, status);
    }

    public void update(String name, String description, LocalDate startDate,
                       LocalDate deadline, ProjectStatus status) {
        this.name = name;
        this.description = description == null ? "" : description;
        this.startDate = startDate;
        this.deadline = deadline;
        this.status = status;
    }

    public UUID getId() { return id; }
    public Workspace getWorkspace() { return workspace; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getDeadline() { return deadline; }
    public ProjectStatus getStatus() { return status; }
}