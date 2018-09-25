import Vapor
import Leaf
import FluentPostgreSQL
import Authentication

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register services
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    try services.register(LeafProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    services.register(NIOServerConfig.default(maxBodySize: 10_000_000)) // 10 MB

    // Select services
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    var dbConfig = DatabasesConfig()
    let postgresConfig: PostgreSQLDatabaseConfig
    if env.isRelease {
        let databaseUrl = Environment.get("DATABASE_URL")!
        postgresConfig = PostgreSQLDatabaseConfig(url: databaseUrl, transport: .unverifiedTLS)!
    } else {
        postgresConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "ezekielelin", database: "mcedit")
    }
    
    let db = PostgreSQLDatabase(config: postgresConfig)
    dbConfig.add(database: db, as: .psql)
    services.register(dbConfig)
    
    var migrationConfig = MigrationConfig()
    addDatabaseMigrations(&migrationConfig)
    services.register(migrationConfig)
    
    services.register(DatabaseConnectionPoolConfig(maxConnections: 8))
}

fileprivate func addDatabaseMigrations(_ migrations: inout MigrationConfig) {
    migrations.add(model: ReleaseMetaData.self, database: .psql)
    migrations.add(model: ContributorMetaData.self, database: .psql)
    
    migrations.add(migration: UserRole.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
}
