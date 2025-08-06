import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftMessageBusPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    // Macros will be added here as needed
  ]
}
