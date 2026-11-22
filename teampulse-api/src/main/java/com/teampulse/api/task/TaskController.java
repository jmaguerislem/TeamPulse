package com.teampulse.api.task;

import com.teampulse.api.common.Errors;
import com.teampulse.api.member.Member;
import com.teampulse.api.member.MemberRepository;
import com.teampulse.api.project.Project;
import com.teampulse.api.project.ProjectRepository;
import com.teampulse.api.user.AppUser;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import com.teampulse.api.attachment.AttachmentService;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    public record TaskDto(String id, String projectId, String title, String description,
                          LocalDate dueDate, TaskPriority priority, TaskStatus status,
                          String assigneeId, Instant createdAt, Instant completedAt) {}

    public record TaskRequest(@NotNull UUID projectId, @NotBlank String title, String description,
                              @NotNull LocalDate dueDate, @NotNull TaskPriority priority) {}

    public record StatusRequest(@NotNull TaskStatus status) {}

    public record AssignRequest(UUID memberId) {} // null = retirer l'assignation

    private final TaskRepository tasks;
    private final ProjectRepository projects;
    private final MemberRepository members;
    private final AttachmentService attachmentService;

    public TaskController(TaskRepository tasks, ProjectRepository projects,
                          MemberRepository members, AttachmentService attachmentService) {
        this.tasks = tasks;
        this.projects = projects;
        this.members = members;
        this.attachmentService = attachmentService;
    }

    private static TaskDto dto(Task t) {
        return new TaskDto(t.getId().toString(), t.getProject().getId().toString(),
                t.getTitle(), t.getDescription(), t.getDueDate(), t.getPriority(), t.getStatus(),
                t.getAssignee() == null ? null : t.getAssignee().getId().toString(),
                t.getCreatedAt(), t.getCompletedAt());
    }

    private Task find(AppUser user, UUID id) {
        return tasks.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("task_not_found"));
    }

    private Project findProject(AppUser user, UUID id) {
        return projects.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("project_not_found"));
    }

    @GetMapping
    public List<TaskDto> list(@AuthenticationPrincipal AppUser user,
                              @RequestParam(required = false) UUID projectId) {
        UUID wid = user.getWorkspace().getId();
        List<Task> found = projectId == null
                ? tasks.findByWorkspaceIdOrderByDueDateAsc(wid)
                : tasks.findByWorkspaceIdAndProjectIdOrderByDueDateAsc(wid, projectId);
        return found.stream().map(TaskController::dto).toList();
    }

    @PostMapping
    public TaskDto create(@AuthenticationPrincipal AppUser user, @Valid @RequestBody TaskRequest r) {
        Project p = findProject(user, r.projectId());
        Task t = tasks.save(new Task(user.getWorkspace(), p, r.title().trim(),
                r.description(), r.dueDate(), r.priority()));
        return dto(t);
    }

    @PutMapping("/{id}")
    @Transactional
    public TaskDto update(@AuthenticationPrincipal AppUser user, @PathVariable UUID id,
                          @Valid @RequestBody TaskRequest r) {
        Task t = find(user, id);
        t.update(findProject(user, r.projectId()), r.title().trim(),
                r.description(), r.dueDate(), r.priority());
        return dto(t);
    }

    @PatchMapping("/{id}/status")
    @Transactional
    public TaskDto changeStatus(@AuthenticationPrincipal AppUser user, @PathVariable UUID id,
                                @Valid @RequestBody StatusRequest r) {
        Task t = find(user, id);
        t.changeStatus(r.status());
        return dto(t);
    }

    @PatchMapping("/{id}/assignee")
    @Transactional
    public TaskDto assign(@AuthenticationPrincipal AppUser user, @PathVariable UUID id,
                          @RequestBody AssignRequest r) {
        Task t = find(user, id);
        Member m = r.memberId() == null ? null
                : members.findByIdAndWorkspaceId(r.memberId(), user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("member_not_found"));
        t.setAssignee(m);
        return dto(t);
    }

    @DeleteMapping("/{id}")
    @Transactional
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AppUser user, @PathVariable UUID id) {
        Task t = find(user, id);
        attachmentService.deleteForTask(t.getId());
        tasks.delete(t);
    }
}