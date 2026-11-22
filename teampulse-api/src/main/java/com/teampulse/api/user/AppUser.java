package com.teampulse.api.user;

import com.teampulse.api.workspace.Workspace;
import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "users")
public class AppUser {
    @Id
    private UUID id = UUID.randomUUID();

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @ManyToOne(optional = false)
    @JoinColumn(name = "workspace_id")
    private Workspace workspace;

    protected AppUser() {}

    public AppUser(String fullName, String email, String passwordHash, Workspace workspace) {
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.workspace = workspace;
    }

    public UUID getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public Workspace getWorkspace() { return workspace; }
    public void updateProfile(String fullName, String email) {
        this.fullName = fullName;
        this.email = email;
    }

    public void changePasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
}
