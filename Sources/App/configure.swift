import Vapor
import Leaf
import Fluent
import FluentPostgreSQL

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    //MARK: File and Sessions Middleware
    var middleware = MiddlewareConfig.default()
    middleware.use(FileMiddleware.self)
    middleware.use(SessionsMiddleware.self)
    services.register(middleware)
    
    //MARK: Cache
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    //MARK: SQL
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentPostgreSQLProvider())
    
    var dbConfig = DatabasesConfig()
    let postgreConfig: PostgreSQLDatabaseConfig
    if env.isRelease {
        postgreConfig = try PostgreSQLDatabaseConfig(url: Environment.get("DATABASE_URL")!)
    } else {
        postgreConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "ezekielelin", database: "mcedit")
    }
    let db = PostgreSQLDatabase(config: postgreConfig)
    dbConfig.add(database: db, as: .psql)
    services.register(dbConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: ReleaseMetaData.self, database: .psql)
    migrationConfig.add(model: ContributorMetaData.self, database: .psql)
    migrationConfig.add(migration: ContributorMigration1.self, database: .psql)
    services.register(migrationConfig)
}
