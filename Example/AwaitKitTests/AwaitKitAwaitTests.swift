/*
 * AwaitKit
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

@testable import AwaitKitExample
import PromiseKit
import XCTest

class AwaitKitAwaitTests: XCTestCase {
  let backgroundQueue = dispatch_queue_create("com.yannickloriot.testqueue", DISPATCH_QUEUE_CONCURRENT)
  let commonError     = NSError(domain: "com.yannickloriot.error", code: 320, userInfo: nil)

  func testSimpleAwaitPromise() {
    let promise: Promise<String> = Promise { resolve, reject in
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), backgroundQueue, {
        resolve("AwaitedPromiseKit")
      })
    }

    let name = try! await(promise)

    XCTAssertEqual(name, "AwaitedPromiseKit")
  }

  func testSimpleFailedAwaitPromise() {
    let promise: Promise<String> = Promise { resolve, reject in
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), backgroundQueue, {
        reject(self.commonError)
      })
    }

    XCTAssertThrowsError(try await(promise))
  }

  func testNoValueAwaitPromise() {
    let promise: Promise<Void> = Promise { resolve, reject in
      resolve()
    }

    XCTAssertNotNil(promise.value)
  }

  func testAwaitBlock() {
    var name: String = try! await {
      return "AwaitedPromiseKit"
    }

    XCTAssertEqual(name, "AwaitedPromiseKit")

    name = try! await {
      NSThread.sleepForTimeInterval(0.2)

      return "PromiseKit"
    }

    XCTAssertEqual(name, "PromiseKit")

    do {
      try await { throw self.commonError }

      XCTAssertTrue(false)
    }
    catch {
      XCTAssertTrue(true)
    }
  }

  func testAsyncInsideAwaitBlock() {
    let name: String = try! await(async({
      return "AwaitedPromiseKit"
    }))

    XCTAssertEqual(name, "AwaitedPromiseKit")

    let error: String? = try? await(async({
      throw self.commonError
    }))

    XCTAssertNil(error)
  }
}