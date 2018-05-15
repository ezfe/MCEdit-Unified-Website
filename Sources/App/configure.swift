import Vapor
import Leaf
import Fluent
import FluentSQLite

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
    
    try services.register(FluentSQLiteProvider())
    
    var databaseConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)instantcoder.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: ReleaseMetaData.self, database: .sqlite)
    migrationConfig.add(model: ContributorMetaData.self, database: .sqlite)
//    migrationConfig.add(model: Project.self, database: .sqlite)
    services.register(migrationConfig)
}
