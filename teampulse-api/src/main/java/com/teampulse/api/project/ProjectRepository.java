package com.teampulse.api.project;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProjectRepository extends JpaRepository<Project, UUID> {
    List<Project> findByWorkspaceIdOrderByDeadlineAsc(UUID workspaceId);
    Optional<Project> findByIdAndWorkspaceId(UUID id, UUID workspaceId);
}