package com.teampulse.api.attachment;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AttachmentRepository extends JpaRepository<Attachment, UUID> {
    List<Attachment> findByTaskIdOrderByCreatedAtAsc(UUID taskId);
    List<Attachment> findByTaskId(UUID taskId);
    List<Attachment> findByTask_Project_Id(UUID projectId);
    Optional<Attachment> findByIdAndWorkspaceId(UUID id, UUID workspaceId);
}