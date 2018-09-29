import Vapor
import Leaf
import FluentPostgreSQL
import Redis
import Authentication

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    //MARK:- Register services
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    try services.register(LeafProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(RedisProvider())
    try services.register(AuthenticationProvider())
    services.register(NIOServerConfig.default(maxBodySize: 10_000_000)) // 10 MB

    //MARK:- Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    //MARK:- Database
    var dbConfig = DatabasesConfig()
    
    //MARK: PostgreSQL
    let postgresConfig: PostgreSQLDatabaseConfig
    if let databaseUrl = Environment.get("DATABASE_URL") {
        postgresConfig = PostgreSQLDatabaseConfig(url: databaseUrl, transport: .unverifiedTLS)!
    } else {
        postgresConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "ezekielelin", database: "mcedit")
    }
    
    let db = PostgreSQLDatabase(config: postgresConfig)
    dbConfig.add(database: db, as: .psql)
    
    var migrationConfig = MigrationConfig()
    addDatabaseMigrations(&migrationConfig)
    services.register(migrationConfig)
    
    services.register(DatabaseConnectionPoolConfig(maxConnections: 8))
    
    //MARK: Redis
    typealias RedisKeyedCache = DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>
    
    let redisConfig: RedisClientConfig
    if let redisUrlString = Environment.get("REDIS_URL"), let redisUrl = URL(string: redisUrlString) {
        redisConfig = RedisClientConfig(url: redisUrl)
    } else {
        redisConfig = RedisClientConfig(url: URL(string: "redis://localhost")!)
    }
    let redis = try RedisDatabase(config: redisConfig)
    services.register(KeyedCache.self) { (container) -> RedisKeyedCache in
        return try container.keyedCache(for: .redis)
    }
    dbConfig.add(database: redis, as: .redis)
    
    // Register databases
    services.register(dbConfig)
    
    //MARK:- Select services
    config.prefer(RedisKeyedCache.self, for: KeyedCache.self)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}

fileprivate func addDatabaseMigrations(_ migrations: inout MigrationConfig) {
    migrations.add(model: ReleaseMetaData.self, database: .psql)
    migrations.add(model: ContributorMetaData.self, database: .psql)
    migrations.add(model: Alert.self, database: .psql)
    migrations.add(migration: UserRole.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
}
