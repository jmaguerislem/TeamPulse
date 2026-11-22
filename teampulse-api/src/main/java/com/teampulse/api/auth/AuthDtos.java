package com.teampulse.api.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AuthDtos {
    public record RegisterRequest(
            @NotBlank String fullName,
            @NotBlank @Email String email,
            @NotBlank @Size(min = 8) String password,
            String workspaceCode) {}

    public record LoginRequest(@NotBlank String email, @NotBlank String password) {}

    public record AuthResponse(String token, String userId, String fullName,
                               String email, String workspaceCode) {}
    public record UpdateProfileRequest(@NotBlank String fullName, @NotBlank @Email String email) {}

    public record ChangePasswordRequest(@NotBlank String oldPassword,
                                        @NotBlank @Size(min = 8) String newPassword) {}
}