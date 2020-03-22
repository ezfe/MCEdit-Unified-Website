import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Redis

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = false

    let sessions = SessionsMiddleware(session: app.sessions.driver)
    app.middleware.use(sessions)

    //MARK:- PostgreSQL
    let postgresConfig: PostgresConfiguration
    if let _databaseURL = Environment.get("DATABASE_URL"),
        let databaseURL = URL(string: _databaseURL),
        let config = PostgresConfiguration(url: databaseURL) {

        postgresConfig = config
    } else {
        postgresConfig = PostgresConfiguration(hostname: "localhost",
                                               port: 5432,
                                               username: "ezekielelin",
                                               password: "",
                                               database: "mcedit")
    }

    app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

    try routes(app)
}
//    try services.register(LeafProvider())
//    try services.register(FluentPostgreSQLProvider())
//    try services.register(RedisProvider())
//    try services.register(AuthenticationProvider())
//    services.register(NIOServerConfig.default(maxBodySize: 10_000_000)) // 10 MB
//
//    //MARK:- Register middleware
//    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
//    middlewares.use(SessionsMiddleware.self)
//    services.register(middlewares)
//
//    //MARK:- Database
//    var dbConfig = DatabasesConfig()
//
//    var migrationConfig = MigrationConfig()
//    addDatabaseMigrations(&migrationConfig)
//    services.register(migrationConfig)
//
//    services.register(DatabaseConnectionPoolConfig(maxConnections: 8))
//
//    //MARK:- Redis
//    if let redisUrlString = Environment.get("REDIS_URL"), let redisUrl = URL(string: redisUrlString) {
//        typealias RedisKeyedCache = DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>
//
//        let redisConfig = RedisClientConfig(url: redisUrl)
//        let redis = try RedisDatabase(config: redisConfig)
//
//        services.register(KeyedCache.self) { (container) -> RedisKeyedCache in
//            return try container.keyedCache(for: .redis)
//        }
//        dbConfig.add(database: redis, as: .redis)
//
//        config.prefer(RedisKeyedCache.self, for: KeyedCache.self)
//    } else {
//        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
//    }
//
//    // Register databases
//    services.register(dbConfig)
//
//    //MARK:- Select Renderer
//    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
//}
//
//fileprivate func addDatabaseMigrations(_ migrations: inout MigrationConfig) {
//    migrations.add(model: ReleaseMetaData.self, database: .psql)
//    migrations.add(model: ContributorMetaData.self, database: .psql)
//    migrations.add(model: Alert.self, database: .psql)
//    migrations.add(migration: UserRole.self, database: .psql)
//    migrations.add(model: User.self, database: .psql)
//
//    migrations.add(migration: ContributorMigration2.self, database: .psql)
//}
