//  MIT License
//
//  Copyright (c) 2018 Pablo Pallocchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import SQLite3

final class MoviesRepository {
    
    private var titleWeight = 10.0
    private var overviewWeight = 1.0
    
    private lazy var db: OpaquePointer? = {
        let path = Bundle.main.path(forResource:"movies", ofType: "db")
        var db: OpaquePointer?
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("Error opening database")
        }
        return db
    }()
    
    /**
     Get the top n movies from the repository.
     
     - Parameters:
        - limit: The amount of movies to retrieve
     
     - Returns: An array of the top n movies
     */
    func top(limit: Int = 100) -> [Movie] {
        
        var movies: [Movie] = []
        var statement: OpaquePointer?
        
        let query = "SELECT title, overview, poster, year FROM movies"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Error preparing select: \(String(cString: sqlite3_errmsg(db)!))")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if
                let cTitle = sqlite3_column_text(statement, 0),
                let cOverview = sqlite3_column_text(statement, 1),
                let cPoster = sqlite3_column_text(statement, 2)
            {
                let cYear = sqlite3_column_int64(statement, 3)
                movies.append(
                    Movie(
                        title: String(cString: cTitle),
                        overview: String(cString: cOverview),
                        poster: String(cString: cPoster),
                        year: Int(cYear)
                    )
                )
            }
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            print("Error finalizing prepared statement: \(String(cString: sqlite3_errmsg(db)!))")
        }
        
        return movies
    }
    
    /**
     Get the movies that match a given text.
     
     - Parameters:
        - text: The text to use
     
     - Returns: An array of movies matching the given text, sorted by relevance
     */
    func search(text: String) -> [Movie] {
        
        var movies: [Movie] = []
        var statement: OpaquePointer?
        
        let query = "SELECT title, overview, poster, year, matchinfo(movies, 'pcnalx') FROM movies WHERE movies MATCH '\(text)*'"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Error preparing select: \(String(cString: sqlite3_errmsg(db)!))")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if
                let cTitle = sqlite3_column_text(statement, 0),
                let cOverview = sqlite3_column_text(statement, 1),
                let cPoster = sqlite3_column_text(statement, 2)
            {
                let cYear = sqlite3_column_int64(statement, 3)

                // Read and prepare matchinfo blob
                let buf = sqlite3_column_blob(statement, 4).assumingMemoryBound(to: UInt32.self)
                let blob = [UInt32](UnsafeBufferPointer(start: buf, count: Int(sqlite3_column_bytes(statement, 4))))
                
                // Calculate score based on matchinfo values
                // Here I'm only using the first column (title) to calculate the score
                let score = OkapiBM25.score(matchinfo: blob, column: 0)
                
                movies.append(
                    Movie(
                        title: String(cString: cTitle),
                        overview: String(cString: cOverview),
                        poster: String(cString: cPoster),
                        year: Int(cYear),
                        score: score
                    )
                )
                
            }
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            print("Error finalizing prepared statement: \(String(cString: sqlite3_errmsg(db)!))")
        }
        
        // Sort the movies by the Okapi BM25 score
        return movies.sorted(by: {$0.score > $1.score})
    }

}
