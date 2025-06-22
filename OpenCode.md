## Build, Test, and Lint Commands

*   **Build**: `xcodebuild -scheme Wallify build`
*   **Test**: `xcodebuild -scheme Wallify test`
*   **Run Single Test**: Requires specifying the test identifier, e.g., `xcodebuild -scheme Wallify test -only WallifyTests/WallifyTests/example` (adjust as needed)
*   **Lint**: `swiftlint` (requires SwiftLint integrated into the project)
*   **Format**: `swiftformat .` (requires SwiftFormat integrated into the project)
*   **Xcode Project Modification**: `XcodeBuildMCP` can be used for automated Xcode project file modifications (requires manual installation and setup).

## Code Style Guidelines

*   **Naming**: Use PascalCase for types (Struct, Class, Enum, Protocol) and camelCase for variables, functions, and instances.
*   **Imports**: Group related imports. Avoid wildcard imports.
*   **Formatting**: Follow standard Swift indentation (4 spaces). Keep lines reasonably short.
*   **Types**: Use explicit types unless the type is immediately clear from context.
*   **Error Handling**: Prefer Swift's native error handling (`throws`, `Result` type) over optional returns for recoverable errors.
*   **Comments**: Add comments to explain complex logic or the purpose of non-obvious code sections.
*   **Concurrency**: Use `async/await` for asynchronous operations.
*   **UI**: Follow SwiftUI conventions for view structure and data flow.