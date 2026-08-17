# authz-authn.md — Authentication & Authorization Policy

> Always refer to this document before making changes related to authentication or authorization.
> Related ADR: `meta/adr/ADR-0003-auth-strategy.md`

## Authentication

### Method
- **API**: Laravel Sanctum (token-based)
- **Web**: Laravel session authentication

### Login Flow
```
POST /login
  → FormRequest validation
  → Auth::attempt()
  → Session regeneration (prevents session fixation attacks)
  → For API: issue Sanctum token
```

### Security Settings
- Session: HttpOnly + Secure + SameSite=Strict
- CSRF: `VerifyCsrfToken` middleware enabled
- Rate limiting: `throttle:5,1` applied to `/login` endpoint
- Password reset: signed URL + 1-hour expiry

---

## Authorization

### Basic Policy

**Always use Policy / Gate. Direct role checks are prohibited.**

```php
// OK
$this->authorize('update', $post);

// NG (direct role check)
if ($user->role === 'admin') { ... }
```

### Role Definitions

| Role | Description | Permission Scope |
|---|---|---|
| admin | System administrator | Full access to all resources |
| [role2] | [description] | [permissions] |
| user | Regular user | Own resources only |

### Policy Implementation Pattern

```php
class PostPolicy
{
    // Admins can perform all operations
    public function before(User $user): ?bool
    {
        return $user->isAdmin() ? true : null;
    }

    // Only the owner can update
    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }
}
```

### Authorization Call in Controller

```php
public function update(UpdatePostRequest $request, Post $post): JsonResponse
{
    $this->authorize('update', $post);  // always call explicitly

    // processing...
}
```

---

## Change Rules

When changing the authentication or authorization infrastructure:
1. Create a new ADR in `docs/adr/`
2. Undergo a security review
3. Test thoroughly in staging before applying to production
