//
//  File.swift
//  
//
//  Created by Ezekiel Elin on 3/4/20.
//

import NIO

//extension EventLoopFuture {
//    func tryFlatMap<NewValue>(file: StaticString = #file,
//                              line: UInt = #line,
//                              _ callback: @escaping (Expectation) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
//        return flatMap(file: file, line: line) { result in
//            do {
//                return try callback(result)
//            } catch {
//                return self.eventLoop.makeFailedFuture(error, file: file, line: line)
//            }
//        }
//    }
//}
