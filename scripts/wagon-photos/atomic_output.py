"""Publish complete generated assets without exposing partial files to Jekyll."""
import os
import tempfile
from pathlib import Path


def atomic_write_bytes(path, data):
    path = Path(path)
    # Jekyll ignores dotfiles; keep the temporary file on the destination filesystem
    # so os.replace is atomic even when /tmp lives on a different mount.
    fd, temporary = tempfile.mkstemp(prefix=f'.{path.name}.', suffix='.tmp', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
