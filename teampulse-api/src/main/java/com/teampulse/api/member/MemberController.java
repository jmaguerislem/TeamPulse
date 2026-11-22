package com.teampulse.api.member;

import com.teampulse.api.common.Errors;
import com.teampulse.api.task.TaskRepository;
import com.teampulse.api.user.AppUser;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/members")
public class MemberController {
    public record MemberDto(String id, String name, String role, boolean lead) {}
    public record MemberRequest(@NotBlank String name, @NotBlank String role) {}

    private final MemberRepository members;
    private final TaskRepository tasks;

    public MemberController(MemberRepository members, TaskRepository tasks) {
        this.members = members;
        this.tasks = tasks;
    }

    private static MemberDto dto(Member m) {
        return new MemberDto(m.getId().toString(), m.getName(), m.getRole(), m.isLead());
    }

    @GetMapping
    public List<MemberDto> list(@AuthenticationPrincipal AppUser user) {
        return members.findByWorkspaceIdOrderByNameAsc(user.getWorkspace().getId())
                .stream().map(MemberController::dto).toList();
    }

    @PostMapping
    public MemberDto create(@AuthenticationPrincipal AppUser user,
                            @Valid @RequestBody MemberRequest r) {
        Member m = members.save(new Member(user.getWorkspace(), r.name().trim(), r.role().trim(), false));
        return dto(m);
    }

    @DeleteMapping("/{id}")
    @Transactional
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AppUser user, @PathVariable UUID id) {
        Member m = members.findByIdAndWorkspaceId(id, user.getWorkspace().getId())
                .orElseThrow(() -> Errors.notFound("member_not_found"));
        if (m.isLead()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "lead_cannot_be_removed");
        }
        // Ses tâches redeviennent « non assignées ».
        tasks.findByAssigneeId(id).forEach(t -> t.setAssignee(null));
        members.delete(m);
    }
}