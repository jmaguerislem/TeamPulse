package com.teampulse.api.auth;

import com.teampulse.api.auth.AuthDtos.*;
import com.teampulse.api.security.JwtService;
import com.teampulse.api.user.AppUser;
import com.teampulse.api.user.UserRepository;
import com.teampulse.api.workspace.Workspace;
import com.teampulse.api.workspace.WorkspaceRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.teampulse.api.member.Member;
import com.teampulse.api.member.MemberRepository;

import java.security.SecureRandom;

@RestController
public class AuthController {
    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final SecureRandom random = new SecureRandom();

    private final UserRepository users;
    private final WorkspaceRepository workspaces;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final MemberRepository members;

    public AuthController(UserRepository users, WorkspaceRepository workspaces,
                          MemberRepository members, PasswordEncoder encoder, JwtService jwt) {
        this.users = users;
        this.workspaces = workspaces;
        this.members = members;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    @PostMapping("/api/auth/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest r) {
        String email = r.email().trim().toLowerCase();
        if (users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "email_taken");
        }

        Workspace workspace;
        boolean newWorkspace = false;
        if (r.workspaceCode() == null || r.workspaceCode().isBlank()) {
            workspace = workspaces.save(new Workspace(newCode())); // nouvelle équipe
            newWorkspace = true;
        } else {
            workspace = workspaces.findByCode(r.workspaceCode().trim().toUpperCase())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "workspace_not_found"));
        }

        AppUser user = users.save(
                new AppUser(r.fullName().trim(), email, encoder.encode(r.password()), workspace));
        // Le créateur de l'équipe est la cheffe de projet ; les autres sont des membres.
        members.save(new Member(workspace, user.getFullName(), "", newWorkspace));
        return response(user);
    }

    @PostMapping("/api/auth/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest r) {
        AppUser user = users.findByEmail(r.email().trim().toLowerCase())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "bad_credentials"));
        if (!encoder.matches(r.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "bad_credentials");
        }
        return response(user);
    }

    /** Sert à vérifier qu'un jeton est valide. */
    @GetMapping("/api/me")
    public AuthResponse me(@AuthenticationPrincipal AppUser user) {
        return response(user);
    }
    @PutMapping("/api/me")
    public AuthResponse updateMe(@AuthenticationPrincipal AppUser user,
                                 @Valid @RequestBody UpdateProfileRequest r) {
        String email = r.email().trim().toLowerCase();
        if (!email.equals(user.getEmail()) && users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "email_taken");
        }
        String oldName = user.getFullName();
        user.updateProfile(r.fullName().trim(), email);
        users.save(user);

        // La fiche « cheffe de projet » de l'équipe suit le nom du compte.
        members.findByWorkspaceIdOrderByNameAsc(user.getWorkspace().getId()).stream()
                .filter(m -> m.isLead() && m.getName().equals(oldName))
                .forEach(m -> {
                    m.rename(r.fullName().trim());
                    members.save(m);
                });
        return response(user);
    }

    @PutMapping("/api/me/password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void changePassword(@AuthenticationPrincipal AppUser user,
                               @Valid @RequestBody ChangePasswordRequest r) {
        if (!encoder.matches(r.oldPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "wrong_old_password");
        }
        user.changePasswordHash(encoder.encode(r.newPassword()));
        users.save(user);
    }

    private AuthResponse response(AppUser u) {
        return new AuthResponse(jwt.generate(u.getId()), u.getId().toString(),
                u.getFullName(), u.getEmail(), u.getWorkspace().getCode());
    }

    private String newCode() {
        String code;
        do {
            StringBuilder sb = new StringBuilder("TP-");
            for (int i = 0; i < 6; i++) sb.append(ALPHABET.charAt(random.nextInt(ALPHABET.length())));
            code = sb.toString();
        } while (workspaces.existsByCode(code));
        return code;
    }
}