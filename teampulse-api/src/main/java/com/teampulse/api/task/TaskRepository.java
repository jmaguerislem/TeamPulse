package com.teampulse.api.task;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskRepository extends JpaRepository<Task, UUID> {
    List<Task> findByWorkspaceIdOrderByDueDateAsc(UUID workspaceId);
    List<Task> findByWorkspaceIdAndProjectIdOrderByDueDateAsc(UUID workspaceId, UUID projectId);
    Optional<Task> findByIdAndWorkspaceId(UUID id, UUID workspaceId);
    List<Task> findByAssigneeId(UUID memberId);
    void deleteByProjectId(UUID projectId);
}