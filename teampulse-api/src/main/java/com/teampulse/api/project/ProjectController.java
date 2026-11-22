package com.teampulse.api.project;

import com.teampulse.api.common.Errors;
import com.teampulse.api.task.TaskRepository;
import com.teampulse.api.user.AppUser;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.teampulse.api.attachment.AttachmentService;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {
    public record ProjectDto(String id, String name, String description,
                             LocalDate startDate, LocalDate deadline, ProjectStatus status) {}

    public record ProjectRequest(@NotBlank String name, String description,
                                 @NotNull LocalDate startDate, @NotNull LocalDate deadline,
                                 @NotNull ProjectStatus status) {}

    private final ProjectRepository projects;
    private final TaskRepository tasks;
    private final AttachmentService attachmentService;

    public ProjectController(ProjectRepository projects, TaskRepository tasks,
                             AttachmentService attachmentService) {
        this.projects = projects;
        this.tasks = tasks;
        this.attachmentService = attachmentService;
    }

    private static ProjectDto dto(Project p) {
        return new ProjectDto(p.getId().toString(), p.getName(), p.getDescription(),
                p.getStartDate(), p.getDeadline(), p.getStatus());
    }

    private static void check(ProjectRequest r) {
        if (r.deadline().isBefore(r.startDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "deadline_before_start");
        }
    }

    @GetMapping
    public List<ProjectDto> list(@AuthenticationPrincipal AppUser user) {
        return projects.findByWorkspaceIdOrderByDeadlineAsc(user.getWorkspace().getId())
                .stream().map(ProjectController::dto).toList();
    }

    @PostMapping
    public ProjectDto create(@AuthenticationPrincipal AppUser user,
                             @Valid @RequestBody ProjectRequest r) {
        check(r);
        Project p = projects.save(new Project(user.getWorkspace(), r.name().trim(),
                r.description(), r.startDate(), r.deadline(), r.status()));
        return dto(p);
    }

    @PutMapping("/{id}")
    @Transactional
    public ProjectDto update(@AuthenticationPrincipal AppUser user, @PathVariable UUID id,
                             @Valid @RequestBody ProjectRequest r) {
        check(r);
        Project p = projects.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("project_not_found"));
        p.update(r.name().trim(), r.description(), r.startDate(), r.deadline(), r.status());
        return dto(p);
    }

    @DeleteMapping("/{id}")
    @Transactional
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AppUser user, @PathVariable UUID id) {
        Project p = projects.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("project_not_found"));
        attachmentService.deleteForProject(id);
        tasks.deleteByProjectId(id); // supprime aussi ses tâches
        projects.delete(p);
    }
}