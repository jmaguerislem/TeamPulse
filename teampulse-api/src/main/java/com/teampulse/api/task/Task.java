package com.teampulse.api.task;

import com.teampulse.api.member.Member;
import com.teampulse.api.project.Project;
import com.teampulse.api.workspace.Workspace;
import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "tasks")
public class Task {
    @Id
    private UUID id = UUID.randomUUID();

    @ManyToOne(optional = false)
    @JoinColumn(name = "workspace_id")
    private Workspace workspace;

    @ManyToOne(optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @ManyToOne
    @JoinColumn(name = "assignee_id")
    private Member assignee;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description = "";

    @Column(nullable = false)
    private LocalDate dueDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskPriority priority;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskStatus status = TaskStatus.TODO;

    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    private Instant completedAt;

    protected Task() {}

    public Task(Workspace workspace, Project project, String title, String description,
                LocalDate dueDate, TaskPriority priority) {
        this.workspace = workspace;
        update(project, title, description, dueDate, priority);
    }

    public void update(Project project, String title, String description,
                       LocalDate dueDate, TaskPriority priority) {
        this.project = project;
        this.title = title;
        this.description = description == null ? "" : description;
        this.dueDate = dueDate;
        this.priority = priority;
    }

    public void changeStatus(TaskStatus status) {
        this.status = status;
        this.completedAt = status == TaskStatus.DONE ? Instant.now() : null;
    }

    public void setAssignee(Member assignee) { this.assignee = assignee; }

    public UUID getId() { return id; }
    public Project getProject() { return project; }
    public Member getAssignee() { return assignee; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public LocalDate getDueDate() { return dueDate; }
    public TaskPriority getPriority() { return priority; }
    public TaskStatus getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getCompletedAt() { return completedAt; }
}