#!/usr/bin/env python3
"""
Self-contained test runner for Kannada Baruthe E2E tests.
Starts HTTP server, runs all tests, generates report.
"""

import subprocess
import sys
import time
import os
import signal
from pathlib import Path
import socket

# Configuration
PROJECT_ROOT = Path(__file__).parent.absolute()
BUILD_DIR = PROJECT_ROOT / "build" / "web"
PORT = 8081
BASE_URL = f"http://localhost:{PORT}"
REPORT_DIR = PROJECT_ROOT / "test_reports"


def check_port_available(port):
    """Check if port is in use."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('localhost', port))
    sock.close()
    return result != 0


def kill_process_on_port(port):
    """Kill any process using the port."""
    try:
        result = subprocess.run(
            ['lsof', '-ti', f':{port}'],
            capture_output=True,
            text=True
        )
        if result.stdout:
            pids = result.stdout.strip().split('\n')
            for pid in pids:
                if pid:
                    os.kill(int(pid), signal.SIGKILL)
                    print(f"Killed process {pid} on port {port}")
    except Exception as e:
        print(f"Warning: Could not kill processes on port {port}: {e}")


def wait_for_server(url, timeout=30):
    """Wait for HTTP server to be ready."""
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            import urllib.request
            urllib.request.urlopen(url, timeout=1)
            return True
        except:
            time.sleep(0.5)
    return False


def sync_build_assets():
    """Sync assets from source to build directory."""
    print("Syncing assets to build directory...")

    # Ensure config is up to date
    source_config = PROJECT_ROOT / "config" / "app_config.json"
    build_config = BUILD_DIR / "assets" / "config" / "app_config.json"

    if build_config.exists():
        import filecmp
        if not filecmp.cmp(source_config, build_config, shallow=False):
            print("Config changed, copying updated config...")
            import shutil
            shutil.copy2(source_config, build_config)
    else:
        print("Creating build config directory...")
        build_config.parent.mkdir(parents=True, exist_ok=True)
        import shutil
        shutil.copy2(source_config, build_config)

    print("Assets synced.")


def start_http_server():
    """Start HTTP server on port 8081."""
    print(f"Starting HTTP server on port {PORT}...")

    # Check if build exists
    if not BUILD_DIR.exists():
        print(f"ERROR: Build directory not found: {BUILD_DIR}")
        print("Run: flutter build web")
        sys.exit(1)

    # Sync assets
    sync_build_assets()

    # Kill existing processes on the port
    kill_process_on_port(PORT)
    time.sleep(1)

    # Start server
    os.chdir(BUILD_DIR)
    server_process = subprocess.Popen(
        [sys.executable, '-m', 'http.server', str(PORT)],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True
    )

    # Wait for server to be ready
    print(f"Waiting for server at {BASE_URL}...")
    if wait_for_server(BASE_URL, timeout=30):
        print(f"Server ready at {BASE_URL}")
        return server_process
    else:
        server_process.terminate()
        raise RuntimeError(f"Server failed to start on port {PORT}")


def run_tests():
    """Run all pytest tests with reporting."""
    print("\n" + "=" * 60)
    print("RUNNING ALL TESTS")
    print("=" * 60 + "\n")

    # Create report directory
    REPORT_DIR.mkdir(exist_ok=True)

    # Run pytest with JUnit XML report
    cmd = [
        sys.executable, '-m', 'pytest',
        'tests/',
        '-v',
        '--tb=short',
        f'--junitxml={REPORT_DIR}/junit.xml',
        '-W', 'ignore::DeprecationWarning'
    ]

    env = os.environ.copy()
    env['PYTHONPATH'] = str(PROJECT_ROOT)

    result = subprocess.run(
        cmd,
        cwd=PROJECT_ROOT,
        env=env,
        capture_output=False
    )

    return result.returncode


def print_summary():
    """Print test summary."""
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    print(f"Reports saved to: {REPORT_DIR}")
    print(f"  - JUnit XML: {REPORT_DIR / 'junit.xml'}")
    print(f"\nTo view detailed results, check: {REPORT_DIR / 'junit.xml'}")


def main():
    """Main entry point."""
    server_process = None

    try:
        # Start HTTP server
        server_process = start_http_server()

        # Run tests
        exit_code = run_tests()

        # Print summary
        print_summary()

        return exit_code

    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
        return 130

    except Exception as e:
        print(f"\n\nError: {e}", file=sys.stderr)
        return 1

    finally:
        # Cleanup
        if server_process:
            print("\nShutting down HTTP server...")
            server_process.terminate()
            try:
                server_process.wait(timeout=5)
            except:
                server_process.kill()


if __name__ == '__main__':
    sys.exit(main())
