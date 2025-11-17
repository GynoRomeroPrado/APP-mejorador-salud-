"""Middleware de rate limiting."""

import time
from collections import defaultdict
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
import structlog

logger = structlog.get_logger()


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Middleware para limitar requests por IP."""

    def __init__(self, app, requests_per_minute: int = 60):
        super().__init__(app)
        self.requests_per_minute = requests_per_minute
        self.requests = defaultdict(list)

    async def dispatch(self, request: Request, call_next):
        """Procesa cada request y aplica rate limiting."""
        # Obtener IP del cliente
        client_ip = request.client.host

        # Limpiar requests antiguos (más de 1 minuto)
        current_time = time.time()
        self.requests[client_ip] = [
            req_time
            for req_time in self.requests[client_ip]
            if current_time - req_time < 60
        ]

        # Verificar límite
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            logger.warning(
                "Rate limit exceeded",
                client_ip=client_ip,
                requests=len(self.requests[client_ip]),
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Rate limit excedido. Máximo {self.requests_per_minute} requests por minuto.",
            )

        # Agregar request actual
        self.requests[client_ip].append(current_time)

        # Procesar request
        response = await call_next(request)
        return response
