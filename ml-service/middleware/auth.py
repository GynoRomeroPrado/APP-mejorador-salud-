"""Middleware de autenticación JWT."""

from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from config import get_settings
import structlog

logger = structlog.get_logger()
security = HTTPBearer()
settings = get_settings()


async def verify_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    Verifica el token JWT y retorna el payload.

    Args:
        credentials: Credenciales HTTP con el token

    Returns:
        Payload del token decodificado

    Raises:
        HTTPException: Si el token es inválido
    """
    token = credentials.credentials

    try:
        # Decodificar token
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm],
        )

        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return payload

    except JWTError as e:
        logger.error("JWT verification failed", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No se pudo validar el token",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_current_user_id(token_payload: dict = Depends(verify_token)) -> str:
    """Extrae el user_id del token."""
    return token_payload.get("sub")
