from rest_framework.permissions import BasePermission


class IsOperator(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and (getattr(user, 'role', '') == 'operator' or user.is_superuser))


class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and (getattr(user, 'role', '') == 'admin' or user.is_superuser))


class IsOperatorOrAdmin(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and (getattr(user, 'role', '') in ('operator','admin') or user.is_superuser))
