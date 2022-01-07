//
//  Closures.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 06.01.2022.
//

import Foundation

typealias ClosureResult<T> = (Result<T, FoxyError>) -> Void
