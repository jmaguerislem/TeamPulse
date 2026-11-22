package com.teampulse.api.member;

import com.teampulse.api.workspace.Workspace;
import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "members")
public class Member {
    @Id
    private UUID id = UUID.randomUUID();

    @ManyToOne(optional = false)
    @JoinColumn(name = "workspace_id")
    private Workspace workspace;

    @Column(nullable = false)
    private String name;

    @Column(name = "member_role", nullable = false)
    private String role;

    @Column(name = "is_lead", nullable = false)
    private boolean lead;

    protected Member() {}

    public Member(Workspace workspace, String name, String role, boolean lead) {
        this.workspace = workspace;
        this.name = name;
        this.role = role;
        this.lead = lead;
    }

    public UUID getId() { return id; }
    public Workspace getWorkspace() { return workspace; }
    public String getName() { return name; }
    public String getRole() { return role; }
    public boolean isLead() { return lead; }
    public void rename(String name) { this.name = name; }
}