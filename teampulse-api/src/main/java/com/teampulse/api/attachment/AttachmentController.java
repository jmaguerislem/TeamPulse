package com.teampulse.api.attachment;

import com.teampulse.api.common.Errors;
import com.teampulse.api.task.Task;
import com.teampulse.api.task.TaskRepository;
import com.teampulse.api.user.AppUser;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
public class AttachmentController {
    public record AttachmentDto(String id, String taskId, String name,
                                String contentType, long size, Instant createdAt) {}

    private final AttachmentRepository attachments;
    private final TaskRepository tasks;
    private final AttachmentStorage storage;

    public AttachmentController(AttachmentRepository attachments, TaskRepository tasks,
                                AttachmentStorage storage) {
        this.attachments = attachments;
        this.tasks = tasks;
        this.storage = storage;
    }

    private static AttachmentDto dto(Attachment a) {
        return new AttachmentDto(a.getId().toString(), a.getTask().getId().toString(),
                a.getFileName(), a.getContentType(), a.getSize(), a.getCreatedAt());
    }

    private Task findTask(AppUser user, UUID taskId) {
        return tasks.findByIdAndWorkspaceId(taskId, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("task_not_found"));
    }

    private Attachment findAttachment(AppUser user, UUID id) {
        return attachments.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("attachment_not_found"));
    }

    private static String cleanName(String original) {
        if (original == null || original.isBlank()) return "fichier";
        String n = original.replace('\\', '/');
        n = n.substring(n.lastIndexOf('/') + 1).trim();
        return n.isEmpty() ? "fichier" : n;
    }

    @GetMapping("/api/tasks/{taskId}/attachments")
    public List<AttachmentDto> list(@AuthenticationPrincipal AppUser user,
                                    @PathVariable UUID taskId) {
        findTask(user, taskId);
        return attachments.findByTaskIdOrderByCreatedAtAsc(taskId)
                .stream().map(AttachmentController::dto).toList();
    }

    @PostMapping(value = "/api/tasks/{taskId}/attachments",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public AttachmentDto upload(@AuthenticationPrincipal AppUser user,
                                @PathVariable UUID taskId,
                                @RequestParam("file") MultipartFile file) throws IOException {
        Task task = findTask(user, taskId);
        if (file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "empty_file");
        }
        String stored = storage.save(file);
        Attachment a = attachments.save(new Attachment(user.getWorkspace(), task,
                cleanName(file.getOriginalFilename()), file.getContentType(),
                file.getSize(), stored));
        return dto(a);
    }

    @GetMapping("/api/attachments/{id}/download")
    public ResponseEntity<Resource> download(@AuthenticationPrincipal AppUser user,
                                             @PathVariable UUID id) {
        Attachment a = findAttachment(user, id);
        Resource res = storage.load(a.getStoredName());
        if (!res.exists()) throw Errors.notFound("file_missing");

        MediaType type;
        try {
            type = a.getContentType() == null
                    ? MediaType.APPLICATION_OCTET_STREAM
                    : MediaType.parseMediaType(a.getContentType());
        } catch (Exception e) {
            type = MediaType.APPLICATION_OCTET_STREAM;
        }
        return ResponseEntity.ok()
                .contentType(type)
                .contentLength(a.getSize())
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.attachment()
                                .filename(a.getFileName(), StandardCharsets.UTF_8).build().toString())
                .body(res);
    }

    @DeleteMapping("/api/attachments/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AppUser user, @PathVariable UUID id) {
        Attachment a = findAttachment(user, id);
        storage.delete(a.getStoredName());
        attachments.delete(a);
    }
}