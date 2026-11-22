package com.teampulse.api.attachment;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class AttachmentService {
    private final AttachmentRepository attachments;
    private final AttachmentStorage storage;

    public AttachmentService(AttachmentRepository attachments, AttachmentStorage storage) {
        this.attachments = attachments;
        this.storage = storage;
    }

    @Transactional
    public void deleteForTask(UUID taskId) {
        remove(attachments.findByTaskId(taskId));
    }

    @Transactional
    public void deleteForProject(UUID projectId) {
        remove(attachments.findByTask_Project_Id(projectId));
    }

    private void remove(List<Attachment> list) {
        list.forEach(a -> storage.delete(a.getStoredName()));
        attachments.deleteAll(list);
    }
}