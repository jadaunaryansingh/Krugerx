# Core security helpers and password utilities
import secrets
from typing import Optional
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend


def generate_secure_token(length: int = 32) -> str:
    """
    Generates a cryptographically secure hex token.
    """
    return secrets.token_hex(length)


def encrypt_data(data: str, key: bytes) -> bytes:
    """
    Encrypts sensitive data using AES-GCM (useful for local storage/sync keys).
    """
    iv = secrets.token_bytes(12)
    encryptor = Cipher(
        algorithms.AES(key),
        modes.GCM(iv),
        backend=default_backend()
    ).encryptor()
    ciphertext = encryptor.update(data.encode()) + encryptor.finalize()
    return iv + encryptor.tag + ciphertext


def decrypt_data(encrypted_data: bytes, key: bytes) -> str:
    """
    Decrypts AES-GCM encrypted data.
    """
    iv = encrypted_data[:12]
    tag = encrypted_data[12:28]
    ciphertext = encrypted_data[28:]
    decryptor = Cipher(
        algorithms.AES(key),
        modes.GCM(iv, tag),
        backend=default_backend()
    ).decryptor()
    return (decryptor.update(ciphertext) + decryptor.finalize()).decode()
