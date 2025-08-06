# Story 2.4: Implement Query Processing

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation
**Priority**: P0 - Critical
**Estimated Points**: 6
**Dependencies**: Story 2.1 (MessageBusActor core)

## Story

**As a** developer  
**I want** to execute queries with responses  
**So that** I can retrieve data without side effects

## Acceptance Criteria

- [ ] query<T,R>(_ query: Query<T,R>) returns Response<R> with correct type
- [ ] Query caching works when marked cacheable
- [ ] Cache key generation produces consistent keys
- [ ] Cache TTL respected for expiration
- [ ] Timeout handling implemented with configurable duration
- [ ] Success/failure properly set in Response type
- [ ] Layer routing validation enforced
- [ ] Performance: Can handle 10K+ queries/second (without cache)

## Dev Notes

### Query Processing Strategy
- Queries are read-only operations
- Support caching for performance
- Single handler per query type
- Return typed responses
- Should not modify state

### Caching Strategy
- Use cache-aside pattern
- Generate cache keys from query payload
- Respect TTL for cache expiration
- LRU eviction when cache full
- Thread-safe cache operations

## Tasks

### Development Tasks
- [ ] Implement query method with generic response
- [ ] Create QueryCache implementation
- [ ] Add cache key generation logic
- [ ] Implement cache TTL management
- [ ] Add query timeout handling
- [ ] Create cache statistics tracking
- [ ] Implement cache invalidation API

### Implementation Details

#### Query Cache Implementation
```swift
// QueryCache.swift

import Foundation
import Collections

actor QueryCache {
    private struct CacheEntry {
        let response: Any
        let expiresAt: Date
        let hits: Int
    }
    
    private var cache: OrderedDictionary<String, CacheEntry> = [:]
    private let maxSize: Int
    private var statistics = CacheStatistics()
    
    init(maxSize: Int = 1000) {
        self.maxSize = maxSize
    }
    
    func get<R: MessagePayload>(_ key: String, type: R.Type) -> Response<R>? {
        // Remove expired entries
        cleanExpiredEntries()
        
        guard let entry = cache[key] else {
            statistics.misses += 1
            return nil
        }
        
        // Check expiration
        if entry.expiresAt < Date() {
            cache.removeValue(forKey: key)
            statistics.misses += 1
            statistics.evictions += 1
            return nil
        }
        
        // Update hit count and move to end (LRU)
        if let response = entry.response as? Response<R> {
            cache[key] = CacheEntry(
                response: response,
                expiresAt: entry.expiresAt,
                hits: entry.hits + 1
            )
            statistics.hits += 1
            return response
        }
        
        statistics.misses += 1
        return nil
    }
    
    func set<R: MessagePayload>(_ key: String, response: Response<R>, ttl: TimeInterval) {
        // Evict if at capacity (LRU)
        if cache.count >= maxSize {
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
                statistics.evictions += 1
            }
        }
        
        let expiresAt = Date().addingTimeInterval(ttl)
        cache[key] = CacheEntry(
            response: response,
            expiresAt: expiresAt,
            hits: 0
        )
        statistics.entries = cache.count
    }
    
    func invalidate(_ key: String) {
        cache.removeValue(forKey: key)
        statistics.invalidations += 1
        statistics.entries = cache.count
    }
    
    func invalidateAll() {
        let count = cache.count
        cache.removeAll()
        statistics.invalidations += count
        statistics.entries = 0
    }
    
    func getStatistics() -> CacheStatistics {
        statistics
    }
    
    private func cleanExpiredEntries() {
        let now = Date()
        let expiredKeys = cache.compactMap { key, entry in
            entry.expiresAt < now ? key : nil
        }
        
        for key in expiredKeys {
            cache.removeValue(forKey: key)
            statistics.evictions += 1
        }
        statistics.entries = cache.count
    }
    
    // Generate cache key from query
    static func generateKey<T: MessagePayload, R: MessagePayload>(
        for query: Query<T, R>
    ) -> String {
        var hasher = Hasher()
        hasher.combine(String(describing: T.self))
        hasher.combine(String(describing: R.self))
        
        // Use custom cache key if provided
        if let customKey = query.cacheKey {
            hasher.combine(customKey)
        } else {
            // Generate from payload
            if let data = try? JSONEncoder().encode(query.payload) {
                hasher.combine(data)
            }
        }
        
        // Include destination if specified
        if let destination = query.destination {
            hasher.combine(destination.rawValue)
        }
        
        return "query-\(hasher.finalize())"
    }
}

struct CacheStatistics: Sendable {
    var hits: Int = 0
    var misses: Int = 0
    var entries: Int = 0
    var evictions: Int = 0
    var invalidations: Int = 0
    
    var hitRate: Double {
        let total = hits + misses
        guard total > 0 else { return 0 }
        return Double(hits) / Double(total)
    }
}
```

#### Enhanced Query Processing
```swift
// In MessageBusActor.swift

private let queryCache = QueryCache()

func query<T: MessagePayload, R: MessagePayload>(
    _ query: Query<T, R>
) async throws -> Response<R> {
    metrics.messagesPublished += 1
    let startTime = Date()
    
    // Layer routing validation
    if let destination = query.destination {
        guard query.source.canRoute(to: destination) else {
            metrics.errorCount += 1
            throw MessageBusError.routingViolation(
                from: query.source,
                to: destination,
                message: "Invalid layer routing for query"
            )
        }
    }
    
    // Check cache if query is cacheable
    if query.cacheable {
        let cacheKey = query.cacheKey ?? QueryCache.generateKey(for: query)
        if let cachedResponse = await queryCache.get(cacheKey, type: R.self) {
            // Update metrics for cache hit
            metrics.cacheHits += 1
            
            if configuration.enableTracing {
                logCacheHit(query, cacheKey: cacheKey)
            }
            
            return cachedResponse
        }
        metrics.cacheMisses += 1
    }
    
    // Get handler
    let key = "\(String(describing: T.self))->\(String(describing: R.self))"
    guard let handler = queryHandlers[key] else {
        metrics.errorCount += 1
        throw MessageBusError.noHandlerRegistered(
            message: "No handler registered for query type: \(T.self) -> \(R.self)"
        )
    }
    
    do {
        // Execute with timeout
        let response = try await withThrowingTaskGroup(of: Response<R>.self) { group in
            // Add handler task
            group.addTask {
                try await Task.withLocal(\.correlationId, boundTo: query.correlationId) {
                    try await handler.handle(query)
                }
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(query.timeout * 1_000_000_000))
                
                // Return timeout response
                return Response(
                    source: .infrastructure,
                    destination: query.source,
                    payload: try await self.createEmptyPayload(of: R.self),
                    success: false,
                    error: "Query timed out after \(query.timeout) seconds",
                    correlationId: query.correlationId
                )
            }
            
            // Return first result
            guard let result = try await group.next() else {
                throw MessageBusError.internalError("No result from query handler")
            }
            
            // Cancel remaining tasks
            group.cancelAll()
            
            return result
        }
        
        // Cache response if query is cacheable and successful
        if query.cacheable && response.success {
            let cacheKey = query.cacheKey ?? QueryCache.generateKey(for: query)
            let ttl = query.metadata["cache-ttl"]
                .flatMap { TimeInterval($0) }
                ?? configuration.defaultCacheTTL
            
            await queryCache.set(cacheKey, response: response, ttl: ttl)
        }
        
        // Update metrics
        let duration = Date().timeIntervalSince(startTime)
        metrics.totalProcessingTime += duration
        metrics.messagesProcessed += 1
        
        // Log if enabled
        if configuration.enableTracing {
            logQueryExecuted(query, response: response, duration: duration)
        }
        
        return response
        
    } catch {
        metrics.errorCount += 1
        
        // Return error response
        return Response(
            source: .infrastructure,
            destination: query.source,
            payload: try await createEmptyPayload(of: R.self),
            success: false,
            error: error.localizedDescription,
            correlationId: query.correlationId
        )
    }
}

// Helper to create empty payload for error responses
private func createEmptyPayload<T: MessagePayload>(of type: T.Type) async throws -> T {
    // Try to create default instance
    if let emptyData = "{}".data(using: .utf8),
       let decoded = try? JSONDecoder().decode(T.self, from: emptyData) {
        return decoded
    }
    throw MessageBusError.internalError("Cannot create empty payload for type \(T.self)")
}

// Cache invalidation APIs
func invalidateCache(for key: String) async {
    await queryCache.invalidate(key)
}

func invalidateAllCaches() async {
    await queryCache.invalidateAll()
}

func getCacheStatistics() async -> CacheStatistics {
    await queryCache.getStatistics()
}
```

### Testing Tasks
- [ ] Test query execution with response
- [ ] Test cache hit scenarios
- [ ] Test cache miss scenarios
- [ ] Test cache key generation
- [ ] Test cache TTL expiration
- [ ] Test cache LRU eviction
- [ ] Test query timeout handling
- [ ] Test layer routing validation
- [ ] Performance test with 10K queries/second
- [ ] Test cache invalidation

### Test Scenarios
```swift
// Test cache hit
func testQueryCacheHit() async throws {
    let bus = MessageBus()
    var handlerCallCount = 0
    
    await bus.handleQuery(TestRequest.self, responseType: TestResponse.self) { query in
        handlerCallCount += 1
        return Response(
            source: .domain,
            payload: TestResponse(data: "test"),
            success: true
        )
    }
    
    let query = Query(
        source: .presentation,
        payload: TestRequest(id: "123"),
        responseType: TestResponse.self,
        cacheable: true,
        cacheKey: "test-123"
    )
    
    // First call - cache miss
    let response1 = try await bus.query(query)
    XCTAssertTrue(response1.success)
    XCTAssertEqual(handlerCallCount, 1)
    
    // Second call - cache hit
    let response2 = try await bus.query(query)
    XCTAssertTrue(response2.success)
    XCTAssertEqual(handlerCallCount, 1) // Handler not called again
}

// Test cache expiration
func testCacheExpiration() async throws {
    let config = BusConfiguration(defaultCacheTTL: 0.1) // 100ms TTL
    let bus = MessageBus(configuration: config)
    var handlerCallCount = 0
    
    await bus.handleQuery(TestRequest.self, responseType: TestResponse.self) { query in
        handlerCallCount += 1
        return Response(source: .domain, payload: TestResponse(), success: true)
    }
    
    let query = Query(
        source: .presentation,
        payload: TestRequest(),
        responseType: TestResponse.self,
        cacheable: true
    )
    
    // First call
    _ = try await bus.query(query)
    XCTAssertEqual(handlerCallCount, 1)
    
    // Wait for expiration
    try await Task.sleep(nanoseconds: 200_000_000) // 200ms
    
    // Second call after expiration
    _ = try await bus.query(query)
    XCTAssertEqual(handlerCallCount, 2) // Handler called again
}
```

## Definition of Done

- [ ] Query processing fully functional
- [ ] Cache implementation complete
- [ ] Cache hit/miss/expiration working
- [ ] Query timeout working
- [ ] Layer routing validated
- [ ] Response types correct
- [ ] Performance target met (10K+ queries/sec)
- [ ] Cache statistics tracking
- [ ] All tests passing
- [ ] Documentation updated

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] Sources/SwiftMessageBus/Core/MessageBusActor.swift (updated)
- [ ] Sources/SwiftMessageBus/Core/QueryCache.swift
- [ ] Sources/SwiftMessageBus/Core/CacheStatistics.swift
- [ ] Tests/SwiftMessageBusTests/QueryProcessingTests.swift
- [ ] Tests/SwiftMessageBusTests/QueryCacheTests.swift
- [ ] Tests/SwiftMessageBusTests/CacheExpirationTests.swift

### Change Log
- 