package com.teampulse.api.member;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberRepository extends JpaRepository<Member, UUID> {
    List<Member> findByWorkspaceIdOrderByNameAsc(UUID workspaceId);
    Optional<Member> findByIdAndWorkspaceId(UUID id, UUID workspaceId);
}