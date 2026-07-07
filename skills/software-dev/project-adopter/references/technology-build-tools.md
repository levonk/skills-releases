# Technology-Specific Build Tools

**Technology-Specific Build Tools**:
| Technology | Build | Test | Lint | Dev |
|------------|-------|------|------|-----|
| **Rust** | `cargo build` | `cargo test` | `cargo clippy` | `cargo run` |
| **Node.js** | `nx build` | `nx test` | `nx lint` | `nx dev` |
| **Python** | `python -m build` | `pytest` | `ruff check` | `uv run python src/main.py` |
| **Go** | `go build` | `go test` | `golangci-lint run` | `go run` |
| **Java** | `mvn compile` | `mvn test` | `checkstyle` | `mvn exec:java` |
