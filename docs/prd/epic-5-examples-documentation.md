# Epic 5: Examples and Documentation

## Epic Overview
Create comprehensive examples and documentation that enable developers to quickly understand and adopt the Swift Message Bus framework.

**Priority**: P1 - High
**Estimated Duration**: Week 5
**Dependencies**: Epics 1-3 (Core functionality must be complete)

## Success Criteria
- [ ] Hello World example works in under 3 minutes
- [ ] Multiple example applications demonstrating key patterns
- [ ] Complete API documentation via DocC
- [ ] Migration guides from other frameworks
- [ ] All examples have tests and run in CI

## User Stories

### Story 5.1: Create Hello World Example
**As a** new developer  
**I want** a simple working example  
**So that** I can quickly understand the framework

**Acceptance Criteria**:
- [ ] Single file example under 100 lines
- [ ] Demonstrates all message types
- [ ] Clear comments explaining each concept
- [ ] Runs without additional setup
- [ ] Time to working: <3 minutes

**Technical Tasks**:
- Create Examples/HelloWorld/main.swift
- Add all message type examples
- Include clear documentation comments
- Create run instructions
- Test fresh install experience

### Story 5.2: Create Layered Architecture Example
**As a** developer  
**I want** a clean architecture example  
**So that** I can see layer-based routing in action

**Acceptance Criteria**:
- [ ] Complete example with all layers
- [ ] Presentation, Application, Domain, Infrastructure layers
- [ ] Shows proper message flow between layers
- [ ] Includes realistic use cases
- [ ] Well-documented patterns

**Technical Tasks**:
- Create Examples/LayeredArchitecture/
- Implement all architectural layers
- Add realistic business logic
- Show layer isolation benefits
- Document design decisions

### Story 5.3: Create Plugin Development Example
**As a** developer  
**I want** a custom plugin example  
**So that** I can extend the framework

**Acceptance Criteria**:
- [ ] Complete custom plugin implementation
- [ ] Shows all plugin lifecycle hooks
- [ ] Demonstrates middleware pattern
- [ ] Includes configuration example
- [ ] Testing approach documented

**Technical Tasks**:
- Create Examples/CustomPlugin/
- Implement example plugin
- Show configuration usage
- Add plugin tests
- Document plugin patterns

### Story 5.4: Create SwiftUI Integration Example
**As a** iOS developer  
**I want** SwiftUI integration examples  
**So that** I can use the framework in iOS apps

**Acceptance Criteria**:
- [ ] SwiftUI app using message bus
- [ ] Property wrapper integration shown
- [ ] State management patterns
- [ ] Navigation via messages
- [ ] Reactive UI updates

**Technical Tasks**:
- Create Examples/SwiftUIExample/
- Implement property wrappers
- Show state management
- Add navigation examples
- Document SwiftUI patterns

### Story 5.5: Create API Documentation
**As a** developer  
**I want** complete API documentation  
**So that** I can understand all capabilities

**Acceptance Criteria**:
- [ ] DocC documentation for all public APIs
- [ ] Code examples in documentation
- [ ] Conceptual articles included
- [ ] Symbol documentation complete
- [ ] Searchable and browsable

**Technical Tasks**:
- Add DocC comments to all public APIs
- Create conceptual documentation articles
- Add code snippets to docs
- Generate DocC archive
- Set up GitHub Pages hosting

### Story 5.6: Create Migration Guides
**As a** developer  
**I want** migration guides  
**So that** I can migrate from other frameworks

**Acceptance Criteria**:
- [ ] NotificationCenter migration guide
- [ ] Combine migration guide
- [ ] RxSwift migration guide
- [ ] Code examples for each
- [ ] Common patterns mapped

**Technical Tasks**:
- Create docs/migration/from-notification-center.md
- Create docs/migration/from-combine.md
- Create docs/migration/from-rxswift.md
- Add pattern mapping tables
- Include code comparisons

### Story 5.7: Create Performance Tuning Guide
**As a** developer  
**I want** performance optimization guidance  
**So that** I can maximize throughput

**Acceptance Criteria**:
- [ ] Performance best practices documented
- [ ] Common bottlenecks identified
- [ ] Optimization techniques explained
- [ ] Profiling instructions included
- [ ] Real-world scenarios covered

**Technical Tasks**:
- Create docs/guides/performance-tuning.md
- Document best practices
- Add profiling instructions
- Include optimization examples
- Cover scaling strategies